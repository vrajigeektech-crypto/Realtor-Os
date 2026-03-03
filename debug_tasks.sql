-- Check what task types and costs are actually in the database
SELECT 
    at.id,
    at.task_type,
    at.status,
    at.created_at,
    wc.reserved_amount as token_cost
FROM automation_tasks at
LEFT JOIN wallet_commitments wc ON at.related_commitment_id = wc.id
ORDER BY at.created_at DESC;

-- Also check if there are any LinkedIn/Instagram tasks
SELECT * FROM automation_tasks 
WHERE task_type IN ('linkedin_post', 'instagram_story', 'tiktok_video', 'facebook_boost', 'youtube_tour')
ORDER BY created_at DESC;
