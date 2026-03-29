-- Prefix all CyberGuard tables with security_ (e.g. cg_companies -> security_cg_companies).

begin;

-- Drop realtime member by old name before renaming alerts table.
do $$
begin
  alter publication supabase_realtime drop table public.cg_alerts;
exception
  when undefined_object then null;
  when undefined_table then null;
end $$;

alter table if exists public.cg_alerts rename to security_cg_alerts;
alter table if exists public.cg_attack_library rename to security_cg_attack_library;
alter table if exists public.cg_behavior_events rename to security_cg_behavior_events;
alter table if exists public.cg_companies rename to security_cg_companies;
alter table if exists public.cg_company_score_snapshots rename to security_cg_company_score_snapshots;
alter table if exists public.cg_departments rename to security_cg_departments;
alter table if exists public.cg_email_scans rename to security_cg_email_scans;
alter table if exists public.cg_employees rename to security_cg_employees;
alter table if exists public.cg_incidents rename to security_cg_incidents;
alter table if exists public.cg_notification_channels rename to security_cg_notification_channels;
alter table if exists public.cg_phishing_campaigns rename to security_cg_phishing_campaigns;
alter table if exists public.cg_phishing_events rename to security_cg_phishing_events;
alter table if exists public.cg_profiles rename to security_cg_profiles;
alter table if exists public.cg_remediation_actions rename to security_cg_remediation_actions;
alter table if exists public.cg_security_events rename to security_cg_security_events;
alter table if exists public.cg_subscriptions rename to security_cg_subscriptions;
alter table if exists public.cg_teams rename to security_cg_teams;
alter table if exists public.cg_training_assignments rename to security_cg_training_assignments;
alter table if exists public.cg_training_modules rename to security_cg_training_modules;
alter table if exists public.cg_training_records rename to security_cg_training_records;

do $$
begin
  if to_regclass('public.security_cg_alerts') is not null then
    alter publication supabase_realtime add table public.security_cg_alerts;
  end if;
exception
  when duplicate_object then null;
  when undefined_table then null;
end $$;

commit;
