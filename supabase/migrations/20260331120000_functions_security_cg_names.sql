-- Recreate functions/triggers to use security_cg_* table names after 20260330 rename.
begin;

create or replace function public.current_company_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select company_id from public.security_cg_profiles where id = auth.uid();
$$;

create or replace function public.is_company_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.security_cg_profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.is_company_manager()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.security_cg_profiles
    where id = auth.uid()
      and role in ('admin', 'security_manager')
  );
$$;

create or replace function public.is_company_auditor()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.security_cg_profiles
    where id = auth.uid()
      and role = 'auditor'
  );
$$;

create or replace function public.refresh_company_benchmark(target_company uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  own_risk int := 0;
  safer_count int := 0;
  peer_count int := 0;
  percentile int := 0;
begin
  select c.risk_score
  into own_risk
  from public.security_cg_companies c
  where c.id = target_company;

  if own_risk is null then
    return 0;
  end if;

  select count(*)
  into peer_count
  from public.security_cg_companies p;

  if peer_count = 0 then
    percentile := 0;
  else
    select count(*)
    into safer_count
    from public.security_cg_companies p
    where p.risk_score >= own_risk;

    percentile := round((safer_count::numeric / peer_count::numeric) * 100)::int;
  end if;

  update public.security_cg_companies
  set benchmark_percentile = greatest(0, least(100, percentile)),
      updated_at = now()
  where id = target_company;

  return greatest(0, least(100, percentile));
end;
$$;

create or replace function public.recompute_company_risk(target_company uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  score int;
begin
  select coalesce(round(avg(e.risk_score))::int, 0)
  into score
  from public.security_cg_employees e
  where e.company_id = target_company;

  update public.security_cg_companies
  set risk_score = public.clamp_score(score),
      updated_at = now()
  where id = target_company;

  insert into public.security_cg_company_score_snapshots (company_id, snapshot_date, risk_score)
  values (target_company, current_date, public.clamp_score(score))
  on conflict (company_id, snapshot_date) do update
    set risk_score = excluded.risk_score;

  perform public.refresh_company_benchmark(target_company);

  return public.clamp_score(score);
end;
$$;

create or replace function public.assign_adaptive_training(
  target_company uuid,
  target_employee uuid,
  reason text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  module_id uuid;
  assignment_id uuid;
begin
  select id
  into module_id
  from public.security_cg_training_modules m
  where (m.company_id = target_company or m.company_id is null)
    and m.is_active = true
    and (m.topic = reason or m.topic = 'general')
  order by case when m.topic = reason then 0 else 1 end, m.created_at asc
  limit 1;

  if module_id is null then
    insert into public.security_cg_training_modules (company_id, title, topic, estimated_minutes, content_url)
    values (
      null,
      'Rapid Security Recovery',
      'general',
      5,
      'https://owasp.org/www-project-top-ten/'
    )
    returning id into module_id;
  end if;

  select a.id
  into assignment_id
  from public.security_cg_training_assignments a
  where a.company_id = target_company
    and a.employee_id = target_employee
    and a.status in ('assigned', 'in_progress')
    and a.trigger_reason = reason
  order by a.created_at desc
  limit 1;

  if assignment_id is null then
    insert into public.security_cg_training_assignments (
      company_id,
      employee_id,
      module_id,
      trigger_reason,
      status,
      due_at
    )
    values (
      target_company,
      target_employee,
      module_id,
      reason,
      'assigned',
      now() + interval '7 days'
    )
    returning id into assignment_id;
  end if;

  return assignment_id;
end;
$$;

create or replace function public.recompute_employee_risk(target_employee uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  emp public.security_cg_employees%rowtype;
  phishing_risk int := 0;
  training_gap int := 0;
  incident_risk int := 0;
  mfa_penalty int := 0;
  final_score int := 0;
begin
  select *
  into emp
  from public.security_cg_employees
  where id = target_employee;

  if emp.id is null then
    return 0;
  end if;

  select coalesce(
    least(
      100,
      sum(
        case
          when pe.event_type = 'clicked' then 15
          when pe.event_type = 'credential_submitted' then 26
          when pe.event_type = 'opened' then 4
          else 0
        end
      )
    ),
    0
  )
  into phishing_risk
  from public.security_cg_phishing_events pe
  where pe.employee_id = target_employee
    and pe.created_at >= now() - interval '90 days';

  select coalesce(
    least(
      100,
      sum(
        case
          when i.severity = 'critical' then 30
          when i.severity = 'high' then 18
          when i.severity = 'medium' then 10
          else 4
        end
      )
    ),
    0
  )
  into incident_risk
  from public.security_cg_incidents i
  where i.employee_id = target_employee
    and i.created_at >= now() - interval '180 days';

  training_gap := greatest(0, 100 - emp.training_completion);
  mfa_penalty := case when emp.mfa_enabled then 0 else 8 end;

  final_score := round(
    (phishing_risk * 0.28) +
    (emp.password_behavior_score * 0.18) +
    (training_gap * 0.16) +
    (greatest(emp.incident_history_score, incident_risk) * 0.14) +
    (emp.device_compliance_score * 0.10) +
    (emp.behavior_risk_score * 0.10) +
    (mfa_penalty * 0.04)
  )::int;

  update public.security_cg_employees
  set risk_score = public.clamp_score(final_score),
      incident_history_score = greatest(emp.incident_history_score, incident_risk),
      updated_at = now()
  where id = target_employee;

  perform public.recompute_company_risk(emp.company_id);

  return public.clamp_score(final_score);
end;
$$;

create or replace function public.sync_training_to_employee()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.security_cg_employees
  set training_completion = new.completion_percent,
      updated_at = now()
  where id = new.employee_id;

  perform public.recompute_employee_risk(new.employee_id);
  return new;
end;
$$;

create or replace function public.sync_behavior_to_employee()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  behavior_score int;
begin
  select coalesce(
    least(100, round(avg(be.risk_weight))::int),
    0
  )
  into behavior_score
  from public.security_cg_behavior_events be
  where be.employee_id = new.employee_id
    and be.created_at >= now() - interval '30 days';

  update public.security_cg_employees
  set behavior_risk_score = behavior_score,
      updated_at = now()
  where id = new.employee_id;

  perform public.recompute_employee_risk(new.employee_id);
  return new;
end;
$$;

create or replace function public.sync_incidents_to_employee()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_employee uuid;
begin
  target_employee := coalesce(new.employee_id, old.employee_id);

  if target_employee is null then
    return coalesce(new, old);
  end if;

  perform public.recompute_employee_risk(target_employee);
  return coalesce(new, old);
end;
$$;

create or replace function public.recompute_employee_risk_on_factor_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.recompute_employee_risk(new.id);
  return new;
end;
$$;

create or replace function public.apply_phishing_event_effects()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.event_type = 'sent' then
    update public.security_cg_phishing_campaigns
    set sent_count = sent_count + 1,
        updated_at = now()
    where id = new.campaign_id;
  elsif new.event_type = 'opened' then
    update public.security_cg_phishing_campaigns
    set opened_count = opened_count + 1,
        updated_at = now()
    where id = new.campaign_id;
  elsif new.event_type = 'clicked' then
    update public.security_cg_phishing_campaigns
    set clicked_count = clicked_count + 1,
        updated_at = now()
    where id = new.campaign_id;

    insert into public.security_cg_alerts (company_id, employee_id, severity, title, message, alert_kind, channels)
    values (
      new.company_id,
      new.employee_id,
      'high',
      'Phishing click detected',
      'An employee clicked a simulated phishing link. Adaptive training assigned.',
      'risky_behavior',
      array['in_app', 'email']::text[]
    );

    insert into public.security_cg_incidents (company_id, employee_id, incident_type, severity, source, details)
    values (
      new.company_id,
      new.employee_id,
      'phishing_click',
      'high',
      'simulation',
      'User clicked phishing simulation link.'
    );

    perform public.assign_adaptive_training(new.company_id, new.employee_id, 'phishing_click');
  elsif new.event_type = 'credential_submitted' then
    update public.security_cg_phishing_campaigns
    set credential_submitted_count = credential_submitted_count + 1,
        updated_at = now()
    where id = new.campaign_id;

    insert into public.security_cg_alerts (company_id, employee_id, severity, title, message, alert_kind, channels)
    values (
      new.company_id,
      new.employee_id,
      'critical',
      'Credential submission detected',
      'Credentials submitted in phishing simulation. Immediate remediation required.',
      'credential_compromise',
      array['in_app', 'email', 'slack', 'teams', 'push']::text[]
    );

    insert into public.security_cg_incidents (company_id, employee_id, incident_type, severity, source, details)
    values (
      new.company_id,
      new.employee_id,
      'credential_submitted',
      'critical',
      'simulation',
      'User submitted credentials during phishing simulation.'
    );

    perform public.assign_adaptive_training(new.company_id, new.employee_id, 'credential_submitted');
  end if;

  perform public.recompute_employee_risk(new.employee_id);
  return new;
end;
$$;

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
  on conflict (id) do nothing;

  insert into public.security_cg_employees (company_id, auth_user_id, name, email, role)
  values (resolved_company_id, new.id, resolved_name, new.email, requested_role)
  on conflict (company_id, email) do update
    set auth_user_id = excluded.auth_user_id,
        role = excluded.role,
        updated_at = now();

  -- Create onboarding subscription row once per company.
  insert into public.security_cg_subscriptions (
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

-- Re-bind triggers after table rename (names reference security_cg_* relations).
drop trigger if exists trg_behavior_sync on public.security_cg_behavior_events;
create trigger trg_behavior_sync
after insert on public.security_cg_behavior_events
for each row execute function public.sync_behavior_to_employee();

drop trigger if exists trg_incident_sync on public.security_cg_incidents;
create trigger trg_incident_sync
after insert or update or delete on public.security_cg_incidents
for each row execute function public.sync_incidents_to_employee();

drop trigger if exists trg_employee_factor_recompute on public.security_cg_employees;
create trigger trg_employee_factor_recompute
after update of password_behavior_score, training_completion, incident_history_score, device_compliance_score, behavior_risk_score, mfa_enabled
on public.security_cg_employees
for each row execute function public.recompute_employee_risk_on_factor_change();

commit;
