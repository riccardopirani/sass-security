import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { dispatchThreatNotifications } from '../_shared/notifications.ts';
import { assertManagerRole, getProfileOrThrow } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

type Severity = 'low' | 'medium' | 'high' | 'critical';

const normalizeSeverity = (value: string | undefined): Severity => {
  switch (value) {
    case 'critical':
      return 'critical';
    case 'high':
      return 'high';
    case 'low':
      return 'low';
    case 'medium':
    default:
      return 'medium';
  }
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
    const mailLocale =
      (body?.locale as string | undefined)?.trim() ||
      req.headers.get('accept-language')?.split(',')[0]?.trim().split(/[-_]/)[0] ||
      undefined;
    const title = (body?.title as string | undefined)?.trim();
    const message = (body?.message as string | undefined)?.trim();
    const severity = normalizeSeverity((body?.severity as string | undefined)?.trim().toLowerCase());
    const employeeId = (body?.employeeId as string | undefined)?.trim();
    const alertKind = (body?.alertKind as string | undefined)?.trim() || 'generic';
    const channelsInput = (body?.channels as string[] | undefined) ?? [
      'in_app',
      'email',
      'slack',
      'teams',
      'push',
    ];

    if (!title || !message) {
      return json({ error: 'title and message are required' }, 400);
    }

    const channelSettings = await adminClient
      .from('security_cg_notification_channels')
      .select('email_enabled,slack_webhook_url,teams_webhook_url,push_enabled')
      .eq('company_id', profile.company_id)
      .maybeSingle();

    const recipientsResult = await adminClient
      .from('security_cg_employees')
      .select('email')
      .eq('company_id', profile.company_id);

    if (recipientsResult.error) {
      return json({ error: recipientsResult.error.message }, 400);
    }

    const recipients = (recipientsResult.data ?? [])
      .map((row) => (row.email as string | undefined)?.trim().toLowerCase())
      .filter((email): email is string => Boolean(email));

    const alertInsert = await adminClient
      .from('security_cg_alerts')
      .insert({
        company_id: profile.company_id,
        employee_id: employeeId || null,
        severity,
        title,
        message,
        alert_kind: alertKind,
        channels: channelsInput,
        metadata: {
          dispatched_by: profile.id,
          dispatched_at: new Date().toISOString(),
        },
      })
      .select('id')
      .single();

    if (alertInsert.error || !alertInsert.data) {
      return json({ error: alertInsert.error?.message ?? 'Unable to create alert' }, 400);
    }

    const channel = channelSettings.data;
    const notifications = await dispatchThreatNotifications({
      recipients: channel?.email_enabled === false ? [] : recipients,
      title,
      message,
      severity,
      locale: mailLocale,
      slackWebhookUrl: channelsInput.includes('slack') ? channel?.slack_webhook_url : null,
      teamsWebhookUrl: channelsInput.includes('teams') ? channel?.teams_webhook_url : null,
    });

    return json({
      alert_id: alertInsert.data.id,
      channels_requested: channelsInput,
      channels_dispatched: {
        in_app: true,
        email: notifications.email_sent,
        slack: notifications.slack_sent,
        teams: notifications.teams_sent,
        push: channel?.push_enabled !== false && notifications.push_sent,
      },
      email_recipients: notifications.email_recipients,
    });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});

