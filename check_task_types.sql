-- Check what task types are actually in the database
SELECT id, task_type, status, created_at 
FROM automation_tasks 
ORDER BY created_at DESC;

-- Also check if there are any tasks with string types
SELECT COUNT(*) as total_tasks,
       COUNT(CASE WHEN task_type ~ '^[a-z_]+$' THEN 1 END) as string_tasks,
       COUNT(CASE WHEN task_type ~ '^[0-9]+$' THEN 1 END) as numeric_tasks
FROM automation_tasks;
