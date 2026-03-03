-- ============================================================================
-- Setup Existing Auth User as Admin
-- User ID: 0db45541-2b25-4f78-aa5d-56336a6f1dd2
-- Password: 123456
-- ============================================================================

-- Step 1: Create/Update public.users record with admin role
INSERT INTO public.users (
  id,
  email,
  name,
  phone,
  secondary_phone,
  role,
  org_id,
  broker_id,
  team_lead_id,
  status,
  onboarded,
  onboarding_completed,
  onboarding_step,
  is_deleted,
  created_at,
  joined_at,
  last_login,
  last_activity_date,
  logo_url,
  headshot_url,
  writing_sample,
  voice_sample_url,
  gallery_urls,
  gallery_count,
  primary_logo_url,
  primary_headshot_url,
  primary_writing_sample_url,
  primary_voice_sample_url,
  tokens_balance,
  xp_total,
  level,
  current_streak,
  longest_streak
)
SELECT 
  au.id,
  au.email,
  NULL as name,
  NULL as phone,
  NULL as secondary_phone,
  'admin' as role,  -- Set as admin
  NULL as org_id,
  NULL as broker_id,
  NULL as team_lead_id,
  'active' as status,
  false as onboarded,
  false as onboarding_completed,
  0 as onboarding_step,
  false as is_deleted,
  COALESCE(au.created_at, NOW()) as created_at,
  COALESCE(au.created_at, NOW()) as joined_at,
  au.last_sign_in_at as last_login,
  NOW() as last_activity_date,
  NULL as logo_url,
  NULL as headshot_url,
  NULL as writing_sample,
  NULL as voice_sample_url,
  NULL as gallery_urls,
  0 as gallery_count,
  NULL as primary_logo_url,
  NULL as primary_headshot_url,
  NULL as primary_writing_sample_url,
  NULL as primary_voice_sample_url,
  NULL as tokens_balance,
  NULL as xp_total,
  NULL as level,
  NULL as current_streak,
  NULL as longest_streak
FROM auth.users au
WHERE au.id = '0db45541-2b25-4f78-aa5d-56336a6f1dd2'
ON CONFLICT (id) 
DO UPDATE SET
  role = 'admin',  -- Update to admin
  status = 'active',
  email = EXCLUDED.email,
  last_activity_date = NOW();

-- Step 2: Verify the user exists and is linked
SELECT 
  au.id as auth_user_id,
  au.email as auth_email,
  au.created_at as auth_created_at,
  pu.id as public_user_id,
  pu.email as public_email,
  pu.role as public_role,
  pu.status as public_status
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE au.id = '0db45541-2b25-4f78-aa5d-56336a6f1dd2';

-- Step 3: Get the email for reference
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  last_sign_in_at
FROM auth.users
WHERE id = '0db45541-2b25-4f78-aa5d-56336a6f1dd2';

-- Step 4: Update password via Supabase Dashboard
-- Go to Authentication > Users > Find user by ID: 0db45541-2b25-4f78-aa5d-56336a6f1dd2
-- Click "Reset Password" or "Update Password"
-- Set password to: 123456

-- ============================================================================
-- IMPORTANT: Password Update Instructions
-- ============================================================================
-- The password cannot be changed via SQL for security reasons.
-- You must update it using one of these methods:
--
-- METHOD 1: Supabase Dashboard (Easiest)
-- 1. Go to Authentication > Users
-- 2. Find the user with ID: 0db45541-2b25-4f78-aa5d-56336a6f1dd2
-- 3. Click on the user
-- 4. Click "Reset Password" or "Update Password"
-- 5. Set new password: 123456
-- 6. Save
--
-- METHOD 2: Use Supabase Management API
-- POST https://macenrukodfgfeowrqqf.supabase.co/auth/v1/admin/users/0db45541-2b25-4f78-aa5d-56336a6f1dd2
-- Headers:
--   apikey: YOUR_SERVICE_ROLE_KEY
--   Authorization: Bearer YOUR_SERVICE_ROLE_KEY
-- Body:
--   {
--     "password": "123456"
--   }
--
-- METHOD 3: Use Flutter app (if user can sign in with old password)
-- The app will handle password reset if needed
