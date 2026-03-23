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
