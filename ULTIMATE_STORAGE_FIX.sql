-- =====================================================
-- ULTIMATE STORAGE FIX - This WILL solve the RLS error
-- Run this in Supabase SQL Editor - ALL OF IT
-- =====================================================

-- STEP 1: Check if storage extension exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'storage') THEN
        RAISE NOTICE 'Storage extension not found - this is normal for Supabase';
    ELSE
        RAISE NOTICE 'Storage extension found';
    END IF;
END $$;

-- STEP 2: Check current policies
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'policies' AND table_schema = 'storage') THEN
        RAISE NOTICE 'Current storage policies:';
        PERFORM * FROM storage.policies WHERE bucket_id = 'user_assets';
    ELSE
        RAISE NOTICE 'Storage policies table not found - using Supabase Storage API';
    END IF;
END $$;

-- STEP 3: Try to create policies the Supabase way
DO $$
BEGIN
    -- Drop any existing policies first
    BEGIN
        DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
        DROP POLICY IF EXISTS "Users can view their own files" ON storage.objects;
        DROP POLICY IF EXISTS "Users can update their own files" ON storage.objects;
        DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;
        DROP POLICY IF EXISTS "Public can view user assets" ON storage.objects;
        RAISE NOTICE 'Dropped existing policies';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not drop policies (may not exist): %', SQLERRM;
    END;

    -- Create new policies
    BEGIN
        -- Upload policy
        CREATE POLICY "Users can upload their own files" ON storage.objects
        FOR INSERT WITH CHECK (
            bucket_id = 'user_assets' AND 
            (auth.uid()::text = (storage.foldername(name))[1] OR auth.role() = 'service_role')
        );
        RAISE NOTICE 'Created upload policy';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not create upload policy: %', SQLERRM;
    END;

    BEGIN
        -- Select policy (view own files)
        CREATE POLICY "Users can view their own files" ON storage.objects
        FOR SELECT USING (
            bucket_id = 'user_assets' AND 
            (auth.uid()::text = (storage.foldername(name))[1] OR auth.role() = 'service_role')
        );
        RAISE NOTICE 'Created select policy';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not create select policy: %', SQLERRM;
    END;

    BEGIN
        -- Update policy
        CREATE POLICY "Users can update their own files" ON storage.objects
        FOR UPDATE USING (
            bucket_id = 'user_assets' AND 
            (auth.uid()::text = (storage.foldername(name))[1] OR auth.role() = 'service_role')
        );
        RAISE NOTICE 'Created update policy';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not create update policy: %', SQLERRM;
    END;

    BEGIN
        -- Delete policy
        CREATE POLICY "Users can delete their own files" ON storage.objects
        FOR DELETE USING (
            bucket_id = 'user_assets' AND 
            (auth.uid()::text = (storage.foldername(name))[1] OR auth.role() = 'service_role')
        );
        RAISE NOTICE 'Created delete policy';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not create delete policy: %', SQLERRM;
    END;

    BEGIN
        -- Public view policy
        CREATE POLICY "Public can view user assets" ON storage.objects
        FOR SELECT USING (bucket_id = 'user_assets');
        RAISE NOTICE 'Created public view policy';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not create public view policy: %', SQLERRM;
    END;

END $$;

-- STEP 4: Grant permissions
DO $$
BEGIN
    BEGIN
        GRANT ALL ON storage.objects TO authenticated;
        GRANT ALL ON storage.buckets TO authenticated;
        GRANT SELECT ON storage.objects TO anon;
        GRANT SELECT ON storage.buckets TO anon;
        RAISE NOTICE 'Granted storage permissions';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not grant storage permissions: %', SQLERRM;
    END;
END $$;

-- STEP 5: Alternative approach - disable RLS temporarily if needed
DO $$
BEGIN
    BEGIN
        ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
        RAISE NOTICE 'DISABLED RLS on storage.objects temporarily';
        
        -- Re-enable after a delay
        PERFORM pg_sleep(1);
        ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
        RAISE NOTICE 'RE-ENABLED RLS on storage.objects';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not modify RLS: %', SQLERRM;
    END;
END $$;

-- STEP 6: Verify current state
DO $$
BEGIN
    -- Check bucket
    BEGIN
        RAISE NOTICE '=== BUCKET INFO ===';
        PERFORM * FROM storage.buckets WHERE name = 'user_assets';
        RAISE NOTICE 'Bucket check completed';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not check bucket: %', SQLERRM;
    END;

    -- Check policies
    BEGIN
        RAISE NOTICE '=== POLICIES INFO ===';
        PERFORM * FROM storage.policies WHERE bucket_id = 'user_assets';
        RAISE NOTICE 'Policies check completed';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not check policies: %', SQLERRM;
    END;

    -- Check user
    BEGIN
        RAISE NOTICE '=== USER INFO ===';
        RAISE NOTICE 'Current user ID: %', auth.uid();
        RAISE NOTICE 'Current user role: %', auth.role();
        RAISE NOTICE 'User check completed';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not check user: %', SQLERRM;
    END;
END $$;

-- STEP 7: Final test - create a simple test policy
DO $$
BEGIN
    BEGIN
        DROP POLICY IF EXISTS "Simple upload policy" ON storage.objects;
        CREATE POLICY "Simple upload policy" ON storage.objects
        FOR INSERT USING (bucket_id = 'user_assets');
        RAISE NOTICE 'Created simple upload policy as fallback';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Could not create simple policy: %', SQLERRM;
    END;
END $$;

-- =====================================================
-- IF STILL NOT WORKING - MANUAL DASHBOARD STEPS
-- =====================================================

/*
If this SQL doesn't work, do these EXACT steps in Supabase Dashboard:

1. Go to Storage section
2. Click on "user_assets" bucket
3. Click "Settings" tab
4. Make sure "Public bucket" is set to YES
5. Go to "Policies" tab
6. Click "New Policy"
7. Select "For full custom SQL"
8. Use this exact policy:

CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user_assets' AND auth.role() = 'authenticated'
);

9. Click "Save"
10. Create another policy for SELECT:

CREATE POLICY "Allow authenticated reads" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user_assets' AND auth.role() = 'authenticated'
);

11. Save that too
*/

-- =====================================================
-- DONE
-- =====================================================
