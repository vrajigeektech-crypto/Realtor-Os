-- ============================================================================
-- Set All Users Role to Agent
-- Updates all users to have 'agent' role
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

-- Update all users to agent role (except admins if you want to keep them)
UPDATE public.users 
SET role = 'agent' 
WHERE is_deleted = false 
  AND role != 'admin';  -- Remove this line if you want to change admins too

-- If you want to change ALL users (including admins) to agent, use this instead:
-- UPDATE public.users SET role = 'agent' WHERE is_deleted = false;

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
