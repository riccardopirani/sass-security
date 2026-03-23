import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { assertManagerRole, getProfileOrThrow } from '../_shared/roles.ts';
import { requireUser } from '../_shared/supabase.ts';

const openAiApiKey = Deno.env.get('OPENAI_API_KEY') ?? '';
const openAiModel = Deno.env.get('OPENAI_MODEL') ?? 'gpt-4.1-mini';

const fallbackTemplates = (scenario: string, targetRole: string) => {
  const subjectA = `[Action Required] ${scenario}`;
  const bodyA =
    `Hi ${targetRole},\n\n` +
    `We need you to quickly review ${scenario}. ` +
    `Please complete verification through the internal portal in the next 30 minutes.\n\n` +
    `Security Operations`;

  const subjectB = `[Reminder] ${scenario} update`;
  const bodyB =
    `Hello ${targetRole},\n\n` +
    `This is a scheduled request related to ${scenario}. ` +
    `Please review the attached instructions and confirm your account details.\n\n` +
    `IT Support`;

  return {
    subject_a: subjectA,
    body_a: bodyA,
    subject_b: subjectB,
    body_b: bodyB,
    generated_by: 'fallback',
  };
};

const callOpenAi = async (scenario: string, targetRole: string) => {
  if (!openAiApiKey) {
    return null;
  }

  const prompt =
    'Create two short phishing simulation templates for awareness training. ' +
    'Return strict JSON with keys: subject_a, body_a, subject_b, body_b. ' +
    `Scenario: ${scenario}. Target role: ${targetRole}.`;

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${openAiApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: openAiModel,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.8,
      response_format: { type: 'json_object' },
    }),
  });

  if (!response.ok) {
    return null;
  }

  const data = await response.json();
  const content = data?.choices?.[0]?.message?.content as string | undefined;
  if (!content) {
    return null;
  }

  try {
    const parsed = JSON.parse(content) as Record<string, string>;
    if (
      parsed.subject_a &&
      parsed.body_a &&
      parsed.subject_b &&
      parsed.body_b
    ) {
      return {
        subject_a: parsed.subject_a.trim(),
        body_a: parsed.body_a.trim(),
        subject_b: parsed.subject_b.trim(),
        body_b: parsed.body_b.trim(),
        generated_by: 'openai',
      };
    }
  } catch {
    return null;
  }

  return null;
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
    assertManagerRole(profile.role);

    const body = await req.json();
    const scenario = (body?.scenario as string | undefined)?.trim() || 'security policy update';
    const targetRole = (body?.targetRole as string | undefined)?.trim() || 'employee';

    const generated = (await callOpenAi(scenario, targetRole)) ?? fallbackTemplates(scenario, targetRole);
    return json(generated);
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});

