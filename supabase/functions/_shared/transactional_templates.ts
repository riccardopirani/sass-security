import {
  escapeHtml,
  type MailLocale,
  normalizeMailLocale,
  sendTransactionalEmail,
  type SendTransactionalParams,
} from './transactional_email.ts';

export type TransactionalTemplateId =
  | 'threat_alert'
  | 'security_report'
  | 'subscription_invoice_paid'
  | 'subscription_payment_failed'
  | 'welcome';

type TemplateData = Record<string, string | undefined>;

const greeting = (locale: MailLocale): string => {
  const map: Record<MailLocale, string> = {
    en: 'Hello',
    it: 'Ciao',
    de: 'Hallo',
    fr: 'Bonjour',
    zh: '您好',
    ru: 'Здравствуйте',
  };
  return map[locale];
};

const threatStrings: Record<MailLocale, { subject: string; title: string; severity: string; cta: string }> = {
  en: {
    subject: 'CyberGuard security alert',
    title: 'Security alert',
    severity: 'Severity',
    cta: 'Open your CyberGuard dashboard to review details and take action.',
  },
  it: {
    subject: 'Avviso di sicurezza CyberGuard',
    title: 'Avviso di sicurezza',
    severity: 'Gravità',
    cta: 'Apri la dashboard CyberGuard per i dettagli e le azioni suggerite.',
  },
  de: {
    subject: 'CyberGuard Sicherheitswarnung',
    title: 'Sicherheitswarnung',
    severity: 'Schweregrad',
    cta: 'Öffnen Sie Ihr CyberGuard-Dashboard für Details und empfohlene Schritte.',
  },
  fr: {
    subject: 'Alerte de sécurité CyberGuard',
    title: 'Alerte de sécurité',
    severity: 'Gravité',
    cta: 'Ouvrez votre tableau de bord CyberGuard pour les détails et les actions.',
  },
  zh: {
    subject: 'CyberGuard 安全警报',
    title: '安全警报',
    severity: '严重程度',
    cta: '请打开 CyberGuard 控制台查看详情并采取建议措施。',
  },
  ru: {
    subject: 'Оповещение безопасности CyberGuard',
    title: 'Оповещение безопасности',
    severity: 'Важность',
    cta: 'Откройте панель CyberGuard для деталей и рекомендуемых действий.',
  },
};

const reportStrings: Record<
  MailLocale,
  { subject: string; heading: string; intro: string; summary: string; reporter: string; company: string }
> = {
  en: {
    subject: 'New security incident report',
    heading: 'Security incident report',
    intro: 'A security incident was submitted through your CyberGuard tenant.',
    summary: 'Summary',
    reporter: 'Reporter',
    company: 'Company',
  },
  it: {
    subject: 'Nuova segnalazione di incidente di sicurezza',
    heading: 'Segnalazione incidente di sicurezza',
    intro: 'È stata inviata una nuova segnalazione di incidente di sicurezza dal tenant CyberGuard.',
    summary: 'Riassunto',
    reporter: 'Segnalatore',
    company: 'Azienda',
  },
  de: {
    subject: 'Neuer Sicherheitsvorfall',
    heading: 'Sicherheitsvorfall',
    intro: 'Ein Sicherheitsvorfall wurde über Ihren CyberGuard-Mandanten gemeldet.',
    summary: 'Zusammenfassung',
    reporter: 'Melder',
    company: 'Unternehmen',
  },
  fr: {
    subject: 'Nouveau signalement d’incident de sécurité',
    heading: 'Signalement d’incident',
    intro: 'Un incident de sécurité a été signalé via votre locataire CyberGuard.',
    summary: 'Résumé',
    reporter: 'Signaleur',
    company: 'Entreprise',
  },
  zh: {
    subject: '新的安全事件报告',
    heading: '安全事件报告',
    intro: '您的 CyberGuard 租户提交了一条新的安全事件。',
    summary: '摘要',
    reporter: '报告人',
    company: '公司',
  },
  ru: {
    subject: 'Новое сообщение об инциденте безопасности',
    heading: 'Инцидент безопасности',
    intro: 'Через вашего арендатора CyberGuard отправлен отчёт об инциденте безопасности.',
    summary: 'Краткое описание',
    reporter: 'Автор',
    company: 'Компания',
  },
};

