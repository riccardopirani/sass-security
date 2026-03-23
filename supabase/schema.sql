-- CyberGuard core schema
-- Run in Supabase SQL editor or as a migration.

create extension if not exists pgcrypto;

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'app_role' and n.nspname = 'public'
  ) then
    create type public.app_role as enum ('admin', 'employee');
  end if;

  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'alert_severity' and n.nspname = 'public'
  ) then
    create type public.alert_severity as enum ('low', 'medium', 'high');
  end if;

  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'subscription_plan' and n.nspname = 'public'
  ) then
    create type public.subscription_plan as enum ('starter', 'pro', 'business');
  end if;

  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'phishing_event_type' and n.nspname = 'public'
  ) then
    create type public.phishing_event_type as enum ('sent', 'opened', 'clicked');
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'app_role' and e.enumlabel = 'admin'
  ) then
    alter type public.app_role add value 'admin';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'app_role' and e.enumlabel = 'employee'
  ) then
    alter type public.app_role add value 'employee';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'alert_severity' and e.enumlabel = 'low'
  ) then
    alter type public.alert_severity add value 'low';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'alert_severity' and e.enumlabel = 'medium'
  ) then
    alter type public.alert_severity add value 'medium';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'alert_severity' and e.enumlabel = 'high'
  ) then
    alter type public.alert_severity add value 'high';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'subscription_plan' and e.enumlabel = 'starter'
  ) then
    alter type public.subscription_plan add value 'starter';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'subscription_plan' and e.enumlabel = 'pro'
  ) then
    alter type public.subscription_plan add value 'pro';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'subscription_plan' and e.enumlabel = 'business'
  ) then
    alter type public.subscription_plan add value 'business';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'phishing_event_type' and e.enumlabel = 'sent'
  ) then
    alter type public.phishing_event_type add value 'sent';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'phishing_event_type' and e.enumlabel = 'opened'
  ) then
    alter type public.phishing_event_type add value 'opened';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'phishing_event_type' and e.enumlabel = 'clicked'
  ) then
    alter type public.phishing_event_type add value 'clicked';
  end if;
end $$;

create table if not exists public.cg_companies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique default upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8)),
  risk_score int not null default 0 check (risk_score between 0 and 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cg_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  company_id uuid not null references public.cg_companies(id) on delete restrict,
  name text not null,
  email text not null,
  role public.app_role not null default 'employee',
  risk_score int not null default 0 check (risk_score between 0 and 100),
  training_completion int not null default 0 check (training_completion between 0 and 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id, email)
);

create table if not exists public.cg_employees (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  auth_user_id uuid references public.cg_profiles(id) on delete set null,
  name text not null,
  email text not null,
  role public.app_role not null default 'employee',
  risk_score int not null default 0 check (risk_score between 0 and 100),
  training_completion int not null default 0 check (training_completion between 0 and 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id, email)
);

create table if not exists public.cg_phishing_campaigns (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  created_by uuid references public.cg_profiles(id) on delete set null,
  name text not null,
  template text not null,
  status text not null default 'draft' check (status in ('draft', 'scheduled', 'sent', 'completed')),
  sent_count int not null default 0,
  opened_count int not null default 0,
  clicked_count int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cg_phishing_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  campaign_id uuid not null references public.cg_phishing_campaigns(id) on delete cascade,
  employee_id uuid not null references public.cg_employees(id) on delete cascade,
  event_type public.phishing_event_type not null,
  created_at timestamptz not null default now(),
  unique (campaign_id, employee_id, event_type)
);

create table if not exists public.cg_alerts (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  employee_id uuid references public.cg_employees(id) on delete set null,
  severity text not null default 'low' check (severity in ('low', 'medium', 'high')),
  title text not null,
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.cg_training_records (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  employee_id uuid not null references public.cg_employees(id) on delete cascade,
  completion_percent int not null default 0 check (completion_percent between 0 and 100),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (employee_id)
);

create table if not exists public.cg_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.cg_profiles(id) on delete cascade,
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  stripe_customer_id text,
  stripe_subscription_id text,
  plan public.subscription_plan not null default 'starter',
  status text not null default 'inactive',
  current_period_end timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id),
  unique (stripe_subscription_id)
);

