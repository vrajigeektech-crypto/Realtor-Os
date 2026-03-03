-- ============================================================================
-- Create Auth User for Testing
-- This creates the auth.users entry for the test admin user
-- ============================================================================

-- Note: You cannot directly INSERT into auth.users in Supabase
-- You must use one of these methods:

-- METHOD 1: Use Supabase Dashboard
-- 1. Go to Authentication > Users
-- 2. Click "Add User"
-- 3. Email: approver@test.com
-- 4. Password: (set your test password)
-- 5. Auto Confirm User: ON
-- 6. The user ID will be auto-generated, but you can link it to your public.users record

-- METHOD 2: Use Supabase Management API (if you have service role key)
-- This requires making an API call, not SQL

-- METHOD 3: Use Supabase Auth API from your app
-- See the Flutter code in main.dart for auto-signup

-- ============================================================================
-- After creating the auth user, link it to public.users:
-- ============================================================================

-- If the auth user ID doesn't match, update the public.users record:
-- UPDATE public.users 
-- SET id = (SELECT id FROM auth.users WHERE email = 'approver@test.com')
-- WHERE email = 'approver@test.com';

-- OR if you want to use a specific UUID, create the auth user with that UUID
-- (requires service role access or API call)
