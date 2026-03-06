-- Test script to verify AdminContentApprovalQueueScreen shows live data
-- Run this in Supabase SQL Editor to create test data

-- Step 1: Check if functions exist
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name IN ('get_pending_tasks_for_admin', 'approve_automation_task', 'reject_automation_task')
AND routine_schema = 'public';

-- Step 2: Check if automation_tasks table has pending status constraint
SELECT conname, convalidated 
FROM pg_constraint 
WHERE conrelid = 'automation_tasks'::regclass 
AND conname = 'automation_tasks_status_check';

-- Step 3: Create a test pending task (if none exist)
INSERT INTO automation_tasks (user_id, task_type, status) 
VALUES (
    (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1), 
    'test_admin_queue', 
    'pending'
)
ON CONFLICT DO NOTHING
RETURNING id, user_id, task_type, status, created_at;

-- Step 4: Test the get_pending_tasks_for_admin function
SELECT * FROM get_pending_tasks_for_admin();

-- Step 5: Check all automation_tasks to see current status
SELECT 
    id, 
    user_id, 
    task_type, 
    status, 
    created_at,
    CASE 
        WHEN status = 'pending' THEN '⏳ Pending'
        WHEN status = 'queued' THEN '✅ Approved'
        WHEN status = 'rejected' THEN '❌ Rejected'
        ELSE status
    END as status_display
FROM automation_tasks 
ORDER BY created_at DESC 
LIMIT 10;

-- Step 6: If you want to test approval, run this (replace with actual task_id)
-- SELECT * FROM approve_automation_task(
--     'YOUR_TASK_ID_HERE',
--     (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1)
-- );
