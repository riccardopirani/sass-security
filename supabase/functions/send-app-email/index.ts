import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import {
  dispatchTransactionalEmail,
  type TransactionalTemplateId,
} from '../_shared/transactional_templates.ts';

const validTemplates: TransactionalTemplateId[] = [
  'threat_alert',
  'security_report',
  'subscription_invoice_paid',
  'subscription_payment_failed',
  'welcome',
];

const authorize = (req: Request): boolean => {
  const internal = Deno.env.get('EMAIL_INTERNAL_SECRET');
  if (internal && req.headers.get('x-internal-email-secret') === internal) {
    return true;
  }
  const sr = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  const auth = req.headers.get('Authorization');
  if (sr && auth === `Bearer ${sr}`) {
    return true;
  }
  return false;
};

const normalizeRecipients = (raw: unknown): string[] => {
  if (Array.isArray(raw)) {
    return raw
      .filter((x): x is string => typeof x === 'string')
      .map((e) => e.trim())
      .filter(Boolean);
  }
  if (typeof raw === 'string' && raw.trim()) {
    return [raw.trim()];
  }
  return [];
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return handleOptions();
  }

  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  if (!authorize(req)) {
    return json({ error: 'Unauthorized' }, 401);
  }

  try {
    const body = await req.json();
    const template = body?.template as string | undefined;
    if (!template || !validTemplates.includes(template as TransactionalTemplateId)) {
      return json({ error: 'Invalid or missing template' }, 400);
    }

    const to = normalizeRecipients(body?.to);
    if (to.length === 0) {
      return json({ error: 'to must be a non-empty string or string array' }, 400);
    }

    const data =
      body?.data && typeof body.data === 'object' && !Array.isArray(body.data)
        ? (body.data as Record<string, string | undefined>)
        : {};

    const result = await dispatchTransactionalEmail({
      template: template as TransactionalTemplateId,
      locale: typeof body?.locale === 'string' ? body.locale : undefined,
      to,
      data,
      from: typeof body?.from === 'string' ? body.from : undefined,
    });

    if (!result.ok) {
      return json({ error: result.error ?? 'Resend error' }, 502);
    }

    return json({ ok: true });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});
