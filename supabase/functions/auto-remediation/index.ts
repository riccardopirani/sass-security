import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { assertManagerRole, getProfileOrThrow } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

type ActionType = 'reset_password' | 'block_account' | 'force_mfa' | 'isolate_user';

type Suggestion = {
  action_type: ActionType;
  reason: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
};

const createSuggestions = (riskScore: number, criticalIncidents: number): Suggestion[] => {
  const suggestions: Suggestion[] = [];

  if (criticalIncidents > 0) {
    suggestions.push({
      action_type: 'isolate_user',
      reason: 'Critical incident detected for this user.',
      severity: 'critical',
    });
  }

  if (riskScore >= 85) {
    suggestions.push({
      action_type: 'block_account',
      reason: 'Risk score >= 85.',
      severity: 'critical',
    });
  }

  if (riskScore >= 65) {
    suggestions.push({
      action_type: 'force_mfa',
      reason: 'Risk score >= 65.',
      severity: 'high',
    });
  }

  if (riskScore >= 50) {
    suggestions.push({
      action_type: 'reset_password',
      reason: 'Risk score >= 50.',
      severity: 'medium',
    });
  }

  return suggestions;
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
    const employeeId = (body?.employeeId as string | undefined)?.trim();
    const incidentId = (body?.incidentId as string | undefined)?.trim();
    const execute = body?.execute === true;

    if (!employeeId && !incidentId) {
      return json({ error: 'employeeId or incidentId is required' }, 400);
    }

    let targetEmployeeId = employeeId;
    if (!targetEmployeeId && incidentId) {
      const incident = await adminClient
        .from('cg_incidents')
        .select('employee_id')
        .eq('id', incidentId)
        .eq('company_id', profile.company_id)
        .maybeSingle();
      targetEmployeeId = (incident.data?.employee_id as string | undefined) ?? undefined;
    }

    if (!targetEmployeeId) {
      return json({ error: 'Target employee not found' }, 404);
    }

    const employee = await adminClient
      .from('cg_employees')
      .select('id,risk_score,mfa_enabled')
      .eq('id', targetEmployeeId)
      .eq('company_id', profile.company_id)
      .single();

    if (employee.error || !employee.data) {
      return json({ error: 'Employee not found' }, 404);
    }

    const incidents = await adminClient
      .from('cg_incidents')
      .select('id,severity,status')
      .eq('company_id', profile.company_id)
      .eq('employee_id', targetEmployeeId)
      .eq('status', 'open');

    const criticalIncidents = (incidents.data ?? []).filter(
      (item) => item.severity === 'critical',
    ).length;
    const riskScore = (employee.data.risk_score as number | null) ?? 0;

    const suggestions = createSuggestions(riskScore, criticalIncidents);
    const executed: Suggestion[] = [];

    if (execute) {
      for (const suggestion of suggestions) {
        await adminClient.from('cg_remediation_actions').insert({
          company_id: profile.company_id,
          employee_id: targetEmployeeId,
          incident_id: incidentId || null,
          action_type: suggestion.action_type,
          status: 'executed',
          reason: suggestion.reason,
          created_by: profile.id,
        });

        if (suggestion.action_type === 'force_mfa') {
          await adminClient
            .from('cg_employees')
            .update({ force_mfa: true, updated_at: new Date().toISOString() })
            .eq('id', targetEmployeeId);
        }

        executed.push(suggestion);
      }
    } else {
      for (const suggestion of suggestions) {
        await adminClient.from('cg_remediation_actions').insert({
          company_id: profile.company_id,
          employee_id: targetEmployeeId,
          incident_id: incidentId || null,
          action_type: suggestion.action_type,
          status: 'suggested',
          reason: suggestion.reason,
          created_by: profile.id,
        });
      }
    }

    return json({
      employee_id: targetEmployeeId,
      risk_score: riskScore,
      critical_incidents: criticalIncidents,
      suggested_actions: suggestions,
      executed_actions: executed,
      executed: execute,
    });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});

