-- Fix RLS policy to properly check for admin role
-- The policy should check for both 'admin' and 'Super Admin' roles

-- Drop existing policies
DROP POLICY IF EXISTS "Admins can view all automation tasks" ON automation_tasks;
DROP POLICY IF EXISTS "Admins can update automation tasks" ON automation_tasks;

-- Recreate policies with proper role checking
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

-- Verify policies were created
SELECT 'RLS policies updated successfully!' as status;
