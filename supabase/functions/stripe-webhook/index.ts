import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import type Stripe from 'npm:stripe@14.25.0';

import { handleOptions, json } from '../_shared/cors.ts';
import { type MailLocale, resolveUserMailLocale } from '../_shared/transactional_email.ts';
import { dispatchTransactionalEmail } from '../_shared/transactional_templates.ts';
import { adminClient } from '../_shared/supabase.ts';
import { planFromMetadata, stripe } from '../_shared/stripe.ts';

const intlTag: Record<MailLocale, string> = {
  en: 'en-US',
  it: 'it-IT',
  de: 'de-DE',
  fr: 'fr-FR',
  zh: 'zh-CN',
  ru: 'ru-RU',
};

const formatPeriodEnd = (iso: string | null, locale: MailLocale): string => {
  if (!iso) return '—';
  try {
    return new Intl.DateTimeFormat(intlTag[locale], { dateStyle: 'medium' }).format(new Date(iso));
  } catch {
    return iso;
  }
};

const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET') ?? '';

const toIso = (unixSeconds: number | null | undefined) =>
  unixSeconds ? new Date(unixSeconds * 1000).toISOString() : null;

const fetchExistingByStripe = async (
  stripeCustomerId?: string | null,
  stripeSubscriptionId?: string | null,
) => {
  if (stripeSubscriptionId) {
    const bySub = await adminClient
      .from('security_cg_subscriptions')
      .select('company_id,user_id')
      .eq('stripe_subscription_id', stripeSubscriptionId)
      .maybeSingle();
    if (bySub.data) {
      return bySub.data;
    }
  }

  if (stripeCustomerId) {
    const byCustomer = await adminClient
      .from('security_cg_subscriptions')
      .select('company_id,user_id')
      .eq('stripe_customer_id', stripeCustomerId)
      .maybeSingle();
    if (byCustomer.data) {
      return byCustomer.data;
    }
  }

  return null;
};

const parseLicensedSeats = (raw: string | null | undefined): number | null => {
  if (raw == null || raw === '') return null;
  const n = Math.floor(Number(raw));
  if (!Number.isFinite(n) || n < 1) return null;
  return Math.min(50_000, n);
};

const billingIntervalFromSubscription = (subscription: Stripe.Subscription): 'month' | 'year' => {
  const price = subscription.items?.data?.[0]?.price;
  const interval = price?.recurring?.interval;
  return interval === 'year' ? 'year' : 'month';
};

const upsertSubscription = async (params: {
  companyId: string;
  userId: string;
  customerId: string | null;
  subscriptionId: string | null;
  plan: ReturnType<typeof planFromMetadata>;
  status: string;
  currentPeriodEnd: string | null;
  licensedSeats?: number | null;
  billingInterval?: 'month' | 'year';
}) => {
  await adminClient.from('security_cg_subscriptions').upsert(
    {
      company_id: params.companyId,
      user_id: params.userId,
      stripe_customer_id: params.customerId,
      stripe_subscription_id: params.subscriptionId,
      plan: params.plan,
      status: params.status,
      current_period_end: params.currentPeriodEnd,
      licensed_seats: params.licensedSeats ?? null,
      billing_interval: params.billingInterval ?? 'month',
      updated_at: new Date().toISOString(),
    },
    { onConflict: 'company_id' },
  );
};

const handleCheckoutCompleted = async (session: Stripe.Checkout.Session) => {
  const companyId = session.metadata?.company_id;
  const userId = session.metadata?.user_id;
  if (!companyId || !userId) {
    return;
  }

  const stripeCustomerId = typeof session.customer === 'string' ? session.customer : null;
  const stripeSubscriptionId =
    typeof session.subscription === 'string' ? session.subscription : null;

  let plan = planFromMetadata(session.metadata?.plan);
  let status = 'active';
  let currentPeriodEnd: string | null = null;
  let licensedSeats = parseLicensedSeats(session.metadata?.licensed_users);

  let billingInterval: 'month' | 'year' = 'month';
  if (stripeSubscriptionId) {
    const stripeSubscription = await stripe.subscriptions.retrieve(stripeSubscriptionId, {
      expand: ['items.data.price'],
    });
    plan = planFromMetadata(stripeSubscription.metadata?.plan ?? plan);
    licensedSeats =
      parseLicensedSeats(stripeSubscription.metadata?.licensed_users) ?? licensedSeats;
    status = stripeSubscription.status;
    currentPeriodEnd = toIso(stripeSubscription.current_period_end);
    billingInterval = billingIntervalFromSubscription(stripeSubscription);
  }

  await upsertSubscription({
    companyId,
    userId,
    customerId: stripeCustomerId,
    subscriptionId: stripeSubscriptionId,
    plan,
    status,
    currentPeriodEnd,
    licensedSeats,
    billingInterval,
  });
};

