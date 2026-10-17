-- Fix profile picture uploads.
--
-- uploadProfileImage() writes to the `profile-images` bucket with
-- FileOptions(upsert: true), so every upload sends `x-upsert: true`. Supabase
-- Storage requires INSERT + SELECT + UPDATE policies for upserts and DELETE for
-- the orphan-cleanup path. Without these, the upload fails with a generic error
-- and the Edit Profile save never reaches the `profiles` UPDATE.
--
-- Run this in the project SQL editor (or commit + `supabase db push`).

-- Public bucket: avatars are rendered via getPublicUrl().
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'profile-images',
  'profile-images',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
)
on conflict (id) do update set
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[];

-- Users may only touch files inside their own {USER_ID}/ folder.
create policy "Profile images: upload own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'profile-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "Profile images: read own"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'profile-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "Profile images: update own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'profile-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'profile-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "Profile images: delete own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'profile-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- product-images bucket: fix uppercase MIME types (case-sensitive).
-- Keeps existing public/private setting untouched.
update storage.buckets
set allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
where id = 'product-images';