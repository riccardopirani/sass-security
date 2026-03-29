import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { getProfileOrThrow } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

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
    const eventId = (body?.eventId as string | undefined)?.trim();
    const action = (body?.action as string | undefined)?.trim() ?? 'approve';

    if (!eventId) {
      return json({ error: 'eventId is required' }, 400);
    }

    const event = await adminClient
      .from('security_cg_security_events')
      .select('id,company_id,employee_id,event_kind,severity,status')
      .eq('id', eventId)
      .eq('company_id', profile.company_id)
      .single();

    if (event.error || !event.data) {
      return json({ error: 'Security event not found' }, 404);
    }

    const nextStatus = 'resolved';
    await adminClient
      .from('security_cg_security_events')
      .update({
        status: nextStatus,
        updated_at: new Date().toISOString(),
      })
      .eq('id', eventId);

    await adminClient.from('security_cg_alerts').insert({
      company_id: profile.company_id,
      employee_id: event.data.employee_id,
      severity: event.data.severity,
      title: 'Security event resolved',
      message: `Event ${event.data.event_kind} was ${action === 'block' ? 'blocked' : 'approved'} by user action.`,
      alert_kind: 'resolution',
      channels: ['in_app'],
      metadata: {
        event_id: eventId,
        action,
        resolved_by: profile.id,
      },
    });

    return json({
      event_id: eventId,
      action,
      status: nextStatus,
    });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});

