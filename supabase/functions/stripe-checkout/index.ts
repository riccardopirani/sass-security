import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { corsHeaders, handleOptions, json } from '../_shared/cors.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';
import {
  computeMonthlyUsd,
  monthlyUsdToUnitCents,
  yearlyUsdToUnitCents,
} from '../_shared/pricing.ts';
import { stripeUiLocale } from '../_shared/stripe_locale.ts';
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
    const payload = await req.json();
    const users = Math.min(
      50_000,
      Math.max(1, Math.floor(Number(payload?.users) || 1)),
    );

    const profile = await adminClient
      .from('security_cg_profiles')
      .select('id,company_id,role,email,name')
      .eq('id', user.id)
      .single();

    if (profile.error || !profile.data) {
      return json({ error: 'Profile not found' }, 404);
    }

    if (profile.data.role !== 'admin') {
      return json({ error: 'Only admins can create subscriptions' }, 403);
    }

    const companyId = profile.data.company_id;

    const company = await adminClient
      .from('security_cg_companies')
      .select('risk_score')
      .eq('id', companyId)
      .maybeSingle();

    const riskScore = Number(company.data?.risk_score ?? 0);
    const monthlyUsd = computeMonthlyUsd(users, riskScore);
    const intervalRaw = String(payload?.billing_interval ?? payload?.billingInterval ?? 'month')
      .trim()
      .toLowerCase();
    const billingInterval = intervalRaw === 'year' ? 'year' : 'month';
    const unitCents =
      billingInterval === 'year'
        ? yearlyUsdToUnitCents(monthlyUsd)
        : monthlyUsdToUnitCents(monthlyUsd);

    const existing = await adminClient
      .from('security_cg_subscriptions')
      .select('stripe_customer_id')
      .eq('company_id', companyId)
      .maybeSingle();

    let customerId = existing.data?.stripe_customer_id ?? null;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: profile.data.email,
        name: profile.data.name,
        metadata: {
          user_id: user.id,
          company_id: companyId,
        },
      });
      customerId = customer.id;
    }

    const appUrl = Deno.env.get('APP_URL') ?? 'http://localhost:3000';
    const checkoutLocale = stripeUiLocale(payload?.locale);

    const meta = {
      user_id: user.id,
      company_id: companyId,
      plan: 'flex',
      licensed_users: String(users),
      risk_score: String(Math.round(riskScore)),
      monthly_amount_usd: monthlyUsd.toFixed(2),
      billing_interval: billingInterval,
    };

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: customerId,
      ...(checkoutLocale ? { locale: checkoutLocale } : {}),
      allow_promotion_codes: true,
      line_items: [
        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: `CyberGuard (${users} seats, ${billingInterval === 'year' ? 'annual' : 'monthly'})`,
              metadata: meta,
            },
            recurring: { interval: billingInterval },
            unit_amount: unitCents,
          },
          quantity: 1,
        },
      ],
      success_url: `${appUrl}/#/subscription?checkout=success&session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${appUrl}/#/subscription?checkout=cancel`,
      metadata: meta,
      subscription_data: {
        metadata: meta,
      },
    });

    await adminClient.from('security_cg_subscriptions').upsert(
      {
        user_id: user.id,
        company_id: companyId,
        stripe_customer_id: customerId,
        plan: 'flex',
        licensed_seats: users,
        status: 'incomplete',
        billing_interval: billingInterval,
      },
      { onConflict: 'company_id' },
    );

    return new Response(
      JSON.stringify({
        id: session.id,
        url: session.url,
        monthly_usd: monthlyUsd,
        unit_cents: unitCents,
        billing_interval: billingInterval,
        users,
        risk_score: Math.round(riskScore),
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      },
    );
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : 'Unexpected error',
      },
      400,
    );
  }
});
