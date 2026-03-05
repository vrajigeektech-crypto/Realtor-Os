-- ============================================================================
-- Check current user and all users in database
-- Run this to debug the user visibility issue
-- ============================================================================

-- Check current authenticated user
SELECT 
  'CURRENT_AUTHENTICATED_USER' as info,
  auth.uid() as user_id,
  auth.jwt() ->> 'role' as jwt_role;

-- Check all users in database
SELECT 
  'ALL_USERS_IN_DATABASE' as info,
  id::text,
  name,
  email,
  role,
  status,
  is_deleted,
  broker_id::text,
  created_at
FROM public.users 
ORDER BY name;

-- Check what the current user should see based on role
SELECT 
  'WHAT_CURRENT_USER_SHOULD_SEE' as info,
  u.role as current_user_role,
  CASE 
    WHEN u.role = 'admin' THEN 'Should see ALL users'
    WHEN u.role = 'broker' THEN 'Should see their agents + themselves'
    ELSE 'Should see only themselves'
  END as expected_visibility,
  COUNT(*) as actual_count
FROM public.users u
WHERE u.id = auth.uid()
GROUP BY u.role, u.id;
