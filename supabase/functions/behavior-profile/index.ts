import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { getProfileOrThrow } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

const hourBucket = (isoDate: string | null | undefined) => {
  const date = isoDate ? new Date(isoDate) : new Date(0);
  if (Number.isNaN(date.getTime())) {
    return 'unknown';
  }
  return `${date.getUTCHours().toString().padStart(2, '0')}:00`;
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
    const employeeId = (body?.employeeId as string | undefined)?.trim();

    const query = adminClient
      .from('cg_behavior_events')
      .select('employee_id,event_type,risk_weight,metadata,created_at')
      .eq('company_id', profile.company_id)
      .gte('created_at', new Date(Date.now() - 30 * 24 * 3600 * 1000).toISOString());

    const eventsResult = employeeId ? await query.eq('employee_id', employeeId) : await query;

    if (eventsResult.error) {
      return json({ error: eventsResult.error.message }, 400);
    }

    const events = eventsResult.data ?? [];
    const riskyHours = new Map<string, number>();
    const riskyDevices = new Map<string, number>();
    const eventFrequency = new Map<string, number>();

    let totalWeight = 0;
    for (const event of events) {
      const weight = (event.risk_weight as number | null) ?? 0;
      totalWeight += weight;

      const hour = hourBucket(event.created_at as string | undefined);
      riskyHours.set(hour, (riskyHours.get(hour) ?? 0) + weight);

      const metadata = (event.metadata as Record<string, unknown> | null) ?? {};
      const device = (metadata.device as string | undefined) ?? 'unknown';
      riskyDevices.set(device, (riskyDevices.get(device) ?? 0) + weight);

      const eventType = (event.event_type as string | undefined) ?? 'unknown';
      eventFrequency.set(eventType, (eventFrequency.get(eventType) ?? 0) + 1);
    }

    const profileScore = events.length === 0 ? 0 : Math.min(100, Math.round(totalWeight / events.length));

    const topHours = [...riskyHours.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([hour, score]) => ({ hour, score }));

    const topDevices = [...riskyDevices.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([device, score]) => ({ device, score }));

    const topEvents = [...eventFrequency.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 8)
      .map(([eventType, count]) => ({ event_type: eventType, count }));

    return json({
      employee_id: employeeId ?? 'all',
      behavior_risk_profile: profileScore,
      risky_hours: topHours,
      risky_devices: topDevices,
      event_patterns: topEvents,
      samples: events.length,
    });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});

