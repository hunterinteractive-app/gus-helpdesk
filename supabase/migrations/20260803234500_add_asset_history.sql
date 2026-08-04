-- Asset-level repair history and optional case linkage for the private Technician workspace.

alter table public.tickets
  add column asset_id uuid references public.assets(id) on delete set null;

create table public.asset_events (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.assets(id) on delete cascade,
  ticket_id uuid references public.tickets(id) on delete set null,
  event_type text not null default 'repair_note',
  notes text not null,
  performed_by uuid references public.profiles(id) on delete set null,
  performed_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index tickets_asset_idx on public.tickets (asset_id);
create index asset_events_asset_idx on public.asset_events (asset_id, performed_at desc);

alter table public.asset_events enable row level security;
grant select, insert, update, delete on public.asset_events to authenticated;

create policy "Technicians manage asset history"
on public.asset_events for all to authenticated
using (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')))
with check (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')));
