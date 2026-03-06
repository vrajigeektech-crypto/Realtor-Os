-- Get real user IDs to use for testing
-- Run this first to get actual user IDs

SELECT 
    id,
    email,
    created_at,
    raw_user_meta_data
FROM auth.users 
ORDER BY created_at DESC
LIMIT 5;

-- Then use one of these IDs in the test query below:
-- Replace 'ACTUAL_USER_ID_HERE' with a real UUID from the query above

INSERT INTO automation_tasks (user_id, task_type, status) 
VALUES ('ACTUAL_USER_ID_HERE', 'test_approval_workflow', 'pending')
RETURNING id, user_id, task_type, status, created_at;

-- Test getting pending tasks
SELECT * FROM get_pending_tasks_for_admin();
