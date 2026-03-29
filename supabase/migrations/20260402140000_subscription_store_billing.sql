-- Track App Store / Play Store subscriptions separately from Stripe.
alter table public.security_cg_subscriptions
  add column if not exists billing_provider text not null default 'stripe'
    check (billing_provider in ('stripe', 'app_store', 'play_store'));

alter table public.security_cg_subscriptions
  add column if not exists store_original_transaction_id text;
