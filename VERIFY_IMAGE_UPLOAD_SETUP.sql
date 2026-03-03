-- =====================================================
-- Complete verification for image upload setup
-- Run this to verify everything is configured correctly
-- =====================================================

-- 1. Check if users table exists and has correct columns
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
    AND table_schema = 'public'
    AND column_name IN ('id', 'gallery_urls', 'onboarding_completed', 'onboarding_step')
ORDER BY column_name;

-- 2. Check if user_assets bucket exists and is PUBLIC
SELECT 
    id, 
    name, 
    public, 
    file_size_limit, 
    allowed_mime_types
FROM storage.buckets 
WHERE name = 'user_assets';

-- 3. Check storage policies
SELECT 
    name, 
    action, 
    roles,
    cmd
FROM storage.policies 
WHERE bucket_id = 'user_assets'
ORDER BY name;

-- 4. Check if RPC function exists
SELECT 
    proname as function_name,
    proargnames as argument_names
FROM pg_proc 
WHERE proname = 'complete_onboarding_step';

-- 5. Test if you can access your own files (run as authenticated user)
SELECT 
    name,
    bucket_id,
    created_at,
    size
FROM storage.objects 
WHERE bucket_id = 'user_assets' 
    AND name LIKE (auth.uid()::text || '/%')
ORDER BY created_at DESC
LIMIT 5;

-- 6. Check your user profile data
SELECT 
    id,
    email,
    onboarding_completed,
    onboarding_step,
    gallery_urls,
    logo_url,
    headshot_url
FROM public.users 
WHERE id = auth.uid();

-- 7. Check RLS is enabled on users table
SELECT 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename = 'users';

-- 8. Check RLS is enabled on storage.objects
SELECT 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE schemaname = 'storage' 
    AND tablename = 'objects';