const paidStrings: Record<
  MailLocale,
  { subject: string; body: string; plan: string; until: string; amount: string }
> = {
  en: {
    subject: 'Subscription payment received — thank you',
    body: 'We received your payment. Your subscription remains active.',
    plan: 'Plan',
    until: 'Active until',
    amount: 'Amount',
  },
  it: {
    subject: 'Pagamento ricevuto — grazie',
    body: 'Abbiamo ricevuto il pagamento. Il tuo abbonamento resta attivo.',
    plan: 'Piano',
    until: 'Attivo fino al',
    amount: 'Importo',
  },
  de: {
    subject: 'Zahlung eingegangen — vielen Dank',
    body: 'Wir haben Ihre Zahlung erhalten. Ihr Abonnement bleibt aktiv.',
    plan: 'Tarif',
    until: 'Aktiv bis',
    amount: 'Betrag',
  },
  fr: {
    subject: 'Paiement reçu — merci',
    body: 'Nous avons bien reçu votre paiement. Votre abonnement reste actif.',
    plan: 'Formule',
    until: 'Actif jusqu’au',
    amount: 'Montant',
  },
  zh: {
    subject: '已收到付款 — 谢谢',
    body: '我们已收到您的付款，订阅保持有效。',
    plan: '套餐',
    until: '有效期至',
    amount: '金额',
  },
  ru: {
    subject: 'Платёж получен — спасибо',
    body: 'Мы получили оплату. Ваша подписка остаётся активной.',
    plan: 'Тариф',
    until: 'Активна до',
    amount: 'Сумма',
  },
};

const failedStrings: Record<
  MailLocale,
  { subject: string; body: string; action: string }
> = {
  en: {
    subject: 'Subscription payment failed — action needed',
    body:
      'We could not charge your default payment method. Your access may be limited until the payment succeeds.',
    action: 'Update your billing details in the app (Billing) or contact support.',
  },
  it: {
    subject: 'Pagamento abbonamento non riuscito — intervento richiesto',
    body:
      'Non siamo riusciti ad addebitare il metodo di pagamento predefinito. L’accesso potrebbe essere limitato fino al pagamento.',
    action: 'Aggiorna i dati di fatturazione nell’app (Fatturazione) o contatta il supporto.',
  },
  de: {
    subject: 'Abonnementzahlung fehlgeschlagen — Handlung erforderlich',
    body:
      'Die Belastung Ihrer hinterlegten Zahlungsmethode ist fehlgeschlagen. Der Zugang kann eingeschränkt sein, bis die Zahlung erfolgreich ist.',
    action: 'Aktualisieren Sie Ihre Abrechnungsdaten in der App oder kontaktieren Sie den Support.',
  },
  fr: {
    subject: 'Échec du paiement d’abonnement — action requise',
    body:
      'Nous n’avons pas pu débiter votre moyen de paiement par défaut. L’accès peut être limité tant que le paiement n’a pas réussi.',
    action: 'Mettez à jour la facturation dans l’application ou contactez le support.',
  },
  zh: {
    subject: '订阅扣款失败 — 需要处理',
    body: '我们无法从您的默认支付方式扣款。在支付成功前，访问可能会受限。',
    action: '请在应用内更新账单信息或联系支持。',
  },
  ru: {
    subject: 'Ошибка оплаты подписки — требуется действие',
    body:
      'Не удалось списать средства с выбранного способа оплаты. Доступ может быть ограничен до успешной оплаты.',
    action: 'Обновите платёжные данные в приложении или обратитесь в поддержку.',
  },
};

