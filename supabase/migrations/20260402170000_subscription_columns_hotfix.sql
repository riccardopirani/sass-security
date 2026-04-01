-- Hotfix: ensure subscription columns exist in all remote environments.
-- Safe to run multiple times.

begin;

alter table public.security_cg_subscriptions
  add column if not exists billing_interval text;

update public.security_cg_subscriptions
set billing_interval = 'month'
where billing_interval is null;

alter table public.security_cg_subscriptions
  alter column billing_interval set default 'month';

alter table public.security_cg_subscriptions
  alter column billing_interval set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.security_cg_subscriptions'::regclass
      and conname = 'security_cg_subscriptions_billing_interval_check'
  ) then
    alter table public.security_cg_subscriptions
      add constraint security_cg_subscriptions_billing_interval_check
      check (billing_interval in ('month', 'year'));
  end if;
end $$;

alter table public.security_cg_subscriptions
  add column if not exists billing_provider text;

update public.security_cg_subscriptions
set billing_provider = 'stripe'
where billing_provider is null;

alter table public.security_cg_subscriptions
  alter column billing_provider set default 'stripe';

alter table public.security_cg_subscriptions
  alter column billing_provider set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.security_cg_subscriptions'::regclass
      and conname = 'security_cg_subscriptions_billing_provider_check'
  ) then
    alter table public.security_cg_subscriptions
      add constraint security_cg_subscriptions_billing_provider_check
      check (billing_provider in ('stripe', 'app_store', 'play_store'));
  end if;
end $$;

alter table public.security_cg_subscriptions
  add column if not exists store_original_transaction_id text;

commit;
