import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { getProfileOrThrow } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

const openAiApiKey = Deno.env.get('OPENAI_API_KEY') ?? '';
const openAiModel = Deno.env.get('OPENAI_MODEL') ?? 'gpt-4.1-mini';

const fallbackAnswer = (question: string, context: Record<string, unknown>) => {
  const q = question.toLowerCase();

  if (q.includes('utente') && q.includes('rischio')) {
    return `L'utente con rischio maggiore è ${context.top_user_name ?? 'N/A'} con score ${context.top_user_score ?? 0}/100.`;
  }

  if (q.includes('pericoloso') || q.includes('danger')) {
    return `Valutazione rapida: livello ${context.latest_severity ?? 'medium'}. Azione consigliata: contenimento + training immediato se coinvolge phishing/click.`;
  }

  if (q.includes('cosa devo fare') || q.includes('what should i do')) {
    return 'Passi consigliati: 1) valida l’evento, 2) isola account/device se necessario, 3) forza MFA/reset password, 4) assegna micro-training, 5) monitora 24h.';
  }

  return 'Copilot: posso aiutarti su priorità incidenti, utenti più a rischio e azioni di remediation. Fai una domanda più specifica.';
};

const callOpenAi = async (question: string, context: Record<string, unknown>) => {
  if (!openAiApiKey) {
    return null;
  }

  const prompt =
    'You are a SOC assistant. Answer in Italian, concise and actionable. ' +
    `Question: ${question}\n` +
    `Context JSON: ${JSON.stringify(context)}`;

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${openAiApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: openAiModel,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.2,
    }),
  });

  if (!response.ok) {
    return null;
  }

  const data = await response.json();
  const content = data?.choices?.[0]?.message?.content as string | undefined;
  return content?.trim() || null;
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return handleOptions();
  }

  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  try {
    const user = await requireUser(req);
    const profile = await getProfileOrThrow(user.id);
    const body = await req.json();
    const question = (body?.question as string | undefined)?.trim();

    if (!question) {
      return json({ error: 'question is required' }, 400);
    }

    const topRisky = await adminClient
      .from('security_cg_employees')
      .select('id,name,risk_score')
      .eq('company_id', profile.company_id)
      .order('risk_score', { ascending: false })
      .limit(3);

    const openIncidents = await adminClient
      .from('security_cg_incidents')
      .select('id,severity')
      .eq('company_id', profile.company_id)
      .eq('status', 'open');

    const openAlerts = await adminClient
      .from('security_cg_alerts')
      .select('id,severity,created_at')
      .eq('company_id', profile.company_id)
      .eq('is_read', false)
      .order('created_at', { ascending: false })
      .limit(20);

    const context = {
      company_id: profile.company_id,
      top_user_name: topRisky.data?.[0]?.name ?? 'N/A',
      top_user_score: topRisky.data?.[0]?.risk_score ?? 0,
      open_incidents: (openIncidents.data ?? []).length,
      open_alerts: (openAlerts.data ?? []).length,
      latest_severity: openAlerts.data?.[0]?.severity ?? 'medium',
      top_risky_users: topRisky.data ?? [],
    };

    const aiAnswer = await callOpenAi(question, context);
    const answer = aiAnswer ?? fallbackAnswer(question, context);

    return json({
      answer,
      context,
      provider: aiAnswer ? 'openai' : 'fallback',
    });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});

