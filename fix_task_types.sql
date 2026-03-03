-- Update numeric task types to proper string types
UPDATE automation_tasks 
SET task_type = CASE 
    WHEN task_type = '1' THEN 'basic_promotion'
    WHEN task_type = '2' THEN 'standard_promotion' 
    WHEN task_type = '3' THEN 'premium_promotion'
    ELSE 'basic_promotion'
END
WHERE task_type IN ('1', '2', '3');

-- Show the updated results
SELECT id, task_type, status, created_at 
FROM automation_tasks 
ORDER BY created_at DESC;
