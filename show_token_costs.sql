-- Add sample tasks with proper token costs
INSERT INTO automation_tasks (id, user_id, task_type, status, created_at)
VALUES 
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'linkedin_post', 'queued', NOW()),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'instagram_story', 'queued', NOW()),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'tiktok_video', 'queued', NOW()),
    (gen_random_uuid(), 'fc6183ec-f307-4a34-a101-e805b6975699', 'facebook_boost', 'queued', NOW());

-- Show all tasks with their expected token costs
SELECT 
    at.id,
    at.task_type,
    at.status,
    at.created_at,
    CASE 
        WHEN at.task_type = 'linkedin_post' THEN 10
        WHEN at.task_type = 'instagram_story' THEN 8
        WHEN at.task_type = 'tiktok_video' THEN 15
        WHEN at.task_type = 'facebook_boost' THEN 18
        WHEN at.task_type = 'youtube_tour' THEN 30
        WHEN at.task_type = 'email_blast' THEN 14
        WHEN at.task_type = 'google_ads' THEN 35
        WHEN at.task_type = 'social_blast' THEN 12
        WHEN at.task_type = 'premium_visibility' THEN 25
        WHEN at.task_type = 'featured_listing' THEN 20
        WHEN at.task_type = '1' OR at.task_type = 'basic_promotion' THEN 10
        WHEN at.task_type = '2' OR at.task_type = 'standard_promotion' THEN 15
        WHEN at.task_type = '3' OR at.task_type = 'premium_promotion' THEN 20
        ELSE 10
    END as expected_token_cost
FROM automation_tasks at
WHERE at.user_id = 'fc6183ec-f307-4a34-a101-e805b6975699'
ORDER BY at.created_at DESC;
