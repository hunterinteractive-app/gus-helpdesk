-- The RLS policy already limits this table to a user's own profile.
-- This grant lets an authenticated user perform that permitted read.
grant select on public.profiles to authenticated;
