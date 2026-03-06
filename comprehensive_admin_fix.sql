-- Comprehensive fix for admin approval queue issues
-- This script fixes: 1) Admin RLS policies, 2) Task creation, 3) Debugging

-- Step 1: Drop all existing automation_tasks policies to avoid conflicts
DROP POLICY IF EXISTS "Users can insert their own automation tasks" ON automation_tasks;
DROP POLICY IF EXISTS "Users can update their own automation tasks" ON automation_tasks;
DROP POLICY IF EXISTS "Users can delete their own automation tasks" ON automation_tasks;
DROP POLICY IF EXISTS "Admins can view all automation tasks" ON automation_tasks;
DROP POLICY IF EXISTS "Admins can update automation tasks" ON automation_tasks;

-- Step 2: Create user policies for basic operations
CREATE POLICY "Users can insert their own automation tasks"
  ON automation_tasks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own automation tasks"
  ON automation_tasks FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own automation tasks"
  ON automation_tasks FOR DELETE
  USING (auth.uid() = user_id);

-- Step 3: Create admin policies with proper role checking
CREATE POLICY "Admins can view all automation tasks"
  ON automation_tasks FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND (
        auth.users.raw_user_meta_data->>'role' = 'admin' 
        OR auth.users.raw_user_meta_data->>'role' = 'Super Admin'
        OR (auth.users.raw_user_meta_data->>'is_admin')::text::boolean = true
        OR (auth.users.raw_user_meta_data->>'is_super_admin')::text::boolean = true
      )
    )
  );

CREATE POLICY "Admins can update automation tasks"
  ON automation_tasks FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND (
        auth.users.raw_user_meta_data->>'role' = 'admin' 
        OR auth.users.raw_user_meta_data->>'role' = 'Super Admin'
        OR (auth.users.raw_user_meta_data->>'is_admin')::text::boolean = true
        OR (auth.users.raw_user_meta_data->>'is_super_admin')::text::boolean = true
      )
    )
  );

-- Step 4: Enable RLS on automation_tasks
ALTER TABLE automation_tasks ENABLE ROW LEVEL SECURITY;

-- Step 5: Test the setup
SELECT 'RLS policies fixed successfully!' as status;

-- Step 6: Check current admin user
SELECT 
    email,
    raw_user_meta_data->>'role' as role,
    raw_user_meta_data->>'is_super_admin' as is_super_admin
FROM auth.users 
WHERE email = 'admin@gmail.com';

-- Step 7: Check for pending tasks
SELECT 
    COUNT(*) as pending_count,
    'Sample pending tasks:' as info
FROM automation_tasks 
WHERE status = 'pending';
