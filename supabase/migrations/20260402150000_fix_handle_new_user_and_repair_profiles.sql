begin;

-- 1. Fix handle_new_user: add 'flex' to plan selection + re-bind trigger
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
  requested_role_text   := lower(coalesce(meta->>'role', 'admin'));
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

  if requested_role in ('employee'::public.app_role, 'security_manager'::public.app_role, 'auditor'::public.app_role)
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

-- 2. Repair: create missing profiles for auth users that slipped through.
--    Runs only for rows where profile is absent.  Safe to re-run.
do $$
declare
  rec record;
  meta jsonb;
  r_role_text text;
  r_role public.app_role;
  r_company_name text;
  r_company_code text;
  r_name text;
  r_mode text;
  r_plan_text text;
  r_plan public.subscription_plan;
  r_company_id uuid;
begin
  for rec in
    select u.id, u.email, u.raw_user_meta_data as meta
      from auth.users u
      left join public.security_cg_profiles p on p.id = u.id
     where p.id is null
  loop
    meta           := coalesce(rec.meta, '{}'::jsonb);
    r_role_text    := lower(coalesce(meta->>'role', 'admin'));
    r_company_name := coalesce(nullif(trim(meta->>'company_name'), ''), 'CyberGuard Company');
    r_company_code := nullif(trim(meta->>'company_code'), '');
    r_name         := coalesce(nullif(trim(meta->>'name'), ''), split_part(rec.email, '@', 1));
    r_mode         := lower(coalesce(meta->>'onboarding_mode', 'trial'));
    r_plan_text    := lower(coalesce(meta->>'selected_plan', 'flex'));

    r_role := case
      when r_role_text in ('admin', 'employee', 'security_manager', 'auditor')
        then r_role_text::public.app_role
      else 'admin'::public.app_role
    end;

    r_plan := case
      when r_plan_text in ('flex', 'starter', 'pro', 'business')
        then r_plan_text::public.subscription_plan
      else 'flex'::public.subscription_plan
    end;

    r_company_id := null;

    if r_role in ('employee'::public.app_role, 'security_manager'::public.app_role, 'auditor'::public.app_role)
       and r_company_code is not null
    then
      select id into r_company_id
        from public.security_cg_companies
       where code = upper(r_company_code)
       limit 1;
    end if;

    if r_company_id is null then
      insert into public.security_cg_companies (name)
      values (r_company_name)
      returning id into r_company_id;
      r_role := 'admin';
    end if;

    insert into public.security_cg_profiles (id, company_id, name, email, role)
    values (rec.id, r_company_id, r_name, rec.email, r_role)
    on conflict (id) do nothing;

    insert into public.security_cg_employees (company_id, auth_user_id, name, email, role)
    values (r_company_id, rec.id, r_name, rec.email, r_role)
    on conflict (company_id, email) do update
      set auth_user_id = excluded.auth_user_id,
          role         = excluded.role,
          updated_at   = now();

    insert into public.security_cg_subscriptions (
      user_id, company_id, plan, status, current_period_end
    )
    values (
      rec.id,
      r_company_id,
      r_plan,
      case
        when r_role = 'admin' and r_mode = 'trial'  then 'trialing'
        when r_role = 'admin' and r_mode = 'paid'   then 'pending_checkout'
        else 'inactive'
      end,
      case
        when r_role = 'admin' and r_mode = 'trial' then now() + interval '30 days'
        else null
      end
    )
    on conflict (company_id) do nothing;

    perform public.recompute_company_risk(r_company_id);
    raise notice 'Repaired profile for user %', rec.id;
  end loop;
end;
$$;

commit;
