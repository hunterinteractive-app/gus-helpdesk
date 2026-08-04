-- Operations Technology Support: secure Help Desk foundation.
-- Public visitors can create a ticket, but cannot read any ticket data.

create type public.ticket_status as enum ('open', 'planned', 'in_progress', 'waiting_on_parts', 'resolved', 'closed');
create type public.ticket_priority as enum ('p1', 'p2', 'p3', 'p4');
create type public.profile_role as enum ('crew', 'manager', 'technician', 'admin');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role public.profile_role not null default 'crew',
  created_at timestamptz not null default now()
);

create table public.restaurants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  area text,
  address text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (name)
);

create table public.tickets (
  id uuid primary key default gen_random_uuid(),
  ticket_number bigint generated always as identity unique,
  restaurant_id uuid references public.restaurants(id) on delete set null,
  restaurant_name text not null,
  area_affected text not null,
  system_affected text not null,
  issue_description text not null,
  additional_details text,
  reporter_name text,
  reporter_contact text,
  quick_checks_completed jsonb not null default '[]'::jsonb,
  status public.ticket_status not null default 'open',
  priority public.ticket_priority not null default 'p3',
  scheduled_for timestamptz,
  assigned_to uuid references public.profiles(id) on delete set null,
  resolution_notes text,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.ticket_attachments (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references public.tickets(id) on delete cascade,
  storage_path text not null unique,
  original_filename text not null,
  mime_type text,
  bytes bigint,
  created_at timestamptz not null default now()
);

create table public.verified_resolutions (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid unique references public.tickets(id) on delete set null,
  title text not null,
  symptoms text,
  verified_fix text not null,
  system_affected text,
  restaurant_id uuid references public.restaurants(id) on delete set null,
  verified_by uuid references public.profiles(id) on delete set null,
  verified_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index tickets_status_priority_created_idx on public.tickets (status, priority, created_at desc);
create index tickets_restaurant_created_idx on public.tickets (restaurant_id, created_at desc);
create index ticket_attachments_ticket_idx on public.ticket_attachments (ticket_id);
create index verified_resolutions_system_idx on public.verified_resolutions (system_affected, verified_at desc);

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger tickets_set_updated_at
before update on public.tickets
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.restaurants enable row level security;
alter table public.tickets enable row level security;
alter table public.ticket_attachments enable row level security;
alter table public.verified_resolutions enable row level security;

-- Data API access is intentionally explicit; no service-role key is ever used in the browser.
grant usage on schema public to anon, authenticated;
grant select on public.restaurants to anon, authenticated;
grant insert on public.tickets to anon;
grant select, update on public.tickets to authenticated;
grant select on public.ticket_attachments to authenticated;
grant select, insert on public.verified_resolutions to authenticated;

create policy "Anyone can view active restaurants"
on public.restaurants for select
to anon, authenticated
using (active = true);

create policy "Users can view their own profile"
on public.profiles for select
to authenticated
using ((select auth.uid()) = id);

create policy "Public can submit a Help Desk ticket"
on public.tickets for insert
to anon
with check (
  char_length(trim(restaurant_name)) > 0
  and char_length(trim(area_affected)) > 0
  and char_length(trim(system_affected)) > 0
  and char_length(trim(issue_description)) > 0
);

create policy "Technicians can read tickets"
on public.tickets for select
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = (select auth.uid())
      and profiles.role in ('technician', 'admin')
  )
);

create policy "Technicians can update tickets"
on public.tickets for update
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = (select auth.uid())
      and profiles.role in ('technician', 'admin')
  )
)
with check (
  exists (
    select 1 from public.profiles
    where profiles.id = (select auth.uid())
      and profiles.role in ('technician', 'admin')
  )
);

create policy "Technicians can view ticket attachments"
on public.ticket_attachments for select
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = (select auth.uid())
      and profiles.role in ('technician', 'admin')
  )
);

create policy "Technicians manage verified resolutions"
on public.verified_resolutions for all
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = (select auth.uid())
      and profiles.role in ('technician', 'admin')
  )
)
with check (
  exists (
    select 1 from public.profiles
    where profiles.id = (select auth.uid())
      and profiles.role in ('technician', 'admin')
  )
);

insert into storage.buckets (id, name, public)
values ('ticket-photos', 'ticket-photos', false);

create policy "Technicians manage ticket photos"
on storage.objects for all
to authenticated
using (
  bucket_id = 'ticket-photos'
  and exists (
    select 1 from public.profiles
    where profiles.id = (select auth.uid())
      and profiles.role in ('technician', 'admin')
  )
)
with check (
  bucket_id = 'ticket-photos'
  and exists (
    select 1 from public.profiles
    where profiles.id = (select auth.uid())
      and profiles.role in ('technician', 'admin')
  )
);

insert into public.restaurants (name, area) values
  ('Harbor & Hearth — Downtown', 'Downtown'),
  ('Oak & Stone — Riverside', 'Riverside'),
  ('Northside Kitchen — Market St.', 'Market St.');