const welcomeStrings: Record<MailLocale, { subject: string; body: string }> = {
  en: {
    subject: 'Welcome to CyberGuard',
    body: 'Your account is ready. Sign in to complete your security baseline and invite your team.',
  },
  it: {
    subject: 'Benvenuto in CyberGuard',
    body: 'Il tuo account è attivo. Accedi per completare la base di sicurezza e invitare il team.',
  },
  de: {
    subject: 'Willkommen bei CyberGuard',
    body: 'Ihr Konto ist bereit. Melden Sie sich an, um Ihre Sicherheitsbasis abzuschließen.',
  },
  fr: {
    subject: 'Bienvenue sur CyberGuard',
    body: 'Votre compte est prêt. Connectez-vous pour finaliser votre base de sécurité.',
  },
  zh: {
    subject: '欢迎使用 CyberGuard',
    body: '您的账户已就绪。登录以完成安全基线并邀请团队。',
  },
  ru: {
    subject: 'Добро пожаловать в CyberGuard',
    body: 'Ваш аккаунт готов. Войдите, чтобы завершить базовую настройку безопасности.',
  },
};

function buildThreatAlert(
  locale: MailLocale,
  data: TemplateData,
): Pick<SendTransactionalParams, 'subject' | 'innerHtml' | 'text'> {
  const t = threatStrings[locale];
  const title = escapeHtml(data.title ?? '—');
  const message = escapeHtml(data.message ?? '—');
  const severity = escapeHtml(data.severity ?? '—');
  const sev = (data.severity ?? '').toUpperCase();
  return {
    subject: sev ? `${t.subject} (${sev})` : t.subject,
    innerHtml: `
      <h1 style="margin:0 0 16px;font-size:20px;color:#0f172a;">${escapeHtml(t.title)}</h1>
      <p style="margin:0 0 12px;"><strong>${escapeHtml(t.severity)}:</strong> ${severity}</p>
      <p style="margin:0 0 8px;font-size:16px;font-weight:700;color:#0f172a;">${title}</p>
      <p style="margin:0 0 20px;">${message}</p>
      <p style="margin:0;color:#64748b;font-size:13px;">${escapeHtml(t.cta)}</p>`,
    text: `${t.title}\n${t.severity}: ${data.severity ?? ''}\n${data.title ?? ''}\n${data.message ?? ''}\n\n${t.cta}`,
  };
}

function buildSecurityReport(
  locale: MailLocale,
  data: TemplateData,
): Pick<SendTransactionalParams, 'subject' | 'innerHtml' | 'text'> {
  const t = reportStrings[locale];
  const summary = escapeHtml(data.summary ?? '—');
  const reporter = escapeHtml(data.reporter ?? '—');
  const company = escapeHtml(data.company_name ?? data.companyId ?? '—');
  return {
    subject: t.subject,
    innerHtml: `
      <h1 style="margin:0 0 12px;font-size:20px;color:#0f172a;">${escapeHtml(t.heading)}</h1>
      <p style="margin:0 0 18px;">${escapeHtml(t.intro)}</p>
      <p style="margin:0 0 8px;"><strong>${escapeHtml(t.summary)}</strong></p>
      <p style="margin:0 0 16px;white-space:pre-wrap;">${summary}</p>
      <p style="margin:0 0 6px;"><strong>${escapeHtml(t.reporter)}</strong> ${reporter}</p>
      <p style="margin:0;"><strong>${escapeHtml(t.company)}</strong> ${company}</p>`,
    text: `${t.intro}\n${t.summary}: ${data.summary ?? ''}\n${t.reporter}: ${data.reporter ?? ''}\n${t.company}: ${data.company_name ?? data.companyId ?? ''}`,
  };
}

