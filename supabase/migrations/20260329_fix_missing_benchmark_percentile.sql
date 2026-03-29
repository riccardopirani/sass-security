-- Hotfix for environments where benchmark_percentile was not applied.

begin;

do $$
begin
  if to_regclass('public.cg_companies') is null
     and to_regclass('public.companies') is not null then
    alter table public.companies rename to cg_companies;
  end if;

  if to_regclass('public.cg_companies') is not null
     and not exists (
       select 1
       from information_schema.columns
       where table_schema = 'public'
         and table_name = 'cg_companies'
         and column_name = 'industry'
     ) then
    alter table public.cg_companies
      add column industry text not null default 'general';
  end if;

  if to_regclass('public.cg_companies') is not null
     and not exists (
       select 1
       from information_schema.columns
       where table_schema = 'public'
         and table_name = 'cg_companies'
         and column_name = 'company_size'
     ) then
    alter table public.cg_companies
      add column company_size text not null default 'smb';
  end if;

  if to_regclass('public.cg_companies') is not null
     and not exists (
       select 1
       from information_schema.columns
       where table_schema = 'public'
         and table_name = 'cg_companies'
         and column_name = 'region'
     ) then
    alter table public.cg_companies
      add column region text not null default 'global';
  end if;

  if to_regclass('public.cg_companies') is not null
     and not exists (
       select 1
       from information_schema.columns
       where table_schema = 'public'
         and table_name = 'cg_companies'
         and column_name = 'benchmark_percentile'
     ) then
    alter table public.cg_companies
      add column benchmark_percentile int not null default 0;
  end if;

  if to_regclass('public.cg_companies') is not null
     and exists (
       select 1
       from information_schema.columns
       where table_schema = 'public'
         and table_name = 'cg_companies'
         and column_name = 'benchmark_percentile'
     ) then
    update public.cg_companies
    set benchmark_percentile = 0
    where benchmark_percentile is null;

    alter table public.cg_companies
      alter column benchmark_percentile set default 0;

    alter table public.cg_companies
      alter column benchmark_percentile set not null;

    if not exists (
      select 1
      from pg_constraint
      where conrelid = 'public.cg_companies'::regclass
        and conname = 'cg_companies_benchmark_percentile_check'
    ) then
      alter table public.cg_companies
        add constraint cg_companies_benchmark_percentile_check
        check (benchmark_percentile between 0 and 100);
    end if;
  end if;
end $$;

commit;
