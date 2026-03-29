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
      return json({ error: 'Only admins can view billing history' }, 403);
    }

    const row = await adminClient
      .from('security_cg_subscriptions')
      .select('stripe_customer_id')
      .eq('company_id', profile.data.company_id)
      .maybeSingle();

    const customerId = row.data?.stripe_customer_id as string | null | undefined;
    if (!customerId) {
      return json({ invoices: [] });
    }

    const list = await stripe.invoices.list({
      customer: customerId,
      limit: 40,
    });

    const invoices = list.data.map((inv) => ({
      id: inv.id,
      number: inv.number,
      created: inv.created,
      amount_paid: inv.amount_paid,
      amount_due: inv.amount_due,
      currency: inv.currency,
      status: inv.status,
      invoice_pdf: inv.invoice_pdf,
      hosted_invoice_url: inv.hosted_invoice_url,
    }));

    return json({ invoices });
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : 'Unexpected error',
      },
      400,
    );
  }
});
