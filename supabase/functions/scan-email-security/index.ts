import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { assertManagerRole, getProfileOrThrow } from '../_shared/roles.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

const phishingKeywords = [
  'urgent',
  'verify now',
  'password reset',
  'invoice attached',
  'wire transfer',
  'confirm account',
  'suspended',
  'click here',
];

const suspiciousDomains = ['secure-login', 'verify-account', 'quick-auth', 'payroll-check'];
const maliciousUrlPattern = /(bit\.ly|tinyurl|t\.co|@|http:\/\/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/i;

const domainFromEmail = (value: string) => {
  const parts = value.toLowerCase().split('@');
  return parts.length === 2 ? parts[1] : '';
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
    const sender = (body?.sender as string | undefined)?.trim() ?? '';
    const subject = (body?.subject as string | undefined)?.trim() ?? '';
    const emailBody = (body?.body as string | undefined)?.trim() ?? '';

    if (!sender || !subject) {
      return json({ error: 'sender and subject are required' }, 400);
    }

    const senderDomain = domainFromEmail(sender);
    const companyDomainHint = domainFromEmail(profile.email);

    const hasSpoofing =
      senderDomain.length > 0 &&
      companyDomainHint.length > 0 &&
      senderDomain !== companyDomainHint &&
      senderDomain.includes(companyDomainHint.replace('.', ''));

    const hasDomainTrap = suspiciousDomains.some((item) => senderDomain.includes(item));
    const hasMaliciousLink = maliciousUrlPattern.test(emailBody);
    const text = `${subject} ${emailBody}`.toLowerCase();
    const hasPhishingLanguage = phishingKeywords.some((keyword) => text.includes(keyword));

    let riskScore = 0;
    if (hasSpoofing || hasDomainTrap) {
      riskScore += 35;
    }
    if (hasMaliciousLink) {
      riskScore += 35;
    }
    if (hasPhishingLanguage) {
      riskScore += 30;
    }
    riskScore = Math.min(100, riskScore);

    const scanInsert = await adminClient
      .from('cg_email_scans')
      .insert({
        company_id: profile.company_id,
        employee_id: employeeId || null,
        sender,
        subject,
        body_excerpt: emailBody.slice(0, 800),
        has_spoofing: hasSpoofing || hasDomainTrap,
        has_malicious_link: hasMaliciousLink,
        has_phishing_language: hasPhishingLanguage,
        risk_score: riskScore,
      })
      .select('id')
      .single();

    if (scanInsert.error || !scanInsert.data) {
      return json({ error: scanInsert.error?.message ?? 'Unable to save scan' }, 400);
    }

    const severity = riskScore >= 80 ? 'critical' : riskScore >= 60 ? 'high' : riskScore >= 30 ? 'medium' : 'low';
    if (riskScore >= 60) {
      await adminClient.from('cg_security_events').insert({
        company_id: profile.company_id,
        employee_id: employeeId || null,
        event_kind: 'email_threat_detected',
        severity,
        details: `Suspicious email from ${sender} with risk score ${riskScore}.`,
      });

      await adminClient.from('cg_alerts').insert({
        company_id: profile.company_id,
        employee_id: employeeId || null,
        severity,
        title: 'Suspicious email detected',
        message: `Subject: ${subject}. Sender: ${sender}. Risk: ${riskScore}/100.`,
        alert_kind: 'email_security',
        channels: ['in_app', 'email', 'slack', 'teams', 'push'],
      });
    }

    if (employeeId && riskScore >= 40) {
      await adminClient.from('cg_behavior_events').insert({
        company_id: profile.company_id,
        employee_id: employeeId,
        event_type: 'suspicious_email_received',
        risk_weight: Math.round(Math.min(100, riskScore * 0.8)),
        metadata: {
          sender,
          subject,
          risk_score: riskScore,
        },
      });
    }

    return json({
      scan_id: scanInsert.data.id,
      sender,
      subject,
      risk_score: riskScore,
      severity,
      flags: {
        spoofing: hasSpoofing || hasDomainTrap,
        malicious_link: hasMaliciousLink,
        phishing_language: hasPhishingLanguage,
      },
    });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      400,
    );
  }
});

