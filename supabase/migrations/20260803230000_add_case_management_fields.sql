-- Technician closeout details. Public Help Desk submissions cannot write these fields.

alter table public.tickets
  add column parts_used text,
  add column follow_up_needed boolean not null default false,
  add column follow_up_notes text;

grant update on public.verified_resolutions to authenticated;
