-- Immutable-style timeline for technician-visible case activity.

create table public.case_events (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references public.tickets(id) on delete cascade,
  event_type text not null,
  message text not null,
  performed_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create index case_events_ticket_created_idx on public.case_events (ticket_id, created_at desc);
alter table public.case_events enable row level security;
grant select, insert on public.case_events to authenticated;

create policy "Technicians read case timelines"
on public.case_events for select to authenticated
using (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')));

create policy "Technicians add case timeline notes"
on public.case_events for insert to authenticated
with check (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')));

create function public.log_ticket_created()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.case_events (ticket_id, event_type, message)
  values (new.id, 'submitted', 'Help Desk request submitted.');
  return new;
end;
$$;

create function public.log_ticket_update()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.status is distinct from old.status
     or new.priority is distinct from old.priority
     or new.scheduled_for is distinct from old.scheduled_for
     or new.resolution_notes is distinct from old.resolution_notes then
    insert into public.case_events (ticket_id, event_type, message)
    values (new.id, 'case_updated', 'Technician updated the case plan or resolution.');
  end if;
  return new;
end;
$$;

revoke execute on function public.log_ticket_created(), public.log_ticket_update() from public, anon, authenticated;

create trigger ticket_created_timeline after insert on public.tickets
for each row execute function public.log_ticket_created();
create trigger ticket_updated_timeline after update on public.tickets
for each row execute function public.log_ticket_update();
