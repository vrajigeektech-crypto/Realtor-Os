-- =====================================================
-- SIMPLE STORAGE FIX - Works with Supabase Native Storage
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Complete users table and RPC function (run this first)
CREATE OR REPLACE FUNCTION complete_onboarding_step(
    p_step TEXT,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update the user's onboarding step
    UPDATE public.users 
    SET 
        onboarding_step = LEAST(onboarding_step + 1, 6),
        updated_at = NOW()
    WHERE id = p_user_id;
    
    -- If this is the final step (photos upload), mark onboarding as complete
    IF p_step = 'upload_selfies' THEN
        UPDATE public.users 
        SET 
            onboarding_completed = true,
            onboarded = true,
            updated_at = NOW()
        WHERE id = p_user_id;
    END IF;
    
    RAISE LOG 'Onboarding step completed: % for user %', p_step, p_user_id;
END;
$$;

-- Grant permissions for RPC function
GRANT EXECUTE ON FUNCTION complete_onboarding_step TO authenticated;
GRANT EXECUTE ON FUNCTION complete_onboarding_step TO service_role;

-- =====================================================
-- MANUAL STORAGE SETUP REQUIRED
-- =====================================================

-- YOU MUST DO THESE STEPS IN SUPABASE DASHBOARD:

-- STEP 1: Create Storage Bucket
-- 1. Go to https://supabase.com/dashboard/project/your-project-id/storage
-- 2. Click "New bucket"
-- 3. Name: user_assets
-- 4. Public bucket: YES (very important!)
-- 5. File size limit: 52428800 (50MB)
-- 6. Allowed MIME types: image/jpeg, image/png, image/gif, image/webp
-- 7. Click "Save"

-- STEP 2: Set up Storage Policies
-- After creating the bucket, go to:
-- Storage → user_assets → Policies
-- Click "New Policy" and create these policies:

-- POLICY 1: Allow authenticated users to upload
-- Name: "Users can upload their own files"
-- Allowed operation: INSERT
-- Policy definition: 
-- bucket_id = 'user_assets' AND auth.uid()::text = (storage.foldername(name))[1]

-- POLICY 2: Allow authenticated users to view their own files  
-- Name: "Users can view their own files"
-- Allowed operation: SELECT
-- Policy definition:
-- bucket_id = 'user_assets' AND auth.uid()::text = (storage.foldername(name))[1]

-- POLICY 3: Allow public to view all files (since bucket is public)
-- Name: "Public can view user assets"  
-- Allowed operation: SELECT
-- Policy definition:
-- bucket_id = 'user_assets'

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Check if RPC function exists
SELECT proname as function_name, proargnames as argument_names
FROM pg_proc 
WHERE proname = 'complete_onboarding_step';

-- Check your user profile
SELECT id, email, onboarding_completed, onboarding_step, gallery_urls
FROM public.users 
WHERE id = auth.uid();

-- Check if you're authenticated
SELECT auth.uid() as current_user_id;

-- =====================================================
-- IMPORTANT NOTES
-- =====================================================

-- 1. The storage extension errors are normal - Supabase uses its own storage system
-- 2. You MUST create the bucket in the Dashboard first
-- 3. You MUST set the bucket to PUBLIC for image URLs to work
-- 4. The policies MUST be created through the Dashboard UI
-- 5. After these steps, image upload should work

-- =====================================================
-- TEST YOUR SETUP
-- =====================================================

-- After completing the manual steps, test by:
-- 1. Logging into your app
-- 2. Going to onboarding flow
-- 3. Trying to upload photos
-- 4. Check browser console for upload progress messages
