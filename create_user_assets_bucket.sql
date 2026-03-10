-- Create Supabase Storage bucket used by the app (`user_assets`)
-- Fixes: {"statusCode":"404","error":"Bucket not found"}
--
-- Run once in Supabase SQL Editor.

-- 1) Create bucket (PUBLIC) if missing
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'user_assets',
  'user_assets',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 2) Storage policies (safe re-create)
DROP POLICY IF EXISTS "Users can upload their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Public can view user assets" ON storage.objects;

-- Upload into: <userId>/...
CREATE POLICY "Users can upload their own assets" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user_assets' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Owners can read their own
CREATE POLICY "Users can view their own assets" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user_assets' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Owners can update their own
CREATE POLICY "Users can update their own assets" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'user_assets' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Owners can delete their own
CREATE POLICY "Users can delete their own assets" ON storage.objects
FOR DELETE USING (
  bucket_id = 'user_assets' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Since the bucket is public, allow public read (needed for Image.network public URLs)
CREATE POLICY "Public can view user assets" ON storage.objects
FOR SELECT USING (bucket_id = 'user_assets');

