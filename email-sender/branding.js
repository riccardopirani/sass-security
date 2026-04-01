'use strict';

/**
 * Branded HTML wrapper — ported from transactional_email.ts.
 * Wraps any inner HTML in the CyberGuard / Marconi Software S.R.L. template.
 */

const LOCALES = ['en', 'it', 'de', 'fr', 'zh', 'ru'];

const footerCopy = {
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

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function normalizeLocale(raw) {
  const base = (raw ?? process.env.DEFAULT_LOCALE ?? 'it').toLowerCase().split(/[-_]/)[0];
  return LOCALES.includes(base) ? base : 'it';
}

function wrapBrandedEmail(innerHtml, locale = 'it') {
  const loc = normalizeLocale(locale);
  const f = footerCopy[loc];

  const company = escapeHtml(process.env.MARCONI_LEGAL_NAME ?? 'Marconi Software S.R.L.');
  const address = escapeHtml(process.env.MARCONI_ADDRESS ?? 'Italia');
  const vat     = escapeHtml(process.env.MARCONI_VAT ?? '');
  const email   = escapeHtml(process.env.MARCONI_CONTACT_EMAIL ?? 'service@marconisoftware.com');
  const web     = escapeHtml(process.env.MARCONI_WEBSITE ?? 'https://www.marconisoftware.com');

  return `<!DOCTYPE html>
<html lang="${loc}">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>CyberGuard</title>
</head>
<body style="margin:0;background:#0b1220;font-family:'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0"
         style="background:linear-gradient(165deg,#0b1220 0%,#0f1c2e 45%,#0a1628 100%);padding:32px 16px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%"
               style="max-width:560px;background:#ffffff;border-radius:20px;overflow:hidden;box-shadow:0 24px 60px rgba(0,0,0,.35);">
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
              <p style="margin:0 0 10px;">${f.sentBy} <strong>${company}</strong>.</p>
              <p style="margin:0 0 14px;">${f.legalNotice}</p>
              <div style="background:#f8fafc;border-radius:14px;padding:16px 18px;margin-top:8px;">
                <div style="font-weight:800;color:#0f172a;font-size:14px;margin-bottom:6px;">${company}</div>
                <div style="color:#475569;">${address}</div>
                <div style="color:#475569;margin-top:4px;">${vat}</div>
                <div style="margin-top:10px;">
                  <span style="color:#64748b;">${f.contact}: </span>
                  <a href="mailto:${email}" style="color:#0ea5e9;font-weight:600;">${email}</a>
                  <span style="color:#cbd5e1;margin:0 8px;">|</span>
                  <a href="${web}" style="color:#0ea5e9;font-weight:600;">${web}</a>
                </div>
                <p style="margin:12px 0 0;font-size:11px;color:#94a3b8;">${f.privacy}</p>
              </div>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

module.exports = { wrapBrandedEmail, normalizeLocale, escapeHtml };
