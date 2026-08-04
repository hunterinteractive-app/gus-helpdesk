-- Every Auth user receives a least-privilege Crew profile. Technician and admin
-- roles are granted manually by an administrator after account verification.

create function public.create_profile_for_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    'crew'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

revoke execute on function public.create_profile_for_new_user() from public, anon, authenticated;

create trigger create_profile_after_auth_signup
after insert on auth.users
for each row execute function public.create_profile_for_new_user();