create index if not exists idx_cg_profiles_company on public.cg_profiles(company_id);
create index if not exists idx_cg_employees_company on public.cg_employees(company_id);
create index if not exists idx_cg_alerts_company_read on public.cg_alerts(company_id, is_read);
create index if not exists idx_cg_campaigns_company_status on public.cg_phishing_campaigns(company_id, status);
create index if not exists idx_cg_phishing_events_company on public.cg_phishing_events(company_id);
create index if not exists idx_cg_subscriptions_company on public.cg_subscriptions(company_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.current_company_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select company_id from public.cg_profiles where id = auth.uid();
$$;

create or replace function public.is_company_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.cg_profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.clamp_score(value int)
returns int
language sql
immutable
as $$
  select greatest(0, least(100, value));
$$;

create or replace function public.recompute_company_risk(target_company uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  score int;
begin
  select coalesce(
    round(
      avg((e.risk_score * 0.7) + ((100 - e.training_completion) * 0.3))
    )::int,
    0
  )
  into score
  from public.cg_employees e
  where e.company_id = target_company;

  update public.cg_companies
  set risk_score = public.clamp_score(score),
      updated_at = now()
  where id = target_company;

  return public.clamp_score(score);
end;
$$;

create or replace function public.sync_training_to_employee()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.cg_employees
  set training_completion = new.completion_percent,
      updated_at = now()
  where id = new.employee_id;

  perform public.recompute_company_risk(new.company_id);
  return new;
end;
$$;

create or replace function public.apply_phishing_event_effects()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  risk_delta int := 0;
begin
  if new.event_type = 'sent' then
    update public.cg_phishing_campaigns
    set sent_count = sent_count + 1,
        updated_at = now()
    where id = new.campaign_id;
  elsif new.event_type = 'opened' then
    risk_delta := 4;
    update public.cg_phishing_campaigns
    set opened_count = opened_count + 1,
        updated_at = now()
    where id = new.campaign_id;
  elsif new.event_type = 'clicked' then
    risk_delta := 12;
    update public.cg_phishing_campaigns
    set clicked_count = clicked_count + 1,
        updated_at = now()
    where id = new.campaign_id;

    insert into public.cg_alerts (company_id, employee_id, severity, title, message)
    values (
      new.company_id,
      new.employee_id,
      'high',
      'Phishing click detected',
      'An employee clicked a simulated phishing link. Immediate coaching recommended.'
    );
  end if;

  if risk_delta > 0 then
    update public.cg_employees
    set risk_score = public.clamp_score(risk_score + risk_delta),
        updated_at = now()
    where id = new.employee_id;
  end if;

  perform public.recompute_company_risk(new.company_id);
  return new;
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  meta jsonb;
  requested_role public.app_role;
  requested_company_name text;
  requested_company_code text;
  resolved_company_id uuid;
  resolved_name text;
begin
  meta := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  requested_role := coalesce((meta->>'role')::public.app_role, 'admin');
  requested_company_name := coalesce(nullif(meta->>'company_name', ''), 'CyberGuard Company');
  requested_company_code := nullif(meta->>'company_code', '');
  resolved_name := coalesce(nullif(meta->>'name', ''), split_part(new.email, '@', 1));

  if requested_role = 'employee' and requested_company_code is not null then
    select id
    into resolved_company_id
    from public.cg_companies
    where code = upper(requested_company_code)
    limit 1;
  end if;

  if resolved_company_id is null then
    insert into public.cg_companies (name)
    values (requested_company_name)
    returning id into resolved_company_id;

    requested_role := 'admin';
  end if;

  insert into public.cg_profiles (id, company_id, name, email, role)
  values (new.id, resolved_company_id, resolved_name, new.email, requested_role)
  on conflict (id) do nothing;

  insert into public.cg_employees (company_id, auth_user_id, name, email, role)
  values (resolved_company_id, new.id, resolved_name, new.email, requested_role)
  on conflict (company_id, email) do update
    set auth_user_id = excluded.auth_user_id,
        updated_at = now();

  perform public.recompute_company_risk(resolved_company_id);
  return new;
end;
$$;

drop trigger if exists trg_companies_updated_at on public.cg_companies;
create trigger trg_companies_updated_at
before update on public.cg_companies
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_profiles_updated_at on public.cg_profiles;
create trigger trg_profiles_updated_at
before update on public.cg_profiles
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_employees_updated_at on public.cg_employees;
create trigger trg_employees_updated_at
before update on public.cg_employees
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_campaigns_updated_at on public.cg_phishing_campaigns;
create trigger trg_campaigns_updated_at
before update on public.cg_phishing_campaigns
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_training_updated_at on public.cg_training_records;
create trigger trg_training_updated_at
before update on public.cg_training_records
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_subscriptions_updated_at on public.cg_subscriptions;
create trigger trg_subscriptions_updated_at
before update on public.cg_subscriptions
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_training_sync on public.cg_training_records;
create trigger trg_training_sync
after insert or update on public.cg_training_records
for each row
execute procedure public.sync_training_to_employee();

drop trigger if exists trg_phishing_event_effects on public.cg_phishing_events;
create trigger trg_phishing_event_effects
after insert on public.cg_phishing_events
for each row
execute procedure public.apply_phishing_event_effects();

drop trigger if exists trg_on_auth_user_created on auth.users;
create trigger trg_on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();

alter table public.cg_companies enable row level security;
alter table public.cg_profiles enable row level security;
alter table public.cg_employees enable row level security;
alter table public.cg_phishing_campaigns enable row level security;
alter table public.cg_phishing_events enable row level security;
alter table public.cg_alerts enable row level security;
alter table public.cg_training_records enable row level security;
alter table public.cg_subscriptions enable row level security;

drop policy if exists companies_select_same_company on public.cg_companies;
create policy companies_select_same_company
on public.cg_companies
for select
using (id = public.current_company_id());

drop policy if exists companies_update_admin on public.cg_companies;
create policy companies_update_admin
on public.cg_companies
for update
using (id = public.current_company_id() and public.is_company_admin())
with check (id = public.current_company_id() and public.is_company_admin());

drop policy if exists profiles_select_company on public.cg_profiles;
create policy profiles_select_company
on public.cg_profiles
for select
using (company_id = public.current_company_id());

drop policy if exists profiles_update_self_or_admin on public.cg_profiles;
create policy profiles_update_self_or_admin
on public.cg_profiles
for update
using (
  id = auth.uid()
  or (company_id = public.current_company_id() and public.is_company_admin())
)
with check (
  id = auth.uid()
  or (company_id = public.current_company_id() and public.is_company_admin())
);

drop policy if exists employees_select_company on public.cg_employees;
create policy employees_select_company
on public.cg_employees
for select
using (company_id = public.current_company_id());

drop policy if exists employees_write_admin on public.cg_employees;
create policy employees_write_admin
on public.cg_employees
for all
using (company_id = public.current_company_id() and public.is_company_admin())
with check (company_id = public.current_company_id() and public.is_company_admin());

drop policy if exists campaigns_select_company on public.cg_phishing_campaigns;
create policy campaigns_select_company
on public.cg_phishing_campaigns
for select
using (company_id = public.current_company_id());

drop policy if exists campaigns_write_admin on public.cg_phishing_campaigns;
create policy campaigns_write_admin
on public.cg_phishing_campaigns
for all
using (company_id = public.current_company_id() and public.is_company_admin())
with check (company_id = public.current_company_id() and public.is_company_admin());

drop policy if exists events_select_company on public.cg_phishing_events;
create policy events_select_company
on public.cg_phishing_events
for select
using (company_id = public.current_company_id());

drop policy if exists events_write_admin on public.cg_phishing_events;
create policy events_write_admin
on public.cg_phishing_events
for all
using (company_id = public.current_company_id() and public.is_company_admin())
with check (company_id = public.current_company_id() and public.is_company_admin());

drop policy if exists alerts_select_company on public.cg_alerts;
create policy alerts_select_company
on public.cg_alerts
for select
using (company_id = public.current_company_id());

drop policy if exists alerts_update_company on public.cg_alerts;
create policy alerts_update_company
on public.cg_alerts
for update
using (company_id = public.current_company_id())
with check (company_id = public.current_company_id());

drop policy if exists alerts_insert_admin on public.cg_alerts;
create policy alerts_insert_admin
on public.cg_alerts
for insert
with check (company_id = public.current_company_id() and public.is_company_admin());

drop policy if exists training_select_company on public.cg_training_records;
create policy training_select_company
on public.cg_training_records
for select
using (company_id = public.current_company_id());

drop policy if exists training_write_admin on public.cg_training_records;
create policy training_write_admin
on public.cg_training_records
for all
using (company_id = public.current_company_id() and public.is_company_admin())
with check (company_id = public.current_company_id() and public.is_company_admin());

drop policy if exists subscriptions_select_company on public.cg_subscriptions;
create policy subscriptions_select_company
on public.cg_subscriptions
for select
using (company_id = public.current_company_id());

drop policy if exists subscriptions_write_admin on public.cg_subscriptions;
create policy subscriptions_write_admin
on public.cg_subscriptions
for all
using (company_id = public.current_company_id() and public.is_company_admin())
with check (company_id = public.current_company_id() and public.is_company_admin());

-- Realtime support for alerts stream.
do $$
begin
  if to_regclass('public.cg_alerts') is not null then
    alter publication supabase_realtime add table public.cg_alerts;
  end if;
exception
  when duplicate_object then null;
  when undefined_table then null;
end $$;
