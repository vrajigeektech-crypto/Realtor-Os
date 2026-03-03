-- =====================================================
-- COMPLETE IMAGE UPLOAD FIX - FIXED VERSION
-- Run this entire script in Supabase SQL Editor
-- Fixes all issues with image upload in onboarding flow
-- =====================================================

-- First, ensure storage extension is enabled
CREATE EXTENSION IF NOT EXISTS "storage";

-- 1. Create the missing public.users table (if not exists)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  phone TEXT,
  secondary_phone TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'agent', 'broker', 'user')),
  org_id UUID,
  broker_id UUID REFERENCES public.users(id),
  team_lead_id UUID REFERENCES public.users(id),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'pending')),
  onboarded BOOLEAN DEFAULT false,
  onboarding_completed BOOLEAN DEFAULT false,
  onboarding_step INTEGER DEFAULT 0,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  joined_at TIMESTAMP WITH TIME ZONE,
  last_login TIMESTAMP WITH TIME ZONE,
  last_activity_date TIMESTAMP WITH TIME ZONE,
  logo_url TEXT,
  headshot_url TEXT,
  writing_sample TEXT,
  voice_sample_url TEXT,
  gallery_urls TEXT[],
  gallery_count INTEGER DEFAULT 0,
  primary_logo_url TEXT,
  primary_headshot_url TEXT,
  primary_writing_sample_url TEXT,
  primary_voice_sample_url TEXT,
  tokens_balance DECIMAL(10,2) DEFAULT 0.00,
  xp_total INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0
);

-- 2. Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS policies for users table
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- 4. Create auto-create user function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.users (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- 5. Create trigger for auto user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6. Updated_at trigger for users table
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON public.users 
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 7. Create user_assets storage bucket (PUBLIC)
-- Only create if storage extension is available
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'storage') THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES ('user_assets', 'user_assets', true, 52428800, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
        ON CONFLICT (id) DO UPDATE SET
            public = true,
            file_size_limit = 52428800,
            allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        
        RAISE NOTICE 'Storage bucket created/updated successfully';
    ELSE
        RAISE NOTICE 'Storage extension not available - skipping bucket creation';
    END IF;
END $$;

-- 8. Create storage policies only if storage extension exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'storage') THEN
        -- Drop any existing storage policies to avoid conflicts
        DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
        DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
        DROP POLICY IF EXISTS "Users can update their own files" ON storage.objects;
        DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;
        DROP POLICY IF EXISTS "Users can upload their own assets" ON storage.objects;
        DROP POLICY IF EXISTS "Users can view their own assets" ON storage.objects;
        DROP POLICY IF EXISTS "Users can update their own assets" ON storage.objects;
        DROP POLICY IF EXISTS "Public can view user assets" ON storage.objects;

        -- Create proper storage policies for PUBLIC bucket
        CREATE POLICY "Users can upload their own files" ON storage.objects
        FOR INSERT WITH CHECK (
          bucket_id = 'user_assets' AND 
          auth.uid()::text = (storage.foldername(name))[1]
        );

        CREATE POLICY "Users can view their own files" ON storage.objects
        FOR SELECT USING (
          bucket_id = 'user_assets' AND 
          auth.uid()::text = (storage.foldername(name))[1]
        );

        CREATE POLICY "Users can update their own files" ON storage.objects
        FOR UPDATE USING (
          bucket_id = 'user_assets' AND 
          auth.uid()::text = (storage.foldername(name))[1]
        );

        CREATE POLICY "Users can delete their own files" ON storage.objects
        FOR DELETE USING (
          bucket_id = 'user_assets' AND 
          auth.uid()::text = (storage.foldername(name))[1]
        );

        -- Allow public access to view files (since bucket is public)
        CREATE POLICY "Public can view user assets" ON storage.objects
        FOR SELECT USING (
          bucket_id = 'user_assets'
        );
        
        RAISE NOTICE 'Storage policies created successfully';
    ELSE
        RAISE NOTICE 'Storage extension not available - skipping policy creation';
    END IF;
END $$;

-- 9. Create the missing complete_onboarding_step RPC function
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

-- 10. Create user record for existing demo user if exists
INSERT INTO public.users (id, email, created_at)
SELECT id, email, created_at FROM auth.users WHERE email = 'demo@gmail.com'
ON CONFLICT (id) DO NOTHING;

-- 11. Grant necessary permissions
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.users TO service_role;

-- Grant storage permissions only if storage extension exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'storage') THEN
        GRANT ALL ON storage.objects TO authenticated;
        GRANT ALL ON storage.buckets TO authenticated;
        GRANT SELECT ON storage.objects TO anon;
        GRANT SELECT ON storage.buckets TO anon;
        RAISE NOTICE 'Storage permissions granted successfully';
    ELSE
        RAISE NOTICE 'Storage extension not available - skipping storage permissions';
    END IF;
END $$;

GRANT EXECUTE ON FUNCTION complete_onboarding_step TO authenticated;
GRANT EXECUTE ON FUNCTION complete_onboarding_step TO service_role;

-- =====================================================
-- VERIFICATION QUERIES (run these after the script completes)
-- =====================================================

-- Verify users table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
    AND table_schema = 'public'
    AND column_name IN ('id', 'gallery_urls', 'onboarding_completed', 'onboarding_step')
ORDER BY column_name;

-- Verify storage extension and bucket
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'storage') 
        THEN 'Storage extension: ENABLED'
        ELSE 'Storage extension: NOT AVAILABLE'
    END as storage_status;

-- Only check bucket if storage is available
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'storage') THEN
        RAISE NOTICE 'Checking storage bucket...';
        PERFORM * FROM storage.buckets WHERE name = 'user_assets';
        IF FOUND THEN
            RAISE NOTICE 'user_assets bucket exists';
        ELSE
            RAISE NOTICE 'user_assets bucket NOT found';
        END IF;
    END IF;
END $$;

-- Verify RPC function exists
SELECT proname as function_name, proargnames as argument_names
FROM pg_proc 
WHERE proname = 'complete_onboarding_step';

-- Check your user profile (run as authenticated user)
SELECT id, email, onboarding_completed, onboarding_step, gallery_urls
FROM public.users 
WHERE id = auth.uid();

-- =====================================================
-- SCRIPT COMPLETE
-- =====================================================

-- If storage extension is not available, you need to:
-- 1. Go to Supabase Dashboard
-- 2. Project Settings -> Database
-- 3. Extensions
-- 4. Enable "storage" extension
-- 5. Then run the storage-related parts separately
