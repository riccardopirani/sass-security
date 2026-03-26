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
