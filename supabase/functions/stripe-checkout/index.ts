import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { corsHeaders, handleOptions, json } from '../_shared/cors.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';
import { priceByPlan, stripe, validatePlan } from '../_shared/stripe.ts';

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
    const plan = validatePlan(payload?.plan);

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

    const priceId = priceByPlan[plan];
    if (!priceId) {
      return json({ error: 'Price ID not configured for plan' }, 500);
    }

    const existing = await adminClient
      .from('security_cg_subscriptions')
      .select('stripe_customer_id')
      .eq('company_id', profile.data.company_id)
      .maybeSingle();

    let customerId = existing.data?.stripe_customer_id ?? null;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: profile.data.email,
        name: profile.data.name,
        metadata: {
          user_id: user.id,
          company_id: profile.data.company_id,
        },
      });
      customerId = customer.id;
    }

    const appUrl = Deno.env.get('APP_URL') ?? 'http://localhost:3000';

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: customerId,
      allow_promotion_codes: true,
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      success_url: `${appUrl}/#/subscription?checkout=success&session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${appUrl}/#/subscription?checkout=cancel`,
      metadata: {
        user_id: user.id,
        company_id: profile.data.company_id,
        plan,
      },
      subscription_data: {
        metadata: {
          user_id: user.id,
          company_id: profile.data.company_id,
          plan,
        },
      },
    });

    await adminClient.from('security_cg_subscriptions').upsert(
      {
        user_id: user.id,
        company_id: profile.data.company_id,
        stripe_customer_id: customerId,
        plan,
        status: 'incomplete',
      },
      { onConflict: 'company_id' },
    );

    return new Response(
      JSON.stringify({
        id: session.id,
        url: session.url,
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
