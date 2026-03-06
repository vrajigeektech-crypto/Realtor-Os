-- Test adding a pending task to see if it appears in admin panel
INSERT INTO automation_tasks (
    id, 
    user_id, 
    task_type, 
    status, 
    created_at, 
    updated_at
) VALUES (
    gen_random_uuid(),
    'fc6183ec-f307-4a34-a101-e805b6975699', -- Using the test user ID
    '1', -- TikTok task type
    'pending',
    NOW(),
    NOW()
);

-- Check if the task was inserted
SELECT * FROM automation_tasks WHERE status = 'pending' ORDER BY created_at DESC;
