-- Technicians can create a private follow-up case from verified learning.
grant insert on public.tickets to authenticated;

create policy "Technicians can create follow-up tickets"
on public.tickets for insert to authenticated
with check (
  exists (
    select 1 from public.profiles
    where profiles.id = (select auth.uid())
      and profiles.role in ('technician', 'admin')
  )
);
