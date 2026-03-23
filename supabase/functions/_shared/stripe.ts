import Stripe from 'npm:stripe@14.25.0';

export type Plan = 'starter' | 'pro' | 'business';

const key = Deno.env.get('STRIPE_SECRET_KEY');
if (!key) {
  throw new Error('Missing STRIPE_SECRET_KEY');
}

export const stripe = new Stripe(key, {
  apiVersion: '2023-10-16',
});

const starter = Deno.env.get('STRIPE_PRICE_STARTER') ?? '';
const pro = Deno.env.get('STRIPE_PRICE_PRO') ?? '';
const business = Deno.env.get('STRIPE_PRICE_BUSINESS') ?? '';

export const priceByPlan: Record<Plan, string> = {
  starter,
  pro,
  business,
};

export const planByPrice = (priceId: string | null | undefined): Plan => {
  if (priceId && priceId === priceByPlan.pro) {
    return 'pro';
  }
  if (priceId && priceId === priceByPlan.business) {
    return 'business';
  }
  return 'starter';
};

export const validatePlan = (value: unknown): Plan => {
  if (value === 'starter' || value === 'pro' || value === 'business') {
    return value;
  }
  throw new Error('Invalid plan. Expected starter, pro, or business.');
};
