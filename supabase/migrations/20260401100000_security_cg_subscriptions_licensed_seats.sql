-- Ensure licensed_seats exists on renamed table (fixes DBs where 20260329140000
-- targeted security_cg_subscriptions before that table existed).
alter table public.security_cg_subscriptions
  add column if not exists licensed_seats integer;
