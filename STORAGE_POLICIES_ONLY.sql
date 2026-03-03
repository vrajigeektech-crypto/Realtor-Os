-- =====================================================
-- STORAGE POLICIES FOR user_assets BUCKET
-- Run this AFTER creating the bucket in Supabase Dashboard
-- =====================================================

-- Drop any existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Public can view user assets" ON storage.objects;

-- Create proper storage policies for user_assets bucket

-- Policy for uploading files - users can only upload to their own folder
CREATE POLICY "Users can upload their own files" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy for viewing files - users can view their own files
CREATE POLICY "Users can view their own files" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy for updating files - users can update their own files
CREATE POLICY "Users can update their own files" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy for deleting files - users can delete their own files
CREATE POLICY "Users can delete their own files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Since bucket is public, allow anyone to view files
CREATE POLICY "Public can view user assets" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user_assets'
);

-- Grant necessary permissions
GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;
GRANT SELECT ON storage.objects TO anon;
GRANT SELECT ON storage.buckets TO anon;

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Check if policies were created
SELECT name, action, roles
FROM storage.policies 
WHERE bucket_id = 'user_assets'
ORDER BY name;

-- Check bucket configuration
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets 
WHERE name = 'user_assets';

-- Test if you can access storage (run as authenticated user)
SELECT 'Storage access test' as test,
       CASE 
         WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE name = 'user_assets') 
         THEN 'Bucket accessible'
         ELSE 'Bucket not found'
       END as bucket_status;

-- =====================================================
-- TROUBLESHOOTING
-- =====================================================

-- If you still get "Unauthorized" errors:
-- 1. Make sure the bucket is PUBLIC in Supabase Dashboard
-- 2. Make sure you're logged in (auth.uid() should not be null)
-- 3. Check that the file path starts with your user ID: auth.uid() + '/...'
-- 4. Try running: SELECT auth.uid(); to verify your user ID
