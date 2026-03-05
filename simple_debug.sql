-- Simple debug queries - run these one by one in Supabase SQL Editor

-- 1. Check current authenticated user
SELECT 'CURRENT_USER' as info, auth.uid() as user_id;

-- 2. Get current user details
SELECT 'CURRENT_USER_DETAILS' as info, 
       id::text, name, email, role, status, is_deleted
FROM public.users 
WHERE id = auth.uid();

-- 3. Count all users in database
SELECT 'TOTAL_USERS_COUNT' as info, COUNT(*) as count
FROM public.users;

-- 4. Count active users (not deleted)
SELECT 'ACTIVE_USERS_COUNT' as info, COUNT(*) as count
FROM public.users 
WHERE is_deleted = false;

-- 5. Show all users with their details
SELECT 'ALL_USERS' as info,
       id::text, name, email, role, status, is_deleted, broker_id::text
FROM public.users 
ORDER BY name;

-- 6. Test what the simple RPC should return for admin
SELECT 'ADMIN_VIEW' as info,
       id::text, name, email, role, status, last_login,
       0 as total_orders,
       COALESCE(tokens_balance, 0) as token_balance,
       false as has_flags
FROM public.users 
WHERE is_deleted = false
ORDER BY name;
