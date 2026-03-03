-- Add sample LinkedIn and Instagram tasks for testing
INSERT INTO automation_tasks (id, user_id, task_type, status, created_at)
VALUES 
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'linkedin_post', 'queued', NOW()),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'instagram_story', 'queued', NOW()),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'tiktok_video', 'queued', NOW()),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'facebook_boost', 'queued', NOW());

-- Show all tasks to verify
SELECT id, task_type, status, created_at 
FROM automation_tasks 
WHERE user_id = 'fc6183ec-f307-4a34-a101-e805b6975699'
ORDER BY created_at DESC;
