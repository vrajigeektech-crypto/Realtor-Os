-- ============================================================================
-- Fix "Database error creating new user" in Supabase Authentication
-- This error usually occurs due to triggers or constraints
-- ============================================================================

-- ============================================================================
-- SOLUTION 1: Temporarily disable triggers (if you have auto-create triggers)
-- ============================================================================

-- Check if there are any triggers on auth.users that might be failing
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users';

-- ============================================================================
-- SOLUTION 2: Create the auth user via SQL (requires service role key)
-- ============================================================================

-- Note: You cannot directly INSERT into auth.users using the anon key
-- You must use one of these methods:

-- METHOD A: Use Supabase Dashboard (Recommended)
-- 1. Go to Authentication > Users
-- 2. Click "Add User" 
-- 3. Fill in:
--    - Email: approver@test.com
--    - Password: TestPassword123!
--    - Auto Confirm User: ON
-- 4. Click "Create User"
-- 5. If it fails, check the error message below

-- METHOD B: Use Supabase Management API (if you have service role key)
-- This requires making an HTTP request, not SQL

-- METHOD C: Use Supabase Auth API from Flutter (signUp)
-- This is what the app tries to do, but it's failing

-- ============================================================================
-- SOLUTION 3: Check for foreign key constraint issues
-- ============================================================================

-- The issue might be that a trigger is trying to INSERT into public.users
-- but failing because of missing fields or constraints

-- Check if there's a trigger that auto-creates public.users record
SELECT 
    tgname as trigger_name,
    pg_get_triggerdef(oid) as trigger_definition
FROM pg_trigger
WHERE tgrelid = 'auth.users'::regclass
  AND tgisinternal = false;

-- ============================================================================
-- SOLUTION 4: Create a function to handle user creation properly
-- ============================================================================

-- This function will be called by a trigger AFTER auth.users is created
-- It ensures public.users record is created with all required fields

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (
    id,
    email,
    role,
    status,
    onboarded,
    onboarding_completed,
    onboarding_step,
    is_deleted,
    created_at,
    joined_at,
    last_activity_date,
    gallery_count
  )
  VALUES (
    NEW.id,
    NEW.email,
    'agent', -- Default role, can be changed
    'active',
    false,
    false,
    0,
    false,
    NOW(),
    NOW(),
    NOW(),
    0
  )
  ON CONFLICT (id) DO NOTHING; -- Don't fail if record already exists
  
  RETURN NEW;
END;
$$;

-- Create the trigger (only if it doesn't exist)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- SOLUTION 5: Grant necessary permissions
-- ============================================================================

-- Ensure the function can insert into public.users
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT INSERT ON public.users TO postgres, anon, authenticated, service_role;

-- ============================================================================
-- SOLUTION 6: Check for existing problematic records
-- ============================================================================

-- Check if there's already a public.users record with this email
-- that might be causing a conflict
SELECT id, email, role, status 
FROM public.users 
WHERE email = 'approver@test.com';

-- If there is one, you might need to delete it first (if safe to do so)
-- DELETE FROM public.users WHERE email = 'approver@test.com';

-- ============================================================================
-- SOLUTION 7: Manual creation workaround
-- ============================================================================

-- If all else fails, create the auth user WITHOUT the trigger,
-- then manually create the public.users record

-- Step 1: Temporarily disable the trigger
-- ALTER TABLE auth.users DISABLE TRIGGER on_auth_user_created;

-- Step 2: Create auth user via Dashboard (should work now)

-- Step 3: Re-enable the trigger
-- ALTER TABLE auth.users ENABLE TRIGGER on_auth_user_created;

-- Step 4: Run link_auth_user.sql to create public.users record
