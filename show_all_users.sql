-- Show all users with their approved queue counts
-- Run this to verify the data is working correctly

SELECT 
    u.id,
    u.name,
    u.email,
    u.role,
    u.status,
    -- Total orders (all automation tasks)
    (SELECT COUNT(*)::int 
     FROM public.automation_tasks at 
     WHERE at.user_id = u.id) as total_orders,
    -- Approved queue count (only queued tasks)
    (SELECT COUNT(*)::int 
     FROM public.automation_tasks at 
     WHERE at.user_id = u.id AND at.status = 'queued') as approved_queue_count,
    u.last_login,
    u.created_at
FROM public.users u 
WHERE u.is_deleted = false 
ORDER BY u.name;
