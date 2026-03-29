-- Legacy path: rename unprefixed tables to cg_*. Skips when schema already uses cg_* (fresh enterprise migration).

begin;

do $$
begin
  if to_regclass('public.companies') is not null and to_regclass('public.cg_companies') is null then
    alter table public.companies rename to cg_companies;
  end if;
  if to_regclass('public.profiles') is not null and to_regclass('public.cg_profiles') is null then
    alter table public.profiles rename to cg_profiles;
  end if;
  if to_regclass('public.employees') is not null and to_regclass('public.cg_employees') is null then
    alter table public.employees rename to cg_employees;
  end if;
  if to_regclass('public.phishing_campaigns') is not null and to_regclass('public.cg_phishing_campaigns') is null then
    alter table public.phishing_campaigns rename to cg_phishing_campaigns;
  end if;
  if to_regclass('public.phishing_events') is not null and to_regclass('public.cg_phishing_events') is null then
    alter table public.phishing_events rename to cg_phishing_events;
  end if;
  if to_regclass('public.alerts') is not null and to_regclass('public.cg_alerts') is null then
    alter table public.alerts rename to cg_alerts;
  end if;
  if to_regclass('public.training_records') is not null and to_regclass('public.cg_training_records') is null then
    alter table public.training_records rename to cg_training_records;
  end if;
  if to_regclass('public.subscriptions') is not null and to_regclass('public.cg_subscriptions') is null then
    alter table public.subscriptions rename to cg_subscriptions;
  end if;
end $$;

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
