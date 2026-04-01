-- Fix RLS for security_cg_employees and security_cg_subscriptions.
-- Root cause: employees_write_admin policy used auth.uid()-based checks which
-- return false during the signup trigger context (no active session).
-- Fix also: handle_new_user now uses SET row_security = off to bypass RLS entirely.

begin;

-- ── security_cg_employees ────────────────────────────────────────────────────

alter table public.security_cg_employees enable row level security;

-- Drop the old policy (was on cg_employees, carried over after rename)
drop policy if exists employees_write_admin on public.security_cg_employees;

-- All authenticated users can read employees in their own company.
drop policy if exists employees_select_company on public.security_cg_employees;
create policy employees_select_company
  on public.security_cg_employees
  for select
  using (company_id = public.current_company_id());

-- Managers / admins can insert new employees in their company.
drop policy if exists employees_insert_manager on public.security_cg_employees;
create policy employees_insert_manager
  on public.security_cg_employees
  for insert
  with check (
    company_id = public.current_company_id()
    and public.is_company_manager()
  );

-- Managers / admins can update employees in their company.
drop policy if exists employees_update_manager on public.security_cg_employees;
create policy employees_update_manager
  on public.security_cg_employees
  for update
  using (
    company_id = public.current_company_id()
    and public.is_company_manager()
  );

-- Only admins can delete employees.
drop policy if exists employees_delete_admin on public.security_cg_employees;
create policy employees_delete_admin
  on public.security_cg_employees
  for delete
  using (
    company_id = public.current_company_id()
    and public.is_company_admin()
  );

-- ── security_cg_subscriptions ────────────────────────────────────────────────

alter table public.security_cg_subscriptions enable row level security;

drop policy if exists subscriptions_write_admin on public.security_cg_subscriptions;

-- Admins can read their company subscription.
drop policy if exists subscriptions_select_admin on public.security_cg_subscriptions;
create policy subscriptions_select_admin
  on public.security_cg_subscriptions
  for select
  using (company_id = public.current_company_id());

-- Only admins can write subscription records (Stripe webhook uses service role,
-- which bypasses RLS; this covers direct admin actions).
drop policy if exists subscriptions_write_manager on public.security_cg_subscriptions;
create policy subscriptions_write_manager
  on public.security_cg_subscriptions
  for all
  using (
    company_id = public.current_company_id()
    and public.is_company_admin()
  )
  with check (
    company_id = public.current_company_id()
    and public.is_company_admin()
  );

-- ── handle_new_user: bypass RLS entirely ─────────────────────────────────────
-- The trigger runs as SECURITY DEFINER (postgres / superuser), but Supabase may
-- still enforce RLS if row_security session var is on.  SET row_security = off
-- guarantees all INSERT statements inside the trigger skip RLS checks.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
set row_security = off          -- bypass RLS for all DML inside this function
as $$
declare
  meta                   jsonb;
  requested_role_text    text;
  requested_role         public.app_role;
  requested_company_name text;
  requested_company_code text;
  onboarding_mode        text;
  selected_plan_text     text;
  selected_plan          public.subscription_plan;
  resolved_company_id    uuid;
  resolved_name          text;
begin
  meta                   := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  requested_role_text    := lower(coalesce(meta->>'role', 'admin'));
  requested_company_name := coalesce(nullif(trim(meta->>'company_name'), ''), 'CyberGuard Company');
  requested_company_code := nullif(trim(meta->>'company_code'), '');
  resolved_name          := coalesce(nullif(trim(meta->>'name'), ''), split_part(new.email, '@', 1));
  onboarding_mode        := lower(coalesce(meta->>'onboarding_mode', 'trial'));
  selected_plan_text     := lower(coalesce(meta->>'selected_plan', 'flex'));

  requested_role := case
    when requested_role_text in ('admin', 'employee', 'security_manager', 'auditor')
      then requested_role_text::public.app_role
    else 'admin'::public.app_role
  end;

  selected_plan := case
    when selected_plan_text in ('flex', 'starter', 'pro', 'business')
      then selected_plan_text::public.subscription_plan
    else 'flex'::public.subscription_plan
  end;

  if requested_role in (
       'employee'::public.app_role,
       'security_manager'::public.app_role,
       'auditor'::public.app_role
     )
     and requested_company_code is not null
  then
    select id
      into resolved_company_id
      from public.security_cg_companies
     where code = upper(requested_company_code)
     limit 1;
  end if;

  if resolved_company_id is null then
    insert into public.security_cg_companies (name)
    values (requested_company_name)
    returning id into resolved_company_id;
    requested_role := 'admin';
  end if;

  insert into public.security_cg_profiles (id, company_id, name, email, role)
  values (new.id, resolved_company_id, resolved_name, new.email, requested_role)
  on conflict (id) do update
    set company_id = excluded.company_id,
        name       = excluded.name,
        email      = excluded.email,
        role       = excluded.role,
        updated_at = now();

  insert into public.security_cg_employees (company_id, auth_user_id, name, email, role)
  values (resolved_company_id, new.id, resolved_name, new.email, requested_role)
  on conflict (company_id, email) do update
    set auth_user_id = excluded.auth_user_id,
        role         = excluded.role,
        updated_at   = now();

  insert into public.security_cg_subscriptions (
    user_id, company_id, plan, status, current_period_end
  )
  values (
    new.id,
    resolved_company_id,
    selected_plan,
    case
      when requested_role = 'admin' and onboarding_mode = 'trial'  then 'trialing'
      when requested_role = 'admin' and onboarding_mode = 'paid'   then 'pending_checkout'
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

-- Re-bind trigger (idempotent)
drop trigger if exists trg_on_auth_user_created on auth.users;
create trigger trg_on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

commit;