const handleInvoicePaid = async (invoice: Stripe.Invoice) => {
  const stripeSubscriptionId = typeof invoice.subscription === 'string' ? invoice.subscription : null;
  const stripeCustomerId = typeof invoice.customer === 'string' ? invoice.customer : null;

  const existing = await fetchExistingByStripe(stripeCustomerId, stripeSubscriptionId);
  if (!existing) {
    return;
  }

  let plan = planFromMetadata('flex');
  let currentPeriodEnd: string | null = null;
  let licensedSeats: number | null = null;
  let billingInterval: 'month' | 'year' = 'month';

  if (stripeSubscriptionId) {
    const stripeSubscription = await stripe.subscriptions.retrieve(stripeSubscriptionId, {
      expand: ['items.data.price'],
    });
    plan = planFromMetadata(stripeSubscription.metadata?.plan);
    licensedSeats = parseLicensedSeats(stripeSubscription.metadata?.licensed_users);
    currentPeriodEnd = toIso(stripeSubscription.current_period_end);
    billingInterval = billingIntervalFromSubscription(stripeSubscription);
  }

  await upsertSubscription({
    companyId: existing.company_id,
    userId: existing.user_id,
    customerId: stripeCustomerId,
    subscriptionId: stripeSubscriptionId,
    plan,
    status: 'active',
    currentPeriodEnd,
    licensedSeats,
    billingInterval,
  });

  try {
    const locale = await resolveUserMailLocale(existing.user_id);
    const prof = await adminClient
      .from('security_cg_profiles')
      .select('email,name')
      .eq('id', existing.user_id)
      .maybeSingle();
    const email = prof.data?.email?.trim();
    if (email && email.length > 3) {
      const currency = (invoice.currency ?? 'usd').toUpperCase();
      const amountPaid = invoice.amount_paid;
      const amountDisplay =
        amountPaid != null
          ? new Intl.NumberFormat(intlTag[locale], {
              style: 'currency',
              currency,
            }).format(amountPaid / 100)
          : undefined;
      await dispatchTransactionalEmail({
        template: 'subscription_invoice_paid',
        locale,
        to: [email],
        data: {
          userName: prof.data?.name ?? undefined,
          plan: String(plan),
          periodEnd: formatPeriodEnd(currentPeriodEnd, locale),
          amountDisplay,
        },
      });
    }
  } catch {
    /* email is best-effort; subscription state already updated */
  }
};

const handleInvoiceFailed = async (invoice: Stripe.Invoice) => {
  const stripeSubscriptionId = typeof invoice.subscription === 'string' ? invoice.subscription : null;
  const stripeCustomerId = typeof invoice.customer === 'string' ? invoice.customer : null;

  const existing = await fetchExistingByStripe(stripeCustomerId, stripeSubscriptionId);
  if (!existing) {
    return;
  }

  await adminClient
    .from('security_cg_subscriptions')
    .update({ status: 'past_due', updated_at: new Date().toISOString() })
    .eq('company_id', existing.company_id);

  await adminClient.from('security_cg_alerts').insert({
    company_id: existing.company_id,
    severity: 'high',
    title: 'Payment failed',
    message: 'Subscription payment failed. Please update billing details.',
  });

  try {
    const locale = await resolveUserMailLocale(existing.user_id);
    const prof = await adminClient
      .from('security_cg_profiles')
      .select('email,name')
      .eq('id', existing.user_id)
      .maybeSingle();
    const email = prof.data?.email?.trim();
    const reason =
      (invoice as Stripe.Invoice & { last_finalization_error?: { message?: string } })
        .last_finalization_error?.message ?? '';
    if (email && email.length > 3) {
      await dispatchTransactionalEmail({
        template: 'subscription_payment_failed',
        locale,
        to: [email],
        data: {
          userName: prof.data?.name ?? undefined,
          reason: reason || undefined,
        },
      });
    }
  } catch {
    /* best-effort */
  }
};

const handleSubscriptionUpdated = async (subscription: Stripe.Subscription) => {
  const stripeSubscriptionId = subscription.id;
  const stripeCustomerId =
    typeof subscription.customer === 'string' ? subscription.customer : null;

  const existing = await fetchExistingByStripe(stripeCustomerId, stripeSubscriptionId);

  const companyId = subscription.metadata?.company_id ?? existing?.company_id;
  const userId = subscription.metadata?.user_id ?? existing?.user_id;

  if (!companyId || !userId) {
    return;
  }

  const rawPrice = subscription.items?.data?.[0]?.price;
  let subResolved = subscription;
  if (typeof rawPrice === 'string' || !rawPrice?.recurring) {
    subResolved = await stripe.subscriptions.retrieve(subscription.id, {
      expand: ['items.data.price'],
    });
  }

  const plan = planFromMetadata(subscription.metadata?.plan);
  const licensedSeats = parseLicensedSeats(subscription.metadata?.licensed_users);
  const billingInterval = billingIntervalFromSubscription(subResolved);

  await upsertSubscription({
    companyId,
    userId,
    customerId: stripeCustomerId,
    subscriptionId: stripeSubscriptionId,
    plan,
    status: subscription.status,
    currentPeriodEnd: toIso(subscription.current_period_end),
    licensedSeats,
    billingInterval,
  });
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return handleOptions();
  }

  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  if (!webhookSecret) {
    return json({ error: 'Missing STRIPE_WEBHOOK_SECRET' }, 500);
  }

  const signature = req.headers.get('stripe-signature');
  if (!signature) {
    return json({ error: 'Missing stripe-signature header' }, 400);
  }

  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : 'Invalid signature',
      },
      400,
    );
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object as Stripe.Checkout.Session);
        break;
      case 'invoice.paid':
        await handleInvoicePaid(event.data.object as Stripe.Invoice);
        break;
      case 'invoice.payment_failed':
        await handleInvoiceFailed(event.data.object as Stripe.Invoice);
        break;
      case 'customer.subscription.updated':
      case 'customer.subscription.deleted':
        await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
        break;
      default:
        break;
    }

    return json({ received: true });
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : 'Webhook processing error',
      },
      500,
    );
  }
});
