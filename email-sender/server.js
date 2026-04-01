'use strict';

require('dotenv').config();

const express = require('express');
const { sendEmail } = require('./mailer');

const app  = express();
const PORT = process.env.PORT ?? 3000;

app.use(express.json({ limit: '2mb' }));

/**
 * POST /send
 *
 * Body (JSON):
 * {
 *   "to":        "cliente@example.com",   // required — or array
 *   "subject":   "Oggetto",               // required
 *   "innerHtml": "<p>Testo HTML...</p>",  // required — wrapped in brand template
 *   "text":      "Testo plain",           // optional
 *   "locale":    "it",                    // optional: en|it|de|fr|zh|ru
 *   "from":      "Nome <addr@ex.com>"     // optional override
 * }
 */
app.post('/send', async (req, res) => {
  const { to, subject, innerHtml, text, locale, from } = req.body ?? {};

  if (!to || !subject || !innerHtml) {
    return res.status(400).json({ ok: false, error: 'Required: to, subject, innerHtml' });
  }

  console.log(`[email] → ${JSON.stringify(to)} | ${subject}`);

  const result = await sendEmail({ to, subject, innerHtml, text, locale, from });

  if (result.ok) {
    console.log(`[email] ✓ sent — messageId: ${result.messageId}`);
    return res.json({ ok: true, messageId: result.messageId });
  } else {
    console.error(`[email] ✗ failed — ${result.error}`);
    return res.status(502).json({ ok: false, error: result.error });
  }
});

/** GET /health — quick liveness check */
app.get('/health', (_req, res) => res.json({ ok: true }));

app.listen(PORT, () => {
  console.log(`Email sender running on http://localhost:${PORT}`);
  console.log(`  SMTP: ${process.env.SMTP_USER} @ ${process.env.SMTP_HOST}:${process.env.SMTP_PORT}`);
});
