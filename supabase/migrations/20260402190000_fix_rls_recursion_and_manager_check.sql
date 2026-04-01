-- Fix two issues introduced by the previous RLS migration:
--
-- 1. profiles_select_same_company caused infinite recursion:
--    the policy called current_company_id() which SELECT-s security_cg_profiles
--    → triggers the same policy again → infinite loop → REST queries hang.
--    Fix: drop that policy. profiles_select_self (id = auth.uid()) is sufficient
--    for the app to read its own profile; company-wide reads are done via
--    service-role in edge functions.
--
-- 2. employees_insert_manager / employees_update_manager used is_company_manager()
--    which queries security_cg_profiles. For users whose profile was just created
--    in the same transaction, or whose profile role was not yet visible, this
--    returned false. Fix: also check JWT user_metadata.role as fallback.

begin;

-- ── Remove recursive policy on profiles ──────────────────────────────────────
drop policy if exists profiles_select_same_company on public.security_cg_profiles;

-- ── Update helper functions with JWT fallback ─────────────────────────────────

create or replace function public.is_company_manager()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select (
    -- Primary: check the profile row (bypasses RLS via security definer)
    exists (
      select 1 from public.security_cg_profiles
       where id = auth.uid()
         and role in ('admin', 'security_manager')
    )
    or
    -- Fallback: trust the signed JWT user_metadata when profile row lags
    coalesce(auth.jwt() -> 'user_metadata' ->> 'role', '')
      in ('admin', 'security_manager')
  );
$$;

create or replace function public.is_company_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select (
    exists (
      select 1 from public.security_cg_profiles
       where id = auth.uid()
         and role = 'admin'
    )
    or
    coalesce(auth.jwt() -> 'user_metadata' ->> 'role', '') = 'admin'
  );
$$;

-- current_company_id: keep querying profiles (security definer → no recursion)
-- but also handle the case where auth.uid() is null gracefully.
create or replace function public.current_company_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select company_id
    from public.security_cg_profiles
   where id = auth.uid()
   limit 1;
$$;

-- ── Rebuild employees policies using updated functions ────────────────────────
drop policy if exists employees_insert_manager on public.security_cg_employees;
create policy employees_insert_manager
  on public.security_cg_employees
  for insert
  with check (
    company_id = public.current_company_id()
    and public.is_company_manager()
  );

drop policy if exists employees_update_manager on public.security_cg_employees;
create policy employees_update_manager
  on public.security_cg_employees
  for update
  using (
    company_id = public.current_company_id()
    and public.is_company_manager()
  );

drop policy if exists employees_delete_admin on public.security_cg_employees;
create policy employees_delete_admin
  on public.security_cg_employees
  for delete
  using (
    company_id = public.current_company_id()
    and public.is_company_admin()
  );

-- ── Rebuild subscriptions write policy ───────────────────────────────────────
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

commit;
