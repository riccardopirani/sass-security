import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
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
    const body = await req.json();

    const name = (body?.name as string | undefined)?.trim();
    const template = (body?.template as string | undefined)?.trim();
    const targetEmployeeIds = (body?.targetEmployeeIds as string[] | undefined) ?? [];
    const simulateBehavior = body?.simulateBehavior !== false;

    if (!name || !template) {
      return json({ error: 'name and template are required' }, 400);
    }

    const profile = await adminClient
      .from('cg_profiles')
      .select('company_id,role')
      .eq('id', user.id)
      .single();

    if (profile.error || !profile.data) {
      return json({ error: 'Profile not found' }, 404);
    }

    if (profile.data.role !== 'admin') {
      return json({ error: 'Only admins can send phishing tests' }, 403);
    }

    let employeesQuery = adminClient
      .from('cg_employees')
      .select('id')
      .eq('company_id', profile.data.company_id);

    if (targetEmployeeIds.length > 0) {
      employeesQuery = employeesQuery.in('id', targetEmployeeIds);
    }

    const employeesResult = await employeesQuery;
    if (employeesResult.error) {
      return json({ error: employeesResult.error.message }, 400);
    }

    const employeeIds = (employeesResult.data ?? []).map((row) => row.id as string);
    if (employeeIds.length === 0) {
      return json({ error: 'No employees found for campaign' }, 400);
    }

    const campaignResult = await adminClient
      .from('cg_phishing_campaigns')
      .insert({
        company_id: profile.data.company_id,
        created_by: user.id,
        name,
        template,
        status: 'sent',
      })
      .select('id')
      .single();

    if (campaignResult.error || !campaignResult.data) {
      return json({ error: campaignResult.error?.message ?? 'Unable to create campaign' }, 400);
    }

    const campaignId = campaignResult.data.id as string;

    const sentEvents = employeeIds.map((employeeId) => ({
      company_id: profile.data.company_id,
      campaign_id: campaignId,
      employee_id: employeeId,
      event_type: 'sent',
    }));

    await adminClient.from('cg_phishing_events').insert(sentEvents);

    const simulatedEvents: Array<{
      company_id: string;
      campaign_id: string;
      employee_id: string;
      event_type: 'opened' | 'clicked';
    }> = [];

    if (simulateBehavior) {
      for (const employeeId of employeeIds) {
        const opened = Math.random() < 0.45;
        const clicked = Math.random() < 0.17;

        if (opened) {
          simulatedEvents.push({
            company_id: profile.data.company_id,
            campaign_id: campaignId,
            employee_id: employeeId,
            event_type: 'opened',
          });
        }

        if (clicked) {
          simulatedEvents.push({
            company_id: profile.data.company_id,
            campaign_id: campaignId,
            employee_id: employeeId,
            event_type: 'clicked',
          });
        }
      }
    }

    if (simulatedEvents.length > 0) {
      await adminClient.from('cg_phishing_events').insert(simulatedEvents);
    }

    await adminClient.from('cg_alerts').insert({
      company_id: profile.data.company_id,
      severity: 'low',
      title: 'Phishing campaign launched',
      message: `${name} was sent to ${employeeIds.length} employees.`,
    });

    return json({
      campaign_id: campaignId,
      sent: employeeIds.length,
      simulated_events: simulatedEvents.length,
    });
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : 'Unexpected error',
      },
      400,
    );
  }
});
