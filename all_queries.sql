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


-- Rename existing tables to use the cg_ prefix.
-- Safe to run multiple times thanks to IF EXISTS checks.

begin;

alter table if exists public.companies rename to cg_companies;
alter table if exists public.profiles rename to cg_profiles;
alter table if exists public.employees rename to cg_employees;
alter table if exists public.phishing_campaigns rename to cg_phishing_campaigns;
alter table if exists public.phishing_events rename to cg_phishing_events;
alter table if exists public.alerts rename to cg_alerts;
alter table if exists public.training_records rename to cg_training_records;
alter table if exists public.subscriptions rename to cg_subscriptions;

-- Keep index names consistent with the new table prefix.
alter index if exists public.idx_profiles_company
  rename to idx_cg_profiles_company;
alter index if exists public.idx_employees_company
  rename to idx_cg_employees_company;
alter index if exists public.idx_alerts_company_read
  rename to idx_cg_alerts_company_read;
alter index if exists public.idx_campaigns_company_status
  rename to idx_cg_campaigns_company_status;
alter index if exists public.idx_phishing_events_company
  rename to idx_cg_phishing_events_company;
alter index if exists public.idx_subscriptions_company
  rename to idx_cg_subscriptions_company;

do $$
begin
  alter publication supabase_realtime drop table public.alerts;
exception
  when undefined_table then null;
  when invalid_parameter_value then null;
end $$;

do $$
begin
  if to_regclass('public.cg_alerts') is not null then
    alter publication supabase_realtime add table public.cg_alerts;
  end if;
exception
  when duplicate_object then null;
  when undefined_table then null;
end $$;

commit;


-- Enterprise platform MVP: full feature foundation
-- Date: 2026-03-23

begin;

do $$
begin
  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'app_role' and e.enumlabel = 'security_manager'
  ) then
    alter type public.app_role add value 'security_manager';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'app_role' and e.enumlabel = 'auditor'
  ) then
    alter type public.app_role add value 'auditor';
  end if;

  if not exists (
    select 1
    from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'phishing_event_type' and e.enumlabel = 'credential_submitted'
  ) then
    alter type public.phishing_event_type add value 'credential_submitted';
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_companies'
      and column_name = 'industry'
  ) then
    alter table public.cg_companies add column industry text not null default 'general';
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_companies'
      and column_name = 'company_size'
  ) then
    alter table public.cg_companies add column company_size text not null default 'smb';
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_companies'
      and column_name = 'region'
  ) then
    alter table public.cg_companies add column region text not null default 'global';
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_companies'
      and column_name = 'benchmark_percentile'
  ) then
    alter table public.cg_companies add column benchmark_percentile int not null default 0 check (benchmark_percentile between 0 and 100);
  end if;
end $$;

create table if not exists public.cg_departments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id, name)
);

create table if not exists public.cg_teams (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  department_id uuid references public.cg_departments(id) on delete set null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id, name)
);

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_employees'
      and column_name = 'department_id'
  ) then
    alter table public.cg_employees
      add column department_id uuid references public.cg_departments(id) on delete set null;
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_employees'
      and column_name = 'team_id'
  ) then
    alter table public.cg_employees
      add column team_id uuid references public.cg_teams(id) on delete set null;
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_employees'
      and column_name = 'password_behavior_score'
  ) then
    alter table public.cg_employees add column password_behavior_score int not null default 30 check (password_behavior_score between 0 and 100);
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_employees'
      and column_name = 'incident_history_score'
  ) then
    alter table public.cg_employees add column incident_history_score int not null default 0 check (incident_history_score between 0 and 100);
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_employees'
      and column_name = 'device_compliance_score'
  ) then
    alter table public.cg_employees add column device_compliance_score int not null default 25 check (device_compliance_score between 0 and 100);
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_employees'
      and column_name = 'behavior_risk_score'
  ) then
    alter table public.cg_employees add column behavior_risk_score int not null default 15 check (behavior_risk_score between 0 and 100);
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_employees'
      and column_name = 'last_password_change_at'
  ) then
    alter table public.cg_employees add column last_password_change_at timestamptz;
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_employees'
      and column_name = 'mfa_enabled'
  ) then
    alter table public.cg_employees add column mfa_enabled boolean not null default false;
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_employees'
      and column_name = 'force_mfa'
  ) then
    alter table public.cg_employees add column force_mfa boolean not null default false;
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_phishing_campaigns'
      and column_name = 'credential_submitted_count'
  ) then
    alter table public.cg_phishing_campaigns add column credential_submitted_count int not null default 0;
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_phishing_campaigns'
      and column_name = 'template_variant_a'
  ) then
    alter table public.cg_phishing_campaigns add column template_variant_a text;
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_phishing_campaigns'
      and column_name = 'template_variant_b'
  ) then
    alter table public.cg_phishing_campaigns add column template_variant_b text;
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_phishing_campaigns'
      and column_name = 'ab_test_enabled'
  ) then
    alter table public.cg_phishing_campaigns add column ab_test_enabled boolean not null default false;
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_phishing_campaigns'
      and column_name = 'campaign_mode'
  ) then
    alter table public.cg_phishing_campaigns add column campaign_mode text not null default 'manual' check (campaign_mode in ('manual', 'automatic'));
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_phishing_campaigns'
      and column_name = 'generated_by_ai'
  ) then
    alter table public.cg_phishing_campaigns add column generated_by_ai boolean not null default false;
  end if;
