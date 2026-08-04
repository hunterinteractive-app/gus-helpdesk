-- Keep crew-uploaded images private while allowing the public Help Desk to
-- attach a limited set of photos to the ticket it just created.

update storage.buckets
set
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']
where id = 'ticket-photos';

grant insert on public.ticket_attachments to anon;

create policy "Public can register a ticket photo"
on public.ticket_attachments for insert
to anon
with check (
  ticket_id is not null
  and storage_path like ticket_id::text || '/%'
  and char_length(original_filename) between 1 and 255
  and bytes > 0
  and bytes <= 5242880
  and mime_type in ('image/jpeg', 'image/png', 'image/webp')
);

create policy "Public can upload private ticket photos"
on storage.objects for insert
to anon
with check (
  bucket_id = 'ticket-photos'
  and (storage.foldername(name))[1] ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
);
