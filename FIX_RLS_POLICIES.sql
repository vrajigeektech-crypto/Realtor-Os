-- =====================================================
-- FIX RLS POLICIES FOR STORAGE
-- Run this in Supabase SQL Editor
-- This will fix the "Unauthorized" error
-- =====================================================

-- First, let's see what policies exist
SELECT name, action, roles, cmd
FROM storage.policies 
WHERE bucket_id = 'user_assets';

-- Drop all existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own assets" ON storage.objects;
DROP POLICY IF EXISTS "Public can view user assets" ON storage.objects;

-- Create the correct policies
-- Policy 1: Allow users to upload to their own folder
CREATE POLICY "Users can upload their own files" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy 2: Allow users to view their own files
CREATE POLICY "Users can view their own files" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy 3: Allow users to update their own files
CREATE POLICY "Users can update their own files" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy 4: Allow users to delete their own files
CREATE POLICY "Users can delete their own files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy 5: Allow public viewing (since bucket is public)
CREATE POLICY "Public can view user assets" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user_assets'
);

-- Grant permissions
GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;
GRANT SELECT ON storage.objects TO anon;
GRANT SELECT ON storage.buckets TO anon;

-- Verify policies were created
SELECT name, action, roles, cmd
FROM storage.policies 
WHERE bucket_id = 'user_assets'
ORDER BY name;

-- Check bucket is public
SELECT id, name, public, file_size_limit
FROM storage.buckets 
WHERE name = 'user_assets';

-- Test if current user can access storage
SELECT auth.uid() as current_user_id;

-- Test if user folder path would work
SELECT auth.uid()::text || '/test.png' as test_path;
