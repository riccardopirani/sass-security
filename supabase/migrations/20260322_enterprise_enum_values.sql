-- New enum labels must be committed before any function/SQL references them (PostgreSQL 55P04).

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
