-- Editable choices for the public Help Desk. Tickets retain their text values
-- so historical records remain accurate if a choice is later renamed.

create table public.affected_areas (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  display_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.technology_systems (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  display_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.affected_areas enable row level security;
alter table public.technology_systems enable row level security;

grant select on public.affected_areas, public.technology_systems to anon, authenticated;

create policy "Anyone can view active affected areas"
on public.affected_areas for select
to anon, authenticated
using (active = true);

create policy "Anyone can view active technology systems"
on public.technology_systems for select
to anon, authenticated
using (active = true);

insert into public.affected_areas (name, display_order) values
  ('Lobby', 10),
  ('Front Counter', 20),
  ('Drive Through', 30),
  ('Kitchen', 40),
  ('Delivery', 50),
  ('Back Office', 60);

insert into public.technology_systems (name, display_order) values
  ('Point of sale / Payment Terminal', 10),
  ('Internet', 20),
  ('Printer', 30),
  ('Menu Board', 40),
  ('Monitors', 50),
  ('Bump Bar', 60),
  ('QSR Cash & Inventory', 70),
  ('POS Close', 80),
  ('Equipment Order', 90);
