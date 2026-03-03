-- ============================================================================
-- Link Auth User to Public Users Table
-- Run this AFTER creating the auth user in Supabase Dashboard
-- ============================================================================

-- Step 1: Create/Update the public.users record with the auth user's ID
-- This will use whatever UUID was generated when you created the auth user
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
  au.id,  -- Use the auth user's ID
  au.email,
  NULL as name,
  NULL as phone,
  NULL as secondary_phone,
  'admin' as role,
  NULL as org_id,
  NULL as broker_id,
  NULL as team_lead_id,
  'active' as status,
  false as onboarded,
  false as onboarding_completed,
  0 as onboarding_step,
  false as is_deleted,
  au.created_at,
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
WHERE au.email = 'approver@test.com'
ON CONFLICT (id) 
DO UPDATE SET
  email = EXCLUDED.email,
  role = EXCLUDED.role,
  status = EXCLUDED.status,
  last_activity_date = EXCLUDED.last_activity_date;

-- Step 2: Verify the link
SELECT 
  au.id as auth_user_id,
  au.email as auth_email,
  pu.id as public_user_id,
  pu.email as public_email,
  pu.role,
  pu.status
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE au.email = 'approver@test.com';
