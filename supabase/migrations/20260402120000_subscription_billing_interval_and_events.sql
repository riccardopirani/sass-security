-- Billing cycle (Stripe price recurring interval) + admin-visible billing activity log.
alter table public.security_cg_subscriptions
  add column if not exists billing_interval text not null default 'month'
    check (billing_interval in ('month', 'year'));

create table if not exists public.security_cg_subscription_billing_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.security_cg_companies (id) on delete cascade,
  created_by uuid references public.security_cg_profiles (id) on delete set null,
  event_type text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_subscription_billing_events_company_created
  on public.security_cg_subscription_billing_events (company_id, created_at desc);

alter table public.security_cg_subscription_billing_events enable row level security;

drop policy if exists subscription_billing_events_select_admin
  on public.security_cg_subscription_billing_events;
create policy subscription_billing_events_select_admin
  on public.security_cg_subscription_billing_events
  for select
  using (
    company_id = public.current_company_id()
    and public.is_company_admin()
  );
