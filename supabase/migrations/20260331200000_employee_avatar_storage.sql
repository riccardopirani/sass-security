-- Profile photo URL on employees; public storage bucket scoped by company folder.

begin;

alter table public.security_cg_employees
  add column if not exists avatar_url text;

insert into storage.buckets (id, name, public)
values ('employee-avatars', 'employee-avatars', true)
on conflict (id) do update set public = excluded.public;

-- Path convention: {company_id}/{employee_id}.{ext}
drop policy if exists employee_avatars_select_same_company on storage.objects;
drop policy if exists employee_avatars_insert_same_company on storage.objects;
drop policy if exists employee_avatars_update_same_company on storage.objects;
drop policy if exists employee_avatars_delete_same_company on storage.objects;

create policy employee_avatars_select_same_company
  on storage.objects for select
  using (
    bucket_id = 'employee-avatars'
    and split_part(name, '/', 1) = (
      select company_id::text from public.security_cg_profiles where id = auth.uid()
    )
  );

create policy employee_avatars_insert_same_company
  on storage.objects for insert
  with check (
    bucket_id = 'employee-avatars'
    and split_part(name, '/', 1) = (
      select company_id::text from public.security_cg_profiles where id = auth.uid()
    )
  );

create policy employee_avatars_update_same_company
  on storage.objects for update
  using (
    bucket_id = 'employee-avatars'
    and split_part(name, '/', 1) = (
      select company_id::text from public.security_cg_profiles where id = auth.uid()
    )
  );

create policy employee_avatars_delete_same_company
  on storage.objects for delete
  using (
    bucket_id = 'employee-avatars'
    and split_part(name, '/', 1) = (
      select company_id::text from public.security_cg_profiles where id = auth.uid()
    )
  );

commit;
