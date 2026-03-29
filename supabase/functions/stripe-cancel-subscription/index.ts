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
      return json({ error: 'Only admins can cancel subscriptions' }, 403);
    }

    const row = await adminClient
      .from('security_cg_subscriptions')
      .select('stripe_subscription_id')
      .eq('company_id', profile.data.company_id)
      .maybeSingle();

    const subscriptionId = row.data?.stripe_subscription_id as string | null | undefined;
    if (!subscriptionId) {
      return json({ error: 'No Stripe subscription linked to this company' }, 400);
    }

    const updated = await stripe.subscriptions.update(subscriptionId, {
      cancel_at_period_end: true,
    });

    return json({
      cancel_at_period_end: updated.cancel_at_period_end,
      current_period_end: updated.current_period_end,
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
