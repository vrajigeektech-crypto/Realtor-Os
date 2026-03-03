-- =====================================================
-- Storage Setup Verification Script
-- Run this to verify storage is properly configured
-- =====================================================

-- Check if user_assets bucket exists
SELECT * FROM storage.buckets WHERE name = 'user_assets';

-- Check storage policies
SELECT * FROM storage.policies WHERE bucket_id = 'user_assets';

-- Test storage permissions (run as authenticated user)
-- This should return your user's folder if properly configured
SELECT name, bucket_id, created_at 
FROM storage.objects 
WHERE bucket_id = 'user_assets' 
AND name LIKE (auth.uid()::text || '/%')
ORDER BY created_at DESC;

-- Check if RLS is enabled on storage
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'storage' 
AND tablename = 'objects';
