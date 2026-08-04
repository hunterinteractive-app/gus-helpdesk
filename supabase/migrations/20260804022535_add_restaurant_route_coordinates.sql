-- Coordinates support a technician-only, straight-line route estimate.
-- These points are intentionally fictional demo locations, not real stores.
alter table public.restaurants
  add column latitude double precision,
  add column longitude double precision;

update public.restaurants
set latitude = 39.7684, longitude = -86.1581
where name = 'Harbor & Hearth — Downtown';

update public.restaurants
set latitude = 39.7812, longitude = -86.1329
where name = 'Oak & Stone — Riverside';

update public.restaurants
set latitude = 39.7548, longitude = -86.1743
where name = 'Northside Kitchen — Market St.';
