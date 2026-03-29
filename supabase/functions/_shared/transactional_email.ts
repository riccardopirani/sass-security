/** Shared transactional email: branded HTML layout (Marconi Software S.R.L.) + Resend. */

import { adminClient } from './supabase.ts';

export type MailLocale = 'en' | 'it' | 'de' | 'fr' | 'zh' | 'ru';

const resendApiKey = () => Deno.env.get('RESEND_API_KEY') ?? '';
export const transactionalFromEmail = () =>
  Deno.env.get('TRANSACTIONAL_FROM_EMAIL') ??
  Deno.env.get('ALERTS_FROM_EMAIL') ??
  'CyberGuard <onboarding@resend.dev>';

const marconiLegalName = () =>
  Deno.env.get('MARCONI_LEGAL_NAME') ?? 'Marconi Software S.R.L.';
const marconiAddress = () =>
  Deno.env.get('MARCONI_ADDRESS') ??
  'Via delle Industrie (es.) — IT (aggiornare MARCONI_ADDRESS in Supabase secrets)';
const marconiVat = () =>
  Deno.env.get('MARCONI_VAT') ?? 'P.IVA / C.F.: da configurare (MARCONI_VAT)';
const marconiContactEmail = () =>
  Deno.env.get('MARCONI_CONTACT_EMAIL') ?? 'info@marconisoftware.com';
const marconiWebsite = () =>
  Deno.env.get('MARCONI_WEBSITE') ?? 'https://www.marconisoftware.com';

export const escapeHtml = (value: string) =>
  value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');

export const normalizeMailLocale = (raw: string | undefined | null): MailLocale => {
  const fallback = Deno.env.get('DEFAULT_TRANSACTIONAL_LOCALE');
  const base = (raw ?? fallback ?? 'en').toLowerCase().split(/[-_]/)[0];
  if (base === 'it' || base === 'de' || base === 'fr' || base === 'zh' || base === 'ru') return base;
  return 'en';
};

export async function resolveUserMailLocale(userId: string): Promise<MailLocale> {
  try {
    const { data, error } = await adminClient.auth.admin.getUserById(userId);
    if (error || !data?.user) {
      return normalizeMailLocale(undefined);
    }
    const meta = data.user.user_metadata as Record<string, unknown> | undefined;
    const raw = meta?.locale ?? meta?.language ?? meta?.preferred_locale;
    if (typeof raw === 'string' && raw.length > 0) {
      return normalizeMailLocale(raw);
    }
  } catch {
    /* use default */
  }
  return normalizeMailLocale(undefined);
}

const footerCopy: Record<
  MailLocale,
  { sentBy: string; legalNotice: string; contact: string; privacy: string }
> = {
  en: {
    sentBy: 'This message was sent by CyberGuard on behalf of',
    legalNotice: 'The software and related services are provided by the company below.',
    contact: 'Contact',
    privacy: 'Privacy & data processing according to applicable regulations.',
  },
  it: {
    sentBy: 'Questo messaggio è stato inviato da CyberGuard per conto di',
    legalNotice: 'Software e servizi correlati forniti dalla società indicata sotto.',
    contact: 'Contatto',
    privacy: 'Trattamento dei dati secondo la normativa vigente.',
  },
  de: {
    sentBy: 'Diese Nachricht wurde von CyberGuard im Namen von gesendet',
    legalNotice: 'Software und zugehörige Dienste werden vom unten genannten Unternehmen bereitgestellt.',
    contact: 'Kontakt',
    privacy: 'Datenverarbeitung gemäß geltenden Vorschriften.',
  },
  fr: {
    sentBy: 'Ce message a été envoyé par CyberGuard pour le compte de',
    legalNotice: 'Le logiciel et les services associés sont fournis par la société ci-dessous.',
    contact: 'Contact',
    privacy: 'Traitement des données conformément aux réglementations applicables.',
  },
  zh: {
    sentBy: '本邮件由 CyberGuard 代表以下主体发送',
    legalNotice: '软件及相关服务由下列公司提供。',
    contact: '联系',
    privacy: '依据适用法规处理个人数据。',
  },
  ru: {
    sentBy: 'Это письмо отправлено CyberGuard от имени',
    legalNotice: 'Программное обеспечение и сопутствующие услуги предоставляются компанией ниже.',
    contact: 'Контакт',
    privacy: 'Обработка данных в соответствии с применимыми нормами.',
  },
};

