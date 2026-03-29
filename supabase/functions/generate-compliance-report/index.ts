import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { PDFDocument, StandardFonts, rgb } from 'https://esm.sh/pdf-lib@1.17.1';

import { handleOptions, json } from '../_shared/cors.ts';
import { getProfileOrThrow, isManagerRole } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

const companySelect =
  'id,name,risk_score,benchmark_percentile,industry,company_size,region';
const companyFallbackSelect = 'id,name,risk_score';

const fetchCompanyWithBenchmarkFallback = async (companyId: string) => {
  const company = await adminClient
    .from('security_cg_companies')
    .select(companySelect)
    .eq('id', companyId)
    .single();

  if (company.error?.code !== '42703') {
    return company;
  }

  const fallback = await adminClient
    .from('security_cg_companies')
    .select(companyFallbackSelect)
    .eq('id', companyId)
    .single();

  return {
    data:
      fallback.data == null
        ? null
        : {
            ...fallback.data,
            benchmark_percentile: 0,
            industry: 'general',
            company_size: 'smb',
            region: 'global',
          },
    error: fallback.error,
  };
};

const formatDate = (value: Date) =>
  `${value.getUTCFullYear()}-${`${value.getUTCMonth() + 1}`.padStart(2, '0')}-${`${value.getUTCDate()}`.padStart(2, '0')}`;

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
    const role = profile.role;

    if (!isManagerRole(role) && role !== 'auditor') {
      return json({ error: 'Only manager/admin/auditor can generate reports' }, 403);
    }

    const company = await fetchCompanyWithBenchmarkFallback(profile.company_id);

    const employees = await adminClient
      .from('security_cg_employees')
      .select('id,risk_score,training_completion,mfa_enabled')
      .eq('company_id', profile.company_id);

    const incidents = await adminClient
      .from('security_cg_incidents')
      .select('id,severity,status,created_at')
      .eq('company_id', profile.company_id)
      .gte('created_at', new Date(Date.now() - 30 * 24 * 3600 * 1000).toISOString());

    const openIncidents = (incidents.data ?? []).filter((item) => item.status === 'open').length;
    const criticalIncidents = (incidents.data ?? []).filter(
      (item) => item.severity === 'critical',
    ).length;

    const empRows = employees.data ?? [];
    const employeeCount = empRows.length;
    const avgTraining =
      employeeCount === 0
        ? 0
        : Math.round(
            empRows.reduce((sum, item) => sum + ((item.training_completion as number | null) ?? 0), 0) /
              employeeCount,
          );
    const mfaCoverage =
      employeeCount === 0
        ? 0
        : Math.round(
            (empRows.filter((item) => (item.mfa_enabled as boolean | null) === true).length /
              employeeCount) *
              100,
          );
    const highRiskUsers = empRows.filter((item) => ((item.risk_score as number | null) ?? 0) >= 70).length;

    const reportPayload = {
      generated_at: new Date().toISOString(),
      company: company.data ?? null,
      metrics: {
        employee_count: employeeCount,
        average_training_completion: avgTraining,
        mfa_coverage: mfaCoverage,
        high_risk_users: highRiskUsers,
        open_incidents_last_30d: openIncidents,
        critical_incidents_last_30d: criticalIncidents,
      },
    };

    const pdf = await PDFDocument.create();
    const page = pdf.addPage([595, 842]);
    const font = await pdf.embedFont(StandardFonts.Helvetica);
    const bold = await pdf.embedFont(StandardFonts.HelveticaBold);

    let y = 790;
    const write = (text: string, size = 12, boldText = false) => {
      page.drawText(text, {
        x: 50,
        y,
        size,
        font: boldText ? bold : font,
        color: rgb(0.08, 0.12, 0.24),
      });
      y -= size + 8;
    };

    write('CyberGuard Audit & Compliance Report', 20, true);
    write(`Date: ${formatDate(new Date())}`);
    y -= 6;
    write(`Company: ${(company.data?.name as string | undefined) ?? 'N/A'}`, 14, true);
    write(`Risk score: ${(company.data?.risk_score as number | undefined) ?? 0}/100`);
    write(
      `Benchmark percentile: ${(company.data?.benchmark_percentile as number | undefined) ?? 0}%`,
    );
    write(`Industry: ${(company.data?.industry as string | undefined) ?? 'general'}`);
    write(`Company size: ${(company.data?.company_size as string | undefined) ?? 'smb'}`);
    write(`Region: ${(company.data?.region as string | undefined) ?? 'global'}`);

    y -= 10;
    write('Security posture summary', 14, true);
    write(`Employees: ${employeeCount}`);
    write(`Average training completion: ${avgTraining}%`);
    write(`MFA coverage: ${mfaCoverage}%`);
    write(`High risk users (>=70): ${highRiskUsers}`);
    write(`Open incidents (30d): ${openIncidents}`);
    write(`Critical incidents (30d): ${criticalIncidents}`);

    y -= 10;
    write('Compliance checks', 14, true);
    write(`GDPR readiness: ${avgTraining >= 60 ? 'Good' : 'Needs improvement'}`);
    write(`Security awareness: ${highRiskUsers <= Math.max(1, Math.floor(employeeCount * 0.25)) ? 'Acceptable' : 'High risk concentration'}`);
    write(`Identity controls: ${mfaCoverage >= 75 ? 'Strong' : 'Weak'}`);

    const bytes = await pdf.save();
    const base64 = btoa(String.fromCharCode(...bytes));

    return json({
      report: reportPayload,
      pdf_base64: base64,
      file_name: `cyberguard_audit_${formatDate(new Date())}.pdf`,
    });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});
