import { normalizeMailLocale } from './transactional_email.ts';
import { dispatchTransactionalEmail } from './transactional_templates.ts';

type ThreatSeverity = 'low' | 'medium' | 'high' | 'critical';

type DispatchOptions = {
  recipients: string[];
  title: string;
  message: string;
  severity: ThreatSeverity;
  slackWebhookUrl?: string | null;
  teamsWebhookUrl?: string | null;
  fromEmail?: string | null;
  /** BCP-47 or short code; defaults to DEFAULT_TRANSACTIONAL_LOCALE / en */
  locale?: string | null;
};

const sendEmail = async (options: DispatchOptions) => {
  if (options.recipients.length === 0) {
    return { sent: false, count: 0 };
  }

  const locale = normalizeMailLocale(options.locale);
  const result = await dispatchTransactionalEmail({
    template: 'threat_alert',
    locale,
    to: options.recipients,
    from: options.fromEmail ?? undefined,
    data: {
      title: options.title,
      message: options.message,
      severity: options.severity,
    },
  });

  return { sent: result.ok, count: result.ok ? options.recipients.length : 0 };
};

const sendWebhook = async (url: string, title: string, message: string, severity: ThreatSeverity) => {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      text: `CyberGuard ${severity.toUpperCase()} alert: ${title}\n${message}`,
    }),
  });

  return response.ok;
};

export const dispatchThreatNotifications = async (options: DispatchOptions) => {
  const email = await sendEmail(options);

  const slackSent = options.slackWebhookUrl
    ? await sendWebhook(options.slackWebhookUrl, options.title, options.message, options.severity)
    : false;

  const teamsSent = options.teamsWebhookUrl
    ? await sendWebhook(options.teamsWebhookUrl, options.title, options.message, options.severity)
    : false;

  return {
    email_sent: email.sent,
    email_recipients: email.count,
    slack_sent: slackSent,
    teams_sent: teamsSent,
    push_sent: true,
  };
};

export type { MailLocale } from './transactional_email.ts';