export const wrapBrandedEmail = (innerHtml: string, locale: MailLocale): string => {
  const f = footerCopy[locale];
  const company = escapeHtml(marconiLegalName());
  const address = escapeHtml(marconiAddress());
  const vat = escapeHtml(marconiVat());
  const email = escapeHtml(marconiContactEmail());
  const web = escapeHtml(marconiWebsite());

  return `<!DOCTYPE html>
<html lang="${locale}">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>CyberGuard</title>
</head>
<body style="margin:0;background:#0b1220;font-family:'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:linear-gradient(165deg,#0b1220 0%,#0f1c2e 45%,#0a1628 100%);padding:32px 16px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" style="max-width:560px;background:#ffffff;border-radius:20px;overflow:hidden;box-shadow:0 24px 60px rgba(0,0,0,.35);">
          <tr>
            <td style="background:linear-gradient(120deg,#00ffc2 0%,#0ea5e9 100%);padding:28px 32px;">
              <div style="font-size:13px;letter-spacing:.18em;text-transform:uppercase;color:rgba(15,23,42,.72);font-weight:700;">CyberGuard</div>
              <div style="font-size:22px;font-weight:800;color:#0f172a;line-height:1.25;margin-top:6px;">Security for your team</div>
            </td>
          </tr>
          <tr>
            <td style="padding:28px 32px 12px;font-size:15px;line-height:1.6;color:#1e293b;">
              ${innerHtml}
            </td>
          </tr>
          <tr>
            <td style="padding:8px 32px 28px;font-size:12px;line-height:1.55;color:#64748b;border-top:1px solid #e2e8f0;">
              <p style="margin:0 0 10px;">${escapeHtml(f.sentBy)} <strong>${company}</strong>.</p>
              <p style="margin:0 0 14px;">${escapeHtml(f.legalNotice)}</p>
              <div style="background:#f8fafc;border-radius:14px;padding:16px 18px;margin-top:8px;">
                <div style="font-weight:800;color:#0f172a;font-size:14px;margin-bottom:6px;">${company}</div>
                <div style="color:#475569;">${address}</div>
                <div style="color:#475569;margin-top:4px;">${vat}</div>
                <div style="margin-top:10px;">
                  <span style="color:#64748b;">${escapeHtml(f.contact)}: </span>
                  <a href="mailto:${email}" style="color:#0ea5e9;font-weight:600;">${email}</a>
                  <span style="color:#cbd5e1;margin:0 8px;">|</span>
                  <a href="${web}" style="color:#0ea5e9;font-weight:600;">${web}</a>
                </div>
                <p style="margin:12px 0 0;font-size:11px;color:#94a3b8;">${escapeHtml(f.privacy)}</p>
              </div>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
};

export type SendTransactionalParams = {
  to: string[];
  subject: string;
  innerHtml: string;
  text: string;
  locale: MailLocale;
  from?: string;
};

export const sendTransactionalEmail = async (
  params: SendTransactionalParams,
): Promise<{ ok: boolean; error?: string }> => {
  const key = resendApiKey();
  if (!key) {
    return { ok: false, error: 'RESEND_API_KEY is not configured' };
  }
  const recipients = params.to.map((e) => e.trim().toLowerCase()).filter(Boolean);
  if (recipients.length === 0) {
    return { ok: false, error: 'No recipients' };
  }

  const html = wrapBrandedEmail(params.innerHtml, params.locale);
  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: params.from ?? transactionalFromEmail(),
      to: recipients,
      subject: params.subject,
      text: params.text,
      html,
    }),
  });

  if (!response.ok) {
    const errBody = await response.text();
    return { ok: false, error: errBody };
  }
  return { ok: true };
};
