import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';
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
      .select('company_id,role')
      .eq('id', user.id)
      .single();

    if (profile.error || !profile.data) {
      return json({ error: 'Profile not found' }, 404);
    }

    if (profile.data.role !== 'admin') {
      return json({ error: 'Only admins can manage billing' }, 403);
    }

    const subscription = await adminClient
      .from('security_cg_subscriptions')
      .select('stripe_customer_id')
      .eq('company_id', profile.data.company_id)
      .maybeSingle();

    const customerId = subscription.data?.stripe_customer_id;
    if (!customerId) {
      return json({ error: 'No Stripe customer linked to this company' }, 400);
    }

    const appUrl = Deno.env.get('APP_URL') ?? 'http://localhost:3000';

    const portal = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: `${appUrl}/#/subscription`,
    });

    return json({ url: portal.url });
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : 'Unexpected error',
      },
      400,
    );
  }
});
