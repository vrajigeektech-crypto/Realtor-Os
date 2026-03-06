-- Debug script to test get_users_list function
-- Run this in Supabase SQL Editor to identify issues

-- 1. Check if automation_tasks table exists
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_name = 'automation_tasks' 
AND table_schema = 'public';

-- 2. Check automation_tasks table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'automation_tasks' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Check if tasks table exists (for total_orders)
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_name = 'tasks' 
AND table_schema = 'public';

-- 4. Check tasks table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tasks' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 5. Test a simple version first
SELECT 
    u.id,
    u.name,
    u.email,
    COUNT(t.id) as total_orders_test
FROM public.users u
LEFT JOIN public.tasks t ON t.user_id = u.id
WHERE u.is_deleted = false
GROUP BY u.id, u.name, u.email
LIMIT 5;

-- 6. Test automation_tasks join
SELECT 
    u.id,
    u.name,
    COUNT(at.id) as approved_queue_test
FROM public.users u
LEFT JOIN public.automation_tasks at ON at.user_id = u.id AND at.status = 'queued'
WHERE u.is_deleted = false
GROUP BY u.id, u.name, u.email
LIMIT 5;

-- 7. Test the function with error handling
DO $$
BEGIN
    -- Try to call the function and catch any errors
    PERFORM public.get_users_list();
    RAISE NOTICE 'Function executed successfully';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error in get_users_list: %', SQLERRM;
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
END $$;
