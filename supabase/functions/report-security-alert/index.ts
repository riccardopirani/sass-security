import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { dispatchTransactionalEmail } from '../_shared/transactional_templates.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

type IncidentType = 'virus' | 'hacking';
type AlertSeverity = 'low' | 'medium' | 'high';

const validIncidentTypes = new Set<IncidentType>(['virus', 'hacking']);
const validSeverities = new Set<AlertSeverity>(['low', 'medium', 'high']);

const incidentLabel = (type: IncidentType) =>
  type === 'hacking' ? 'Tentativo di hacking registrato' : 'Virus registrato';

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
    const mailLocale =
      (body?.locale as string | undefined)?.trim() ||
      req.headers.get('accept-language')?.split(',')[0]?.trim().split(/[-_]/)[0] ||
      undefined;

    const incidentTypeRaw =
      (body?.incidentType as string | undefined)?.trim().toLowerCase() ?? '';
    const severityRaw =
      (body?.severity as string | undefined)?.trim().toLowerCase() ?? 'high';
    const titleRaw = (body?.title as string | undefined)?.trim() ?? '';
    const detailsRaw = (body?.details as string | undefined)?.trim() ?? '';

    if (!validIncidentTypes.has(incidentTypeRaw as IncidentType)) {
      return json({ error: 'incidentType must be virus or hacking' }, 400);
    }

    if (detailsRaw.length < 4) {
      return json({ error: 'details is required' }, 400);
    }

    if (detailsRaw.length > 5000) {
      return json({ error: 'details is too long' }, 400);
    }

    const incidentType = incidentTypeRaw as IncidentType;
    const severity = validSeverities.has(severityRaw as AlertSeverity)
      ? (severityRaw as AlertSeverity)
      : 'high';

    const fallbackTitle = incidentLabel(incidentType);
    const title = titleRaw.length === 0 ? fallbackTitle : titleRaw;

    if (title.length > 140) {
      return json({ error: 'title is too long' }, 400);
    }

    const profile = await adminClient
      .from('security_cg_profiles')
      .select('company_id,name,email')
      .eq('id', user.id)
      .single();

    if (profile.error || !profile.data) {
      return json({ error: 'Profile not found' }, 404);
    }

    const reporter = profile.data;

    const reporterEmployee = await adminClient
      .from('security_cg_employees')
      .select('id')
      .eq('company_id', reporter.company_id)
      .eq('auth_user_id', user.id)
      .maybeSingle();

    const reporterEmployeeId = reporterEmployee.data?.id as string | undefined;
    const reporterName = reporter.name || reporter.email || 'Unknown user';

    const detailsWithReporter = `${detailsRaw}\n\nSegnalata da: ${reporterName} (${reporter.email})`;

    const alertInsert = await adminClient
      .from('security_cg_alerts')
      .insert({
        company_id: reporter.company_id,
        employee_id: reporterEmployeeId ?? null,
        severity,
        title,
        message: detailsWithReporter,
      })
      .select('id')
      .single();

    if (alertInsert.error || !alertInsert.data) {
      return json(
        {
          error: alertInsert.error?.message ?? 'Unable to create alert',
        },
        400,
      );
    }

    const employees = await adminClient
      .from('security_cg_employees')
      .select('email')
      .eq('company_id', reporter.company_id);

    if (employees.error) {
      return json({ error: employees.error.message }, 400);
    }

    const recipients = new Set<string>();
    for (const row of employees.data ?? []) {
      const email = (row.email as string | undefined)?.trim().toLowerCase();
      if (email && email.length > 3) {
        recipients.add(email);
      }
    }

    const reporterEmail = reporter.email?.trim().toLowerCase();
    if (reporterEmail && reporterEmail.length > 3) {
      recipients.add(reporterEmail);
    }

    if (recipients.size === 0) {
      return json({ error: 'No recipients found for this company.' }, 400);
    }

    const emailResult = await dispatchTransactionalEmail({
      template: 'security_report',
      locale: mailLocale,
      to: [...recipients],
      data: {
        summary: detailsWithReporter,
        reporter: reporterName,
        companyId: reporter.company_id,
      },
    });

    if (!emailResult.ok) {
      return json(
        { error: emailResult.error ?? 'Unable to send alert email' },
        502,
      );
    }

    return json({
      alert_id: alertInsert.data.id,
      emailed_count: recipients.size,
      recipients_count: recipients.size,
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
