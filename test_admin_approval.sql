-- Test the admin approval service
-- Check if admin user has correct role
SELECT 
    email,
    raw_user_meta_data,
    raw_user_meta_data->>'role' as role,
    raw_user_meta_data->>'is_admin' as is_admin,
    raw_user_meta_data->>'is_super_admin' as is_super_admin
FROM auth.users 
WHERE email = 'admin@gmail.com';

-- Test the get_pending_tasks_for_admin function
SELECT * FROM get_pending_tasks_for_admin();

-- Check if there are any pending tasks
SELECT 
    id,
    task_type,
    status,
    created_at,
    user_id
FROM automation_tasks 
WHERE status = 'pending' 
ORDER BY created_at DESC;
