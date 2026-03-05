-- ============================================================================
-- Set ALL Users (Including Admins) Role to Agent
-- Updates EVERY user to have 'agent' role
-- ============================================================================

-- First, show current roles before update
SELECT 
  'CURRENT_ROLES_BEFORE_UPDATE' as info,
  role,
  COUNT(*) as user_count,
  STRING_AGG(name, ', ' ORDER BY name) as users
FROM public.users 
WHERE is_deleted = false
GROUP BY role
ORDER BY user_count DESC;

-- Update ALL users to agent role (including admins)
UPDATE public.users 
SET role = 'agent' 
WHERE is_deleted = false;

-- Show results after update
SELECT 
  'ROLES_AFTER_UPDATE' as info,
  role,
  COUNT(*) as user_count,
  STRING_AGG(name, ', ' ORDER BY name) as users
FROM public.users 
WHERE is_deleted = false
GROUP BY role
ORDER BY user_count DESC;

-- Show individual users with their new roles
SELECT 
  'UPDATED_USERS' as info,
  id::text,
  name,
  email,
  role,
  status,
  updated_at
FROM public.users 
WHERE is_deleted = false
ORDER BY name;
