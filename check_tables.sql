-- Check what tables actually exist in the database
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check if there are any task-related tables with different names
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_schema = 'public'
AND (table_name LIKE '%task%' OR table_name LIKE '%order%')
ORDER BY table_name;

-- Check automation_tasks table structure specifically
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'automation_tasks' 
AND table_schema = 'public'
ORDER BY ordinal_position;
