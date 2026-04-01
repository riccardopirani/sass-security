-- Add missing RLS policies for security_cg_profiles and security_cg_companies.
-- The tables had RLS enabled but no SELECT policies, blocking all JWT reads.

begin;

-- ── security_cg_profiles ────────────────────────────────────────────────────

alter table public.security_cg_profiles enable row level security;

-- Users can always read their own profile row.
drop policy if exists profiles_select_self on public.security_cg_profiles;
create policy profiles_select_self
  on public.security_cg_profiles
  for select
  using (id = auth.uid());

-- Users can read profiles of colleagues in the same company.
drop policy if exists profiles_select_same_company on public.security_cg_profiles;
create policy profiles_select_same_company
  on public.security_cg_profiles
  for select
  using (company_id = public.current_company_id());

-- Users can update their own row (name, avatar, etc.).
drop policy if exists profiles_update_self on public.security_cg_profiles;
create policy profiles_update_self
  on public.security_cg_profiles
  for update
  using (id = auth.uid());

-- ── security_cg_companies ────────────────────────────────────────────────────

alter table public.security_cg_companies enable row level security;

-- Users can read their own company row (needed for the join in fetchMyProfile).
drop policy if exists companies_select_own on public.security_cg_companies;
create policy companies_select_own
  on public.security_cg_companies
  for select
  using (id = public.current_company_id());

-- Admins can update their own company.
drop policy if exists companies_update_admin on public.security_cg_companies;
create policy companies_update_admin
  on public.security_cg_companies
  for update
  using (id = public.current_company_id() and public.is_company_admin());

commit;
