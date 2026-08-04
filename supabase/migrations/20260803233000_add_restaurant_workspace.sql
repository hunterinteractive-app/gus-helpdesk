-- Private Technician-side restaurant context. All seed values are fictional demo data.

alter table public.restaurants
  add column internet_provider text,
  add column operations_notes text;

create table public.restaurant_contacts (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants(id) on delete cascade,
  full_name text not null,
  role text,
  phone text,
  email text,
  is_primary boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.assets (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants(id) on delete cascade,
  name text not null,
  category text,
  asset_tag text,
  serial_number text,
  installed_on date,
  warranty_expires date,
  status text not null default 'active',
  notes text,
  created_at timestamptz not null default now()
);

create index restaurant_contacts_restaurant_idx on public.restaurant_contacts (restaurant_id);
create index assets_restaurant_idx on public.assets (restaurant_id);

alter table public.restaurant_contacts enable row level security;
alter table public.assets enable row level security;

grant insert, update, delete on public.restaurants to authenticated;
grant select, insert, update, delete on public.restaurant_contacts, public.assets to authenticated;

create policy "Technicians manage restaurants"
on public.restaurants for all to authenticated
using (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')))
with check (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')));

create policy "Technicians manage restaurant contacts"
on public.restaurant_contacts for all to authenticated
using (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')))
with check (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')));

create policy "Technicians manage assets"
on public.assets for all to authenticated
using (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')))
with check (exists (select 1 from public.profiles where profiles.id = (select auth.uid()) and profiles.role in ('technician','admin')));

update public.restaurants set address = '101 River Ave', internet_provider = 'DemoNet Fiber', operations_notes = 'Front counter controller is in the locked manager cabinet.' where name = 'Harbor & Hearth — Downtown';
update public.restaurants set address = '44 Riverside Blvd', internet_provider = 'DemoNet Fiber', operations_notes = 'Receipt printer spare paper is stored under the host stand.' where name = 'Oak & Stone — Riverside';
update public.restaurants set address = '810 Market St.', internet_provider = 'DemoNet Cable', operations_notes = 'Kitchen controller is mounted beside the expo screen.' where name = 'Northside Kitchen — Market St.';

insert into public.restaurant_contacts (restaurant_id, full_name, role, phone, email, is_primary)
select id, 'Jordan Lee', 'General Manager', '(555) 014-2031', 'jordan.lee@example.test', true from public.restaurants where name = 'Harbor & Hearth — Downtown'
union all select id, 'Casey Morgan', 'Assistant Manager', '(555) 014-2048', 'casey.morgan@example.test', true from public.restaurants where name = 'Oak & Stone — Riverside'
union all select id, 'Avery Brooks', 'General Manager', '(555) 014-2056', 'avery.brooks@example.test', true from public.restaurants where name = 'Northside Kitchen — Market St.';

insert into public.assets (restaurant_id, name, category, asset_tag, serial_number, installed_on, status, notes)
select id, 'Front counter payment terminal', 'POS', 'DEMO-HH-001', 'DEMO-PT-1842', date '2026-01-12', 'active', 'Demo asset' from public.restaurants where name = 'Harbor & Hearth — Downtown'
union all select id, 'Receipt printer', 'Printer', 'DEMO-OS-002', 'DEMO-RP-5291', date '2025-11-08', 'active', 'Demo asset' from public.restaurants where name = 'Oak & Stone — Riverside'
union all select id, 'Expo bump bar', 'Kitchen display', 'DEMO-NK-003', 'DEMO-BB-7740', date '2026-02-16', 'active', 'Demo asset' from public.restaurants where name = 'Northside Kitchen — Market St.';
