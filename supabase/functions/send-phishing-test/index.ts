import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { assertManagerRole, getProfileOrThrow } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

const makeVariant = (base: string, tone: 'urgent' | 'neutral') => {
  if (tone === 'urgent') {
    return `${base}\n\nThis is time-sensitive and requires immediate action.`;
  }
  return `${base}\n\nPlease review and confirm when completed.`;
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
    const body = await req.json();

    const name = (body?.name as string | undefined)?.trim();
    const baseTemplate = (body?.template as string | undefined)?.trim();
    const templateAFromBody = (body?.templateA as string | undefined)?.trim();
    const templateBFromBody = (body?.templateB as string | undefined)?.trim();
    const targetEmployeeIds = (body?.targetEmployeeIds as string[] | undefined) ?? [];
    const simulateBehavior = body?.simulateBehavior !== false;
    const useAi = body?.useAi === true;
    const abTestEnabled = body?.abTestEnabled !== false;
    const campaignMode = body?.campaignMode === 'automatic' ? 'automatic' : 'manual';

    if (!name) {
      return json({ error: 'name is required' }, 400);
    }

    const profile = await getProfileOrThrow(user.id);
    assertManagerRole(profile.role);

    let templateA = templateAFromBody || baseTemplate || '';
    let templateB = templateBFromBody || '';

    if (!templateA && useAi) {
      const seed = `This campaign simulates ${name}.`;
      templateA = makeVariant(seed, 'urgent');
      templateB = makeVariant(seed, 'neutral');
    }

    if (!templateA) {
      return json({ error: 'template/templateA is required' }, 400);
    }

    if (abTestEnabled && !templateB) {
      templateB = makeVariant(templateA, 'neutral');
    }

    let employeesQuery = adminClient
      .from('cg_employees')
      .select('id')
      .eq('company_id', profile.company_id);

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
        company_id: profile.company_id,
        created_by: user.id,
        name,
        template: templateA,
        template_variant_a: templateA,
        template_variant_b: templateB || null,
        ab_test_enabled: abTestEnabled,
        campaign_mode: campaignMode,
        generated_by_ai: useAi,
        status: 'sent',
      })
      .select('id')
      .single();

    if (campaignResult.error || !campaignResult.data) {
      return json({ error: campaignResult.error?.message ?? 'Unable to create campaign' }, 400);
    }

    const campaignId = campaignResult.data.id as string;

    const sentEvents = employeeIds.map((employeeId) => ({
      company_id: profile.company_id,
      campaign_id: campaignId,
      employee_id: employeeId,
      event_type: 'sent',
    }));

    await adminClient.from('cg_phishing_events').insert(sentEvents);

    const simulatedEvents: Array<{
      company_id: string;
      campaign_id: string;
      employee_id: string;
      event_type: 'opened' | 'clicked' | 'credential_submitted';
    }> = [];

    let openedCount = 0;
    let clickedCount = 0;
    let credentialCount = 0;

    if (simulateBehavior) {
      for (const employeeId of employeeIds) {
        const opened = Math.random() < 0.48;
        const clicked = Math.random() < 0.21;
        const credentialSubmitted = clicked && Math.random() < 0.32;

        if (opened) {
          openedCount += 1;
          simulatedEvents.push({
            company_id: profile.company_id,
            campaign_id: campaignId,
            employee_id: employeeId,
            event_type: 'opened',
          });
        }

        if (clicked) {
          clickedCount += 1;
          simulatedEvents.push({
            company_id: profile.company_id,
            campaign_id: campaignId,
            employee_id: employeeId,
            event_type: 'clicked',
          });
        }

        if (credentialSubmitted) {
          credentialCount += 1;
          simulatedEvents.push({
            company_id: profile.company_id,
            campaign_id: campaignId,
            employee_id: employeeId,
            event_type: 'credential_submitted',
          });
        }
      }
    }

    if (simulatedEvents.length > 0) {
      await adminClient.from('cg_phishing_events').insert(simulatedEvents);
    }

    await adminClient.from('cg_alerts').insert({
      company_id: profile.company_id,
      severity: 'low',
      title: 'Phishing campaign launched',
      message:
        `${name} sent to ${employeeIds.length} employees. ` +
        `Open rate: ${employeeIds.length == 0 ? 0 : ((openedCount / employeeIds.length) * 100).toFixed(1)}%, ` +
        `Click rate: ${employeeIds.length == 0 ? 0 : ((clickedCount / employeeIds.length) * 100).toFixed(1)}%, ` +
        `Credential submission rate: ${employeeIds.length == 0 ? 0 : ((credentialCount / employeeIds.length) * 100).toFixed(1)}%.`,
      alert_kind: 'phishing_campaign',
      channels: ['in_app', 'email'],
    });

    const sent = employeeIds.length;
    const openRate = sent === 0 ? 0 : (openedCount / sent) * 100;
    const clickRate = sent === 0 ? 0 : (clickedCount / sent) * 100;
    const credentialRate = sent === 0 ? 0 : (credentialCount / sent) * 100;

    return json({
      campaign_id: campaignId,
      sent,
      opened: openedCount,
      clicked: clickedCount,
      credential_submitted: credentialCount,
      open_rate: Number(openRate.toFixed(2)),
      click_rate: Number(clickRate.toFixed(2)),
      credential_submission_rate: Number(credentialRate.toFixed(2)),
      ab_test_enabled: abTestEnabled,
      generated_by_ai: useAi,
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
