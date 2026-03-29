import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
import { computeMonthlyUsd, monthlyUsdToUnitCents } from '../_shared/pricing.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';
import { stripe } from '../_shared/stripe.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return handleOptions();
  }

  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  try {
    const user = await requireUser(req);

    const profile = await adminClient
      .from('security_cg_profiles')
      .select('id,company_id,role')
      .eq('id', user.id)
      .single();

    if (profile.error || !profile.data) {
      return json({ error: 'Profile not found' }, 404);
    }

    if (profile.data.role !== 'admin') {
      return json({ error: 'Only admins can change billing cadence' }, 403);
    }

    const companyId = profile.data.company_id;

    const row = await adminClient
      .from('security_cg_subscriptions')
      .select('stripe_subscription_id,licensed_seats')
      .eq('company_id', companyId)
      .maybeSingle();

    const subscriptionId = row.data?.stripe_subscription_id as string | null | undefined;
    if (!subscriptionId) {
      return json({ error: 'No Stripe subscription linked to this company' }, 400);
    }

    const sub = await stripe.subscriptions.retrieve(subscriptionId, {
      expand: ['items.data.price.product'],
    });

    if (sub.status !== 'active' && sub.status !== 'trialing') {
      return json({ error: 'Subscription must be active or trialing' }, 400);
    }

    const item = sub.items.data[0];
    const currentPrice = item?.price;
    if (!currentPrice?.recurring) {
      return json({ error: 'Invalid subscription price' }, 400);
    }
    if (currentPrice.recurring.interval !== 'year') {
      return json({ error: 'already_monthly', message: 'Billing is already monthly.' }, 400);
    }

    const productRef = currentPrice.product;
    const productId = typeof productRef === 'string' ? productRef : productRef?.id;
    if (!productId) {
      return json({ error: 'Missing product on subscription' }, 400);
    }

    const company = await adminClient
      .from('security_cg_companies')
      .select('risk_score')
      .eq('id', companyId)
      .maybeSingle();
    const riskScore = Number(company.data?.risk_score ?? 0);
    const users = Math.max(1, Number(row.data?.licensed_seats ?? 1));
    const monthlyUsd = computeMonthlyUsd(users, riskScore);
    const unitCents = monthlyUsdToUnitCents(monthlyUsd);

    const monthlyPrice = await stripe.prices.create({
      currency: 'usd',
      product: productId,
      unit_amount: unitCents,
      recurring: { interval: 'month' },
      metadata: {
        company_id: companyId,
        licensed_users: String(users),
        risk_score: String(Math.round(riskScore)),
        billing_interval: 'month',
      },
    });

    const periodEnd = sub.current_period_end;
    const periodStart = sub.current_period_start;

    const existingSchedule = sub.schedule;
    const scheduleId = existingSchedule
      ? typeof existingSchedule === 'string'
        ? existingSchedule
        : existingSchedule.id
      : (await stripe.subscriptionSchedules.create({ from_subscription: subscriptionId })).id;

    await stripe.subscriptionSchedules.update(scheduleId, {
      end_behavior: 'release',
      phases: [
        {
          start_date: periodStart,
          end_date: periodEnd,
          items: [{ price: currentPrice.id, quantity: item.quantity ?? 1 }],
        },
        {
          start_date: periodEnd,
          items: [{ price: monthlyPrice.id, quantity: item.quantity ?? 1 }],
        },
      ],
    });

    const effectiveIso = periodEnd ? new Date(periodEnd * 1000).toISOString() : null;

    await adminClient.from('security_cg_subscription_billing_events').insert({
      company_id: companyId,
      created_by: user.id,
      event_type: 'switch_to_monthly_scheduled',
      details: {
        stripe_schedule_id: scheduleId,
        effective_at: effectiveIso,
        monthly_unit_cents: unitCents,
      },
    });

    return json({
      ok: true,
      effective_at: effectiveIso,
      schedule_id: scheduleId,
    });
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : 'Unexpected error',
      },
      400,
    );
  }
});