function buildInvoicePaid(
  locale: MailLocale,
  data: TemplateData,
): Pick<SendTransactionalParams, 'subject' | 'innerHtml' | 'text'> {
  const t = paidStrings[locale];
  const name = data.userName?.trim();
  const plan = escapeHtml(data.plan ?? '—');
  const until = escapeHtml(data.periodEnd ?? '—');
  const amount = data.amountDisplay ? escapeHtml(data.amountDisplay) : null;
  const hi = name ? `${greeting(locale)}, ${escapeHtml(name)}` : greeting(locale);
  return {
    subject: t.subject,
    innerHtml: `
      <p style="margin:0 0 16px;font-size:17px;font-weight:700;color:#0f172a;">${escapeHtml(hi)}</p>
      <p style="margin:0 0 18px;">${escapeHtml(t.body)}</p>
      <table role="presentation" cellspacing="0" cellpadding="0" style="width:100%;background:#f8fafc;border-radius:12px;padding:16px;">
        <tr><td style="padding:4px 0;"><strong>${escapeHtml(t.plan)}</strong> ${plan}</td></tr>
        <tr><td style="padding:4px 0;"><strong>${escapeHtml(t.until)}</strong> ${until}</td></tr>
        ${amount ? `<tr><td style="padding:4px 0;"><strong>${escapeHtml(t.amount)}</strong> ${amount}</td></tr>` : ''}
      </table>`,
    text: `${hi}\n${t.body}\n${t.plan}: ${data.plan ?? ''}\n${t.until}: ${data.periodEnd ?? ''}${data.amountDisplay ? `\n${t.amount}: ${data.amountDisplay}` : ''}`,
  };
}

function buildPaymentFailed(
  locale: MailLocale,
  data: TemplateData,
): Pick<SendTransactionalParams, 'subject' | 'innerHtml' | 'text'> {
  const t = failedStrings[locale];
  const name = data.userName?.trim();
  const hi = name ? `${greeting(locale)}, ${escapeHtml(name)}` : greeting(locale);
  return {
    subject: t.subject,
    innerHtml: `
      <p style="margin:0 0 16px;font-size:17px;font-weight:700;color:#b91c1c;">${escapeHtml(hi)}</p>
      <p style="margin:0 0 14px;">${escapeHtml(t.body)}</p>
      ${data.reason ? `<p style="margin:0 0 14px;color:#64748b;font-size:14px;">${escapeHtml(data.reason)}</p>` : ''}
      <p style="margin:0;color:#0f172a;">${escapeHtml(t.action)}</p>`,
    text: `${hi}\n${t.body}\n${data.reason ? `${data.reason}\n` : ''}${t.action}`,
  };
}

function buildWelcome(
  locale: MailLocale,
  data: TemplateData,
): Pick<SendTransactionalParams, 'subject' | 'innerHtml' | 'text'> {
  const t = welcomeStrings[locale];
  const name = data.userName?.trim();
  const hi = name ? `${greeting(locale)}, ${escapeHtml(name)}` : greeting(locale);
  return {
    subject: t.subject,
    innerHtml: `
      <p style="margin:0 0 16px;font-size:17px;font-weight:700;color:#0f172a;">${escapeHtml(hi)}</p>
      <p style="margin:0;">${escapeHtml(t.body)}</p>`,
    text: `${hi}\n${t.body}`,
  };
}

export function renderTransactionalParts(
  template: TransactionalTemplateId,
  localeRaw: string | undefined | null,
  data: TemplateData,
): Pick<SendTransactionalParams, 'subject' | 'innerHtml' | 'text'> & { locale: MailLocale } {
  const locale = normalizeMailLocale(localeRaw);
  switch (template) {
    case 'threat_alert':
      return { locale, ...buildThreatAlert(locale, data) };
    case 'security_report':
      return { locale, ...buildSecurityReport(locale, data) };
    case 'subscription_invoice_paid':
      return { locale, ...buildInvoicePaid(locale, data) };
    case 'subscription_payment_failed':
      return { locale, ...buildPaymentFailed(locale, data) };
    case 'welcome':
      return { locale, ...buildWelcome(locale, data) };
    default:
      return { locale, ...buildWelcome(locale, data) };
  }
}

export async function dispatchTransactionalEmail(options: {
  template: TransactionalTemplateId;
  locale?: string | null;
  to: string[];
  data?: TemplateData;
  from?: string;
}): Promise<{ ok: boolean; error?: string }> {
  const data = options.data ?? {};
  const parts = renderTransactionalParts(options.template, options.locale, data);
  return sendTransactionalEmail({
    to: options.to,
    subject: parts.subject,
    innerHtml: parts.innerHtml,
    text: parts.text,
    locale: parts.locale,
    from: options.from,
  });
}
