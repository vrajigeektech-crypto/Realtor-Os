-- Update automation_tasks table to support approval workflow
-- Add 'pending' and 'rejected' statuses

-- First, update the check constraint to include new statuses
ALTER TABLE automation_tasks 
DROP CONSTRAINT IF EXISTS automation_tasks_status_check;

ALTER TABLE automation_tasks 
ADD CONSTRAINT automation_tasks_status_check 
CHECK (status IN ('pending', 'queued', 'running', 'completed', 'failed', 'rejected'));

-- Create RPC function for admin approval
CREATE OR REPLACE FUNCTION approve_automation_task(
    p_task_id UUID,
    p_admin_user_id UUID
)
RETURNS TABLE (
    task_id UUID,
    user_id UUID,
    task_type TEXT,
    status TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update task status to 'queued' (approved and ready for processing)
    UPDATE automation_tasks 
    SET 
        status = 'queued',
        created_at = NOW() -- Update timestamp to reflect approval time
    WHERE 
        id = p_task_id AND 
        status = 'pending'
    RETURNING 
        id as task_id,
        user_id,
        task_type,
        status,
        created_at,
        created_at as updated_at;
END;
$$;

-- Create RPC function for admin rejection
CREATE OR REPLACE FUNCTION reject_automation_task(
    p_task_id UUID,
    p_admin_user_id UUID,
    p_rejection_reason TEXT DEFAULT 'Rejected by admin'
)
RETURNS TABLE (
    task_id UUID,
    user_id UUID,
    task_type TEXT,
    status TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    rejection_reason TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update task status to 'rejected'
    UPDATE automation_tasks 
    SET 
        status = 'rejected',
        created_at = NOW() -- Update timestamp to reflect rejection time
    WHERE 
        id = p_task_id AND 
        status = 'pending'
    RETURNING 
        id as task_id,
        user_id,
        task_type,
        status,
        created_at,
        created_at as updated_at,
        p_rejection_reason as rejection_reason;
END;
$$;

-- Create RPC function to get all pending tasks for admin approval
CREATE OR REPLACE FUNCTION get_pending_tasks_for_admin()
RETURNS TABLE (
    task_id UUID,
    user_id UUID,
    task_type TEXT,
    status TEXT,
    created_at TIMESTAMPTZ,
    user_email TEXT,
    user_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Return all pending tasks with user information
    RETURN QUERY
    SELECT 
        t.id as task_id,
        t.user_id,
        t.task_type,
        t.status,
        t.created_at,
        u.email as user_email,
        COALESCE(u.raw_user_meta_data->>'name', u.email) as user_name
    FROM 
        automation_tasks t
    JOIN 
        auth.users u ON t.user_id = u.id
    WHERE 
        t.status = 'pending'
    ORDER BY 
        t.created_at ASC;
END;
$$;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION approve_automation_task TO authenticated;
GRANT EXECUTE ON FUNCTION reject_automation_task TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_tasks_for_admin TO authenticated;

-- Update RLS policy to allow admins to see all tasks
CREATE POLICY "Admins can view all automation tasks"
  ON automation_tasks FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
  );

-- Create policy to allow admins to update task status
CREATE POLICY "Admins can update automation tasks"
  ON automation_tasks FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
  );
