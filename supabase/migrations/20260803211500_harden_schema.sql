-- Prevent direct API calls to Supabase's automatic-RLS helper.
revoke execute on function public.rls_auto_enable() from public;

-- Cover foreign keys used by technician assignment and resolution lookups.
create index tickets_assigned_to_idx on public.tickets (assigned_to);
create index verified_resolutions_restaurant_idx on public.verified_resolutions (restaurant_id);
create index verified_resolutions_verified_by_idx on public.verified_resolutions (verified_by);
