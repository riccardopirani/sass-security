'use strict';

const nodemailer = require('nodemailer');
const { wrapBrandedEmail } = require('./branding');

let _transport = null;

function getTransport() {
  if (_transport) return _transport;
  _transport = nodemailer.createTransport({
    host:   process.env.SMTP_HOST   ?? 'smtp.register.it',
    port:   Number(process.env.SMTP_PORT ?? 465),
    secure: process.env.SMTP_SECURE !== 'false', // true = SSL/TLS (port 465)
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
    tls: { rejectUnauthorized: false },
  });
  return _transport;
}

/**
 * Send a branded email.
 *
 * @param {object} opts
 * @param {string|string[]} opts.to        - Recipient(s)
 * @param {string}          opts.subject   - Email subject
 * @param {string}          opts.innerHtml - HTML content (wrapped in brand template)
 * @param {string}          [opts.text]    - Plain-text fallback (auto-stripped if omitted)
 * @param {string}          [opts.locale]  - 'en'|'it'|'de'|'fr'|'zh'|'ru'
 * @param {string}          [opts.from]    - Override sender
 * @returns {Promise<{ok: boolean, error?: string, messageId?: string}>}
 */
async function sendEmail({ to, subject, innerHtml, text, locale, from }) {
  if (!to || !subject || !innerHtml) {
    return { ok: false, error: 'Missing required fields: to, subject, innerHtml' };
  }

  const recipients = (Array.isArray(to) ? to : [to]).map(e => e.trim()).filter(Boolean);
  if (recipients.length === 0) return { ok: false, error: 'No valid recipients' };

  const html = wrapBrandedEmail(innerHtml, locale ?? process.env.DEFAULT_LOCALE ?? 'it');
  const plainText = text ?? innerHtml.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();

  try {
    const info = await getTransport().sendMail({
      from:    from ?? process.env.SMTP_FROM ?? `CyberGuard <${process.env.SMTP_USER}>`,
      to:      recipients.join(', '),
      subject,
      text:    plainText,
      html,
    });
    return { ok: true, messageId: info.messageId };
  } catch (err) {
    return { ok: false, error: err.message };
  }
}

module.exports = { sendEmail };
