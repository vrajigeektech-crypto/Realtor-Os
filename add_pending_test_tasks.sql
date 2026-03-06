-- Add sample PENDING tasks for admin approval testing
INSERT INTO automation_tasks (id, user_id, task_type, status, created_at)
VALUES 
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'linkedin_post', 'pending', NOW() - INTERVAL '2 hours'),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'instagram_story', 'pending', NOW() - INTERVAL '1 hour'),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'tiktok_video', 'pending', NOW() - INTERVAL '30 minutes'),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'facebook_boost', 'pending', NOW() - INTERVAL '15 minutes'),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'youtube_tour', 'pending', NOW() - INTERVAL '5 minutes');

-- Show all pending tasks to verify
SELECT 
    id, 
    task_type, 
    status, 
    created_at,
    user_id
FROM automation_tasks 
WHERE status = 'pending'
ORDER BY created_at DESC;

-- Test the admin RPC function
SELECT * FROM get_pending_tasks_for_admin();
