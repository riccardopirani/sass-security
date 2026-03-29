import Stripe from 'npm:stripe@14.25.0';

const key = Deno.env.get('STRIPE_SECRET_KEY');
if (!key) {
  throw new Error('Missing STRIPE_SECRET_KEY');
}
if (key.startsWith('pk_')) {
  throw new Error(
    'STRIPE_SECRET_KEY must be your Stripe secret key (sk_test_... or sk_live_...), not the publishable key (pk_...). Set it in Supabase Dashboard → Edge Functions → Secrets.',
  );
}

export const stripe = new Stripe(key, {
  apiVersion: '2023-10-16',
});

export type Plan = 'starter' | 'pro' | 'business' | 'flex';

export function planFromMetadata(
  plan: string | null | undefined,
): Plan {
  if (plan === 'starter' || plan === 'pro' || plan === 'business' || plan === 'flex') {
    return plan;
  }
  return 'flex';
}
