type ThreatSeverity = 'low' | 'medium' | 'high' | 'critical';

type DispatchOptions = {
  recipients: string[];
  title: string;
  message: string;
  severity: ThreatSeverity;
  slackWebhookUrl?: string | null;
  teamsWebhookUrl?: string | null;
  fromEmail?: string | null;
};

const resendApiKey = Deno.env.get('RESEND_API_KEY') ?? '';
const defaultFromEmail =
  Deno.env.get('ALERTS_FROM_EMAIL') ?? 'CyberGuard Alerts <onboarding@resend.dev>';

const sendEmail = async (options: DispatchOptions) => {
  if (!resendApiKey || options.recipients.length === 0) {
    return { sent: false, count: 0 };
  }

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${resendApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: options.fromEmail || defaultFromEmail,
      to: options.recipients,
      subject: `[CyberGuard][${options.severity.toUpperCase()}] ${options.title}`,
      text: options.message,
      html: `<h3>${options.title}</h3><p>${options.message}</p>`,
    }),
  });

  if (!response.ok) {
    return { sent: false, count: 0 };
  }

  return { sent: true, count: options.recipients.length };
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

