-- WORKING SQL TEST - Copy and paste this directly into Supabase SQL Editor

-- Step 1: Get real user IDs (this will work)
SELECT 
    id as user_id,
    email,
    created_at
FROM auth.users 
ORDER BY created_at DESC
LIMIT 3;

-- Step 2: Use your actual user ID to create a test task
-- Copy one of the UUIDs from the query above and replace below
INSERT INTO automation_tasks (user_id, task_type, status) 
VALUES (
    (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1), 
    'test_approval_workflow', 
    'pending'
)
RETURNING id, user_id, task_type, status, created_at;

-- Step 3: Test the admin functions
SELECT * FROM get_pending_tasks_for_admin();

-- Step 4: Test approval (copy the task_id from Step 3 result)
-- Replace the task_id with the actual ID from the query above
SELECT approve_automation_task(
    'YOUR_ACTUAL_TASK_ID_HERE',
    (SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin' LIMIT 1)
);

-- Step 5: Test rejection (optional)
SELECT reject_automation_task(
    'YOUR_ACTUAL_TASK_ID_HERE',
    (SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin' LIMIT 1),
    'Test rejection for demo'
);

-- Step 6: Check final state
SELECT * FROM automation_tasks ORDER BY created_at DESC LIMIT 5;
