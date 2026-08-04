alter table public.tickets
  add column reporter_position text
  check (reporter_position is null or reporter_position in ('Crew', 'Manager', 'General Manager', 'Supervisor/Owner'));
