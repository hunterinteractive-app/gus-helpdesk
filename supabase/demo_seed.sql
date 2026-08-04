-- Fictional interview-demo data. Safe to run more than once: each case is
-- identified by its unique demo issue description and is never duplicated.
with demo_cases (restaurant_name, area_affected, system_affected, issue_description, additional_details, reporter_name, reporter_contact, quick_checks_completed, status, priority, scheduled_for, resolution_notes, resolved_at, parts_used, follow_up_needed, follow_up_notes) as (
  values
    ('Harbor & Hearth — Downtown', 'Front Counter', 'Point of sale / Payment Terminal', 'DEMO: Front counter payment terminal intermittently declines cards.', 'The terminal reconnects after a restart but drops again during the lunch rush.', 'Jordan Lee', '(555) 014-2031', '["Checked power", "Checked network cable"]'::jsonb, 'planned'::public.ticket_status, 'p2'::public.ticket_priority, now() + interval '45 minutes', null, null, null, false, null),
    ('Oak & Stone — Riverside', 'Drive Through', 'Menu Board', 'DEMO: Drive-through menu board is blank after morning opening.', 'Audio is working. The display stays black even after the local power check.', 'Avery Collins', '(555) 014-2032', '["Checked display power", "Checked cable connection"]'::jsonb, 'open'::public.ticket_status, 'p2'::public.ticket_priority, null, null, null, null, false, null),
    ('Northside Kitchen — Market St.', 'Kitchen', 'Printer', 'DEMO: Kitchen receipt printer is not printing expo tickets.', 'Paper was replaced and the printer is powered on. No tickets appear at the kitchen station.', 'Morgan Reed', '(555) 014-2033', '["Checked paper", "Restarted printer"]'::jsonb, 'in_progress'::public.ticket_status, 'p3'::public.ticket_priority, now() + interval '2 hours', null, null, null, false, null),
    ('Harbor & Hearth — Downtown', 'Back Office', 'Internet', 'DEMO: Back-office internet drops while the guest network remains available.', 'Manager reports the office workstation cannot reach vendor portals.', 'Taylor Brooks', '(555) 014-2034', '["Restarted workstation", "Checked network cable"]'::jsonb, 'waiting_on_parts'::public.ticket_status, 'p3'::public.ticket_priority, null, null, null, null, true, 'Replacement network adapter is on order.'),
    ('Oak & Stone — Riverside', 'Lobby', 'Monitors', 'DEMO: Lobby information monitor shows no input.', 'Screen is powered on and shows the no-signal message.', 'Casey Morgan', '(555) 014-2035', '["Checked monitor power", "Checked HDMI connection"]'::jsonb, 'open'::public.ticket_status, 'p4'::public.ticket_priority, null, null, null, null, false, null),
    ('Northside Kitchen — Market St.', 'Front Counter', 'Point of sale / Payment Terminal', 'DEMO: Counter terminal would not reconnect after an ISP outage.', 'Issue began immediately after the neighborhood outage was restored.', 'Riley Chen', '(555) 014-2036', '["Checked power", "Restarted terminal"]'::jsonb, 'resolved'::public.ticket_status, 'p2'::public.ticket_priority, now() - interval '2 days', 'Rebooted the terminal, confirmed the network lease renewed, then completed a successful test transaction.', now() - interval '2 days' + interval '45 minutes', 'None', false, null),
    ('Harbor & Hearth — Downtown', 'Kitchen', 'Printer', 'DEMO: Kitchen printer was feeding blank receipts.', 'Printer had paper loaded but tickets were unreadable.', 'Jamie Patel', '(555) 014-2037', '["Checked paper", "Restarted printer"]'::jsonb, 'closed'::public.ticket_status, 'p3'::public.ticket_priority, now() - interval '5 days', 'Removed the packing strip that was blocking the thermal print head, reloaded paper, and printed a test ticket.', now() - interval '5 days' + interval '30 minutes', 'Thermal paper roll', false, null),
    ('Oak & Stone — Riverside', 'Drive Through', 'Menu Board', 'DEMO: Drive-through menu board displayed a frozen image.', 'Board remained on one promotional image after the scheduled change.', 'Drew Simmons', '(555) 014-2038', '["Checked display power", "Restarted player"]'::jsonb, 'closed'::public.ticket_status, 'p4'::public.ticket_priority, now() - interval '8 days', 'Restarted the media player, verified the playlist sync, and confirmed the menu changed on schedule.', now() - interval '8 days' + interval '25 minutes', 'None', false, null)
), inserted as (
  insert into public.tickets (
    restaurant_id, restaurant_name, area_affected, system_affected, issue_description,
    additional_details, reporter_name, reporter_contact, quick_checks_completed,
    status, priority, scheduled_for, resolution_notes, resolved_at, parts_used,
    follow_up_needed, follow_up_notes, assigned_to
  )
  select r.id, d.restaurant_name, d.area_affected, d.system_affected, d.issue_description,
    d.additional_details, d.reporter_name, d.reporter_contact, d.quick_checks_completed,
    d.status, d.priority, d.scheduled_for, d.resolution_notes, d.resolved_at, d.parts_used,
    d.follow_up_needed, d.follow_up_notes,
    (select id from public.profiles where role in ('technician', 'admin') order by created_at limit 1)
  from demo_cases d
  join public.restaurants r on r.name = d.restaurant_name
  where not exists (select 1 from public.tickets t where t.issue_description = d.issue_description)
  returning id, restaurant_id, issue_description, system_affected, resolution_notes
)
insert into public.verified_resolutions (ticket_id, title, symptoms, verified_fix, system_affected, restaurant_id, verified_by)
select i.id,
  case when i.system_affected = 'Point of sale / Payment Terminal' then 'Terminal reconnect after ISP outage'
       when i.system_affected = 'Printer' then 'Clear thermal printer blockage'
       else 'Restart media player and confirm menu sync' end,
  i.issue_description,
  i.resolution_notes,
  i.system_affected,
  i.restaurant_id,
  (select id from public.profiles where role in ('technician', 'admin') order by created_at limit 1)
from inserted i
where i.resolution_notes is not null;