end $$;

alter table public.cg_alerts drop constraint if exists cg_alerts_severity_check;
alter table public.cg_alerts add constraint cg_alerts_severity_check check (severity in ('low', 'medium', 'high', 'critical'));

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_alerts'
      and column_name = 'alert_kind'
  ) then
    alter table public.cg_alerts add column alert_kind text not null default 'generic';
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_alerts'
      and column_name = 'channels'
  ) then
    alter table public.cg_alerts add column channels text[] not null default array['in_app']::text[];
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'cg_alerts'
      and column_name = 'metadata'
  ) then
    alter table public.cg_alerts add column metadata jsonb not null default '{}'::jsonb;
  end if;
end $$;

create table if not exists public.cg_incidents (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  employee_id uuid references public.cg_employees(id) on delete set null,
  incident_type text not null,
  severity text not null default 'medium' check (severity in ('low', 'medium', 'high', 'critical')),
  status text not null default 'open' check (status in ('open', 'mitigated', 'closed')),
  source text not null default 'system',
  details text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cg_behavior_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  employee_id uuid not null references public.cg_employees(id) on delete cascade,
  event_type text not null,
  risk_weight int not null default 5 check (risk_weight between 0 and 100),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.cg_training_modules (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.cg_companies(id) on delete cascade,
  title text not null,
  topic text not null default 'general',
  estimated_minutes int not null default 5 check (estimated_minutes between 2 and 30),
  is_active boolean not null default true,
  content_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cg_training_assignments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  employee_id uuid not null references public.cg_employees(id) on delete cascade,
  module_id uuid references public.cg_training_modules(id) on delete set null,
  trigger_reason text not null default 'manual',
  status text not null default 'assigned' check (status in ('assigned', 'in_progress', 'completed')),
  due_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cg_attack_library (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.cg_companies(id) on delete cascade,
  category text not null,
  name text not null,
  subject_line text not null,
  body_template text not null,
  created_by uuid references public.cg_profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cg_security_events (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  employee_id uuid references public.cg_employees(id) on delete set null,
  event_kind text not null,
  severity text not null default 'medium' check (severity in ('low', 'medium', 'high', 'critical')),
  status text not null default 'open' check (status in ('open', 'resolved')),
  details text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cg_notification_channels (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  email_enabled boolean not null default true,
  slack_webhook_url text,
  teams_webhook_url text,
  push_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id)
);

create table if not exists public.cg_remediation_actions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  employee_id uuid references public.cg_employees(id) on delete set null,
  incident_id uuid references public.cg_incidents(id) on delete set null,
  action_type text not null check (action_type in ('reset_password', 'block_account', 'force_mfa', 'isolate_user')),
  status text not null default 'suggested' check (status in ('suggested', 'approved', 'executed', 'dismissed')),
  reason text not null default '',
  created_by uuid references public.cg_profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cg_email_scans (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  employee_id uuid references public.cg_employees(id) on delete set null,
  sender text not null default '',
  subject text not null default '',
  body_excerpt text not null default '',
  has_spoofing boolean not null default false,
  has_malicious_link boolean not null default false,
  has_phishing_language boolean not null default false,
  risk_score int not null default 0 check (risk_score between 0 and 100),
  created_at timestamptz not null default now()
);

create table if not exists public.cg_company_score_snapshots (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.cg_companies(id) on delete cascade,
  snapshot_date date not null default current_date,
  risk_score int not null default 0 check (risk_score between 0 and 100),
  created_at timestamptz not null default now(),
  unique (company_id, snapshot_date)
);

create index if not exists idx_cg_employees_company_role on public.cg_employees(company_id, role);
create index if not exists idx_cg_employees_company_department on public.cg_employees(company_id, department_id);
create index if not exists idx_cg_incidents_company_status on public.cg_incidents(company_id, status);
create index if not exists idx_cg_security_events_company_status on public.cg_security_events(company_id, status);
create index if not exists idx_cg_behavior_events_employee_created on public.cg_behavior_events(employee_id, created_at desc);
create index if not exists idx_cg_training_assignments_employee_status on public.cg_training_assignments(employee_id, status);
create index if not exists idx_cg_email_scans_company_created on public.cg_email_scans(company_id, created_at desc);
create index if not exists idx_cg_company_snapshots_company_date on public.cg_company_score_snapshots(company_id, snapshot_date desc);

create or replace function public.is_company_manager()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.cg_profiles
    where id = auth.uid()
      and role in ('admin', 'security_manager')
  );
$$;

create or replace function public.is_company_auditor()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.cg_profiles
    where id = auth.uid()
      and role = 'auditor'
  );
$$;

create or replace function public.refresh_company_benchmark(target_company uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  own_risk int := 0;
  safer_count int := 0;
  peer_count int := 0;
  percentile int := 0;
begin
  select c.risk_score
  into own_risk
  from public.cg_companies c
  where c.id = target_company;

  if own_risk is null then
    return 0;
  end if;

  select count(*)
  into peer_count
  from public.cg_companies p;

  if peer_count = 0 then
    percentile := 0;
  else
    select count(*)
    into safer_count
    from public.cg_companies p
    where p.risk_score >= own_risk;

    percentile := round((safer_count::numeric / peer_count::numeric) * 100)::int;
  end if;

  update public.cg_companies
  set benchmark_percentile = greatest(0, least(100, percentile)),
      updated_at = now()
  where id = target_company;

  return greatest(0, least(100, percentile));
end;
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
  select coalesce(round(avg(e.risk_score))::int, 0)
  into score
  from public.cg_employees e
  where e.company_id = target_company;

  update public.cg_companies
  set risk_score = public.clamp_score(score),
      updated_at = now()
  where id = target_company;

  insert into public.cg_company_score_snapshots (company_id, snapshot_date, risk_score)
  values (target_company, current_date, public.clamp_score(score))
  on conflict (company_id, snapshot_date) do update
    set risk_score = excluded.risk_score;

  perform public.refresh_company_benchmark(target_company);

  return public.clamp_score(score);
end;
$$;

create or replace function public.assign_adaptive_training(
  target_company uuid,
  target_employee uuid,
  reason text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  module_id uuid;
  assignment_id uuid;
begin
  select id
  into module_id
  from public.cg_training_modules m
  where (m.company_id = target_company or m.company_id is null)
    and m.is_active = true
    and (m.topic = reason or m.topic = 'general')
  order by case when m.topic = reason then 0 else 1 end, m.created_at asc
  limit 1;

  if module_id is null then
    insert into public.cg_training_modules (company_id, title, topic, estimated_minutes, content_url)
    values (
      null,
      'Rapid Security Recovery',
      'general',
      5,
      'https://owasp.org/www-project-top-ten/'
    )
    returning id into module_id;
  end if;

  select a.id
  into assignment_id
  from public.cg_training_assignments a
  where a.company_id = target_company
    and a.employee_id = target_employee
    and a.status in ('assigned', 'in_progress')
    and a.trigger_reason = reason
  order by a.created_at desc
  limit 1;

  if assignment_id is null then
    insert into public.cg_training_assignments (
      company_id,
      employee_id,
      module_id,
      trigger_reason,
      status,
      due_at
    )
    values (
      target_company,
      target_employee,
      module_id,
      reason,
      'assigned',
      now() + interval '7 days'
    )
    returning id into assignment_id;
  end if;

  return assignment_id;
end;
$$;

create or replace function public.recompute_employee_risk(target_employee uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  emp public.cg_employees%rowtype;
  phishing_risk int := 0;
  training_gap int := 0;
  incident_risk int := 0;
  mfa_penalty int := 0;
  final_score int := 0;
begin
  select *
  into emp
  from public.cg_employees
  where id = target_employee;

  if emp.id is null then
    return 0;
  end if;

  select coalesce(
    least(
      100,
      sum(
        case
          when pe.event_type = 'clicked' then 15
          when pe.event_type = 'credential_submitted' then 26
          when pe.event_type = 'opened' then 4
          else 0
        end
      )
    ),
    0
  )
  into phishing_risk
  from public.cg_phishing_events pe
  where pe.employee_id = target_employee
    and pe.created_at >= now() - interval '90 days';

  select coalesce(
    least(
      100,
      sum(
        case
          when i.severity = 'critical' then 30
          when i.severity = 'high' then 18
          when i.severity = 'medium' then 10
          else 4
        end
      )
    ),
    0
  )
  into incident_risk
  from public.cg_incidents i
  where i.employee_id = target_employee
    and i.created_at >= now() - interval '180 days';

  training_gap := greatest(0, 100 - emp.training_completion);
  mfa_penalty := case when emp.mfa_enabled then 0 else 8 end;

  final_score := round(
    (phishing_risk * 0.28) +
    (emp.password_behavior_score * 0.18) +
    (training_gap * 0.16) +
    (greatest(emp.incident_history_score, incident_risk) * 0.14) +
    (emp.device_compliance_score * 0.10) +
    (emp.behavior_risk_score * 0.10) +
    (mfa_penalty * 0.04)
  )::int;

  update public.cg_employees
  set risk_score = public.clamp_score(final_score),
      incident_history_score = greatest(emp.incident_history_score, incident_risk),
      updated_at = now()
  where id = target_employee;

  perform public.recompute_company_risk(emp.company_id);

  return public.clamp_score(final_score);
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

  perform public.recompute_employee_risk(new.employee_id);
  return new;
end;
$$;

create or replace function public.sync_behavior_to_employee()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  behavior_score int;
begin
  select coalesce(
    least(100, round(avg(be.risk_weight))::int),
    0
  )
  into behavior_score
  from public.cg_behavior_events be
  where be.employee_id = new.employee_id
    and be.created_at >= now() - interval '30 days';

  update public.cg_employees
  set behavior_risk_score = behavior_score,
      updated_at = now()
  where id = new.employee_id;

  perform public.recompute_employee_risk(new.employee_id);
  return new;
end;
$$;

create or replace function public.sync_incidents_to_employee()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_employee uuid;
begin
  target_employee := coalesce(new.employee_id, old.employee_id);

  if target_employee is null then
    return coalesce(new, old);
  end if;

  perform public.recompute_employee_risk(target_employee);
  return coalesce(new, old);
end;
$$;

create or replace function public.recompute_employee_risk_on_factor_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.recompute_employee_risk(new.id);
  return new;
end;
$$;

create or replace function public.apply_phishing_event_effects()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.event_type = 'sent' then
    update public.cg_phishing_campaigns
    set sent_count = sent_count + 1,
        updated_at = now()
    where id = new.campaign_id;
  elsif new.event_type = 'opened' then
    update public.cg_phishing_campaigns
    set opened_count = opened_count + 1,
        updated_at = now()
    where id = new.campaign_id;
  elsif new.event_type = 'clicked' then
    update public.cg_phishing_campaigns
    set clicked_count = clicked_count + 1,
        updated_at = now()
    where id = new.campaign_id;

    insert into public.cg_alerts (company_id, employee_id, severity, title, message, alert_kind, channels)
    values (
      new.company_id,
      new.employee_id,
      'high',
      'Phishing click detected',
      'An employee clicked a simulated phishing link. Adaptive training assigned.',
      'risky_behavior',
      array['in_app', 'email']::text[]
    );

    insert into public.cg_incidents (company_id, employee_id, incident_type, severity, source, details)
    values (
      new.company_id,
      new.employee_id,
      'phishing_click',
      'high',
      'simulation',
      'User clicked phishing simulation link.'
    );

    perform public.assign_adaptive_training(new.company_id, new.employee_id, 'phishing_click');
  elsif new.event_type = 'credential_submitted' then
    update public.cg_phishing_campaigns
    set credential_submitted_count = credential_submitted_count + 1,
        updated_at = now()
    where id = new.campaign_id;

    insert into public.cg_alerts (company_id, employee_id, severity, title, message, alert_kind, channels)
    values (
      new.company_id,
      new.employee_id,
      'critical',
      'Credential submission detected',
      'Credentials submitted in phishing simulation. Immediate remediation required.',
      'credential_compromise',
      array['in_app', 'email', 'slack', 'teams', 'push']::text[]
    );

    insert into public.cg_incidents (company_id, employee_id, incident_type, severity, source, details)
    values (
      new.company_id,
      new.employee_id,
      'credential_submitted',
      'critical',
      'simulation',
      'User submitted credentials during phishing simulation.'
    );

    perform public.assign_adaptive_training(new.company_id, new.employee_id, 'credential_submitted');
  end if;

  perform public.recompute_employee_risk(new.employee_id);
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
  requested_role_text text;
  requested_role public.app_role;
  requested_company_name text;
  requested_company_code text;
  resolved_company_id uuid;
  resolved_name text;
begin
  meta := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  requested_role_text := lower(coalesce(meta->>'role', 'admin'));
  requested_company_name := coalesce(nullif(meta->>'company_name', ''), 'CyberGuard Company');
  requested_company_code := nullif(meta->>'company_code', '');
  resolved_name := coalesce(nullif(meta->>'name', ''), split_part(new.email, '@', 1));

  requested_role := case
    when requested_role_text in ('admin', 'employee', 'security_manager', 'auditor')
      then requested_role_text::public.app_role
    else 'admin'::public.app_role
  end;

  if requested_role in ('employee', 'security_manager', 'auditor') and requested_company_code is not null then
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
        role = excluded.role,
        updated_at = now();

  perform public.recompute_company_risk(resolved_company_id);
  return new;
end;
$$;

drop trigger if exists trg_behavior_sync on public.cg_behavior_events;
create trigger trg_behavior_sync
after insert on public.cg_behavior_events
for each row
execute procedure public.sync_behavior_to_employee();

drop trigger if exists trg_incident_sync on public.cg_incidents;
create trigger trg_incident_sync
after insert or update or delete on public.cg_incidents
for each row
execute procedure public.sync_incidents_to_employee();

drop trigger if exists trg_employee_factor_recompute on public.cg_employees;
create trigger trg_employee_factor_recompute
after update of password_behavior_score, training_completion, incident_history_score, device_compliance_score, behavior_risk_score, mfa_enabled
on public.cg_employees
for each row
execute procedure public.recompute_employee_risk_on_factor_change();

drop policy if exists employees_write_admin on public.cg_employees;
create policy employees_write_admin
on public.cg_employees
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists campaigns_write_admin on public.cg_phishing_campaigns;
create policy campaigns_write_admin
on public.cg_phishing_campaigns
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists events_write_admin on public.cg_phishing_events;
create policy events_write_admin
on public.cg_phishing_events
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists alerts_insert_admin on public.cg_alerts;
create policy alerts_insert_admin
on public.cg_alerts
for insert
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists training_write_admin on public.cg_training_records;
create policy training_write_admin
on public.cg_training_records
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists subscriptions_write_admin on public.cg_subscriptions;
create policy subscriptions_write_admin
on public.cg_subscriptions
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

alter table public.cg_departments enable row level security;
alter table public.cg_teams enable row level security;
alter table public.cg_incidents enable row level security;
alter table public.cg_behavior_events enable row level security;
alter table public.cg_training_modules enable row level security;
alter table public.cg_training_assignments enable row level security;
alter table public.cg_attack_library enable row level security;
alter table public.cg_security_events enable row level security;
alter table public.cg_notification_channels enable row level security;
alter table public.cg_remediation_actions enable row level security;
alter table public.cg_email_scans enable row level security;
alter table public.cg_company_score_snapshots enable row level security;

drop policy if exists departments_select_company on public.cg_departments;
create policy departments_select_company
on public.cg_departments
for select
using (company_id = public.current_company_id());

drop policy if exists departments_write_manager on public.cg_departments;
create policy departments_write_manager
on public.cg_departments
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists teams_select_company on public.cg_teams;
create policy teams_select_company
on public.cg_teams
for select
using (company_id = public.current_company_id());

drop policy if exists teams_write_manager on public.cg_teams;
create policy teams_write_manager
on public.cg_teams
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists incidents_select_company on public.cg_incidents;
create policy incidents_select_company
on public.cg_incidents
for select
using (company_id = public.current_company_id());

drop policy if exists incidents_write_manager on public.cg_incidents;
create policy incidents_write_manager
on public.cg_incidents
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists behavior_select_company on public.cg_behavior_events;
create policy behavior_select_company
on public.cg_behavior_events
for select
using (company_id = public.current_company_id());

drop policy if exists behavior_write_manager on public.cg_behavior_events;
create policy behavior_write_manager
on public.cg_behavior_events
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists training_modules_select_company on public.cg_training_modules;
create policy training_modules_select_company
on public.cg_training_modules
for select
using (company_id is null or company_id = public.current_company_id());

drop policy if exists training_modules_write_manager on public.cg_training_modules;
create policy training_modules_write_manager
on public.cg_training_modules
for all
using ((company_id is null and public.is_company_manager()) or (company_id = public.current_company_id() and public.is_company_manager()))
with check ((company_id is null and public.is_company_manager()) or (company_id = public.current_company_id() and public.is_company_manager()));

drop policy if exists training_assignments_select_company on public.cg_training_assignments;
create policy training_assignments_select_company
on public.cg_training_assignments
for select
using (company_id = public.current_company_id());

drop policy if exists training_assignments_write_manager on public.cg_training_assignments;
create policy training_assignments_write_manager
on public.cg_training_assignments
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists attack_library_select_company on public.cg_attack_library;
create policy attack_library_select_company
on public.cg_attack_library
for select
using (company_id is null or company_id = public.current_company_id());

drop policy if exists attack_library_write_manager on public.cg_attack_library;
create policy attack_library_write_manager
on public.cg_attack_library
for all
using ((company_id is null and public.is_company_manager()) or (company_id = public.current_company_id() and public.is_company_manager()))
with check ((company_id is null and public.is_company_manager()) or (company_id = public.current_company_id() and public.is_company_manager()));

drop policy if exists security_events_select_company on public.cg_security_events;
create policy security_events_select_company
on public.cg_security_events
for select
using (company_id = public.current_company_id());

drop policy if exists security_events_write_manager on public.cg_security_events;
create policy security_events_write_manager
on public.cg_security_events
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists notification_channels_select_company on public.cg_notification_channels;
create policy notification_channels_select_company
on public.cg_notification_channels
for select
using (company_id = public.current_company_id());

drop policy if exists notification_channels_write_manager on public.cg_notification_channels;
create policy notification_channels_write_manager
on public.cg_notification_channels
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists remediation_select_company on public.cg_remediation_actions;
create policy remediation_select_company
on public.cg_remediation_actions
for select
using (company_id = public.current_company_id());

drop policy if exists remediation_write_manager on public.cg_remediation_actions;
create policy remediation_write_manager
on public.cg_remediation_actions
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists email_scans_select_company on public.cg_email_scans;
create policy email_scans_select_company
on public.cg_email_scans
for select
using (company_id = public.current_company_id());

drop policy if exists email_scans_write_manager on public.cg_email_scans;
create policy email_scans_write_manager
on public.cg_email_scans
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop policy if exists company_snapshots_select_company on public.cg_company_score_snapshots;
create policy company_snapshots_select_company
on public.cg_company_score_snapshots
for select
using (company_id = public.current_company_id());

drop policy if exists company_snapshots_write_manager on public.cg_company_score_snapshots;
create policy company_snapshots_write_manager
on public.cg_company_score_snapshots
for all
using (company_id = public.current_company_id() and public.is_company_manager())
with check (company_id = public.current_company_id() and public.is_company_manager());

drop trigger if exists trg_departments_updated_at on public.cg_departments;
create trigger trg_departments_updated_at
before update on public.cg_departments
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_teams_updated_at on public.cg_teams;
create trigger trg_teams_updated_at
before update on public.cg_teams
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_incidents_updated_at on public.cg_incidents;
create trigger trg_incidents_updated_at
before update on public.cg_incidents
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_training_modules_updated_at on public.cg_training_modules;
create trigger trg_training_modules_updated_at
before update on public.cg_training_modules
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_training_assignments_updated_at on public.cg_training_assignments;
create trigger trg_training_assignments_updated_at
before update on public.cg_training_assignments
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_attack_library_updated_at on public.cg_attack_library;
create trigger trg_attack_library_updated_at
before update on public.cg_attack_library
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_security_events_updated_at on public.cg_security_events;
create trigger trg_security_events_updated_at
before update on public.cg_security_events
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_notification_channels_updated_at on public.cg_notification_channels;
create trigger trg_notification_channels_updated_at
before update on public.cg_notification_channels
for each row
execute procedure public.set_updated_at();

drop trigger if exists trg_remediation_updated_at on public.cg_remediation_actions;
create trigger trg_remediation_updated_at
before update on public.cg_remediation_actions
for each row
execute procedure public.set_updated_at();

insert into public.cg_training_modules (company_id, title, topic, estimated_minutes, content_url)
select null, 'Spotting Credential Harvesting', 'credential_submitted', 5, 'https://owasp.org/www-community/attacks/Phishing'
where not exists (
  select 1 from public.cg_training_modules
  where company_id is null and topic = 'credential_submitted'
);

insert into public.cg_training_modules (company_id, title, topic, estimated_minutes, content_url)
select null, 'How to Detect Phishing Links', 'phishing_click', 4, 'https://www.cisa.gov/resources-tools/resources/avoiding-social-engineering-and-phishing-attacks'
where not exists (
  select 1 from public.cg_training_modules
  where company_id is null and topic = 'phishing_click'
);

insert into public.cg_attack_library (company_id, category, name, subject_line, body_template)
select null, 'CEO fraud', 'Urgent CEO Transfer', 'Urgent transfer request', 'Hi, I need a confidential transfer completed in the next 30 minutes. Reply once done.'
where not exists (
  select 1 from public.cg_attack_library
  where company_id is null and name = 'Urgent CEO Transfer'
);

insert into public.cg_attack_library (company_id, category, name, subject_line, body_template)
select null, 'invoice scam', 'Invoice Overdue', 'Outstanding invoice #8841', 'Please review attached invoice and submit payment by EOD to avoid penalties.'
where not exists (
  select 1 from public.cg_attack_library
  where company_id is null and name = 'Invoice Overdue'
);

insert into public.cg_attack_library (company_id, category, name, subject_line, body_template)
select null, 'password reset scam', 'Password Expiring', 'Action required: reset now', 'Your password expires in 2 hours. Reset immediately using this secure link.'
where not exists (
  select 1 from public.cg_attack_library
  where company_id is null and name = 'Password Expiring'
);

insert into public.cg_attack_library (company_id, category, name, subject_line, body_template)
select null, 'hr phishing', 'Benefits Update', 'Mandatory HR confirmation', 'Confirm your updated payroll and benefits details before payroll processing.'
where not exists (
  select 1 from public.cg_attack_library
  where company_id is null and name = 'Benefits Update'
);

commit;


-- Extend signup trigger to initialize subscription onboarding state.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  meta jsonb;
  requested_role_text text;
  requested_role public.app_role;
  requested_company_name text;
  requested_company_code text;
  onboarding_mode text;
  selected_plan_text text;
  selected_plan public.subscription_plan;
  resolved_company_id uuid;
  resolved_name text;
begin
  meta := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  requested_role_text := lower(coalesce(meta->>'role', 'admin'));
  requested_company_name := coalesce(nullif(meta->>'company_name', ''), 'CyberGuard Company');
  requested_company_code := nullif(meta->>'company_code', '');
  resolved_name := coalesce(nullif(meta->>'name', ''), split_part(new.email, '@', 1));
  onboarding_mode := lower(coalesce(meta->>'onboarding_mode', 'trial'));
  selected_plan_text := lower(coalesce(meta->>'selected_plan', 'starter'));

  requested_role := case
    when requested_role_text in ('admin', 'employee', 'security_manager', 'auditor')
      then requested_role_text::public.app_role
    else 'admin'::public.app_role
  end;

  selected_plan := case
    when selected_plan_text in ('starter', 'pro', 'business')
      then selected_plan_text::public.subscription_plan
    else 'starter'::public.subscription_plan
  end;

  if requested_role in ('employee', 'security_manager', 'auditor') and requested_company_code is not null then
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
        role = excluded.role,
        updated_at = now();

  -- Create onboarding subscription row once per company.
  insert into public.cg_subscriptions (
    user_id,
    company_id,
    plan,
    status,
    current_period_end
  )
  values (
    new.id,
    resolved_company_id,
    selected_plan,
    case
      when requested_role = 'admin' and onboarding_mode = 'trial' then 'trialing'
      when requested_role = 'admin' and onboarding_mode = 'paid' then 'pending_checkout'
      else 'inactive'
    end,
    case
      when requested_role = 'admin' and onboarding_mode = 'trial'
        then now() + interval '30 days'
      else null
    end
  )
  on conflict (company_id) do nothing;

  perform public.recompute_company_risk(resolved_company_id);
  return new;
end;
$$;


