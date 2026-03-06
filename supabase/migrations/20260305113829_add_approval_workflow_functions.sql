-- Add approval workflow functions without changing existing schema

-- First, add 'pending' and 'rejected' to the existing check constraint
-- This is a safe addition that won't break existing functionality
DO $$
BEGIN
    -- Check if the constraint exists and update it
    IF EXISTS (
        SELECT 1 FROM information_schema.check_constraints 
        WHERE constraint_name = 'automation_tasks_status_check'
    ) THEN
        -- Drop and recreate the constraint with new values
        ALTER TABLE automation_tasks DROP CONSTRAINT automation_tasks_status_check;
        ALTER TABLE automation_tasks 
        ADD CONSTRAINT automation_tasks_status_check 
        CHECK (status IN ('pending', 'queued', 'running', 'completed', 'failed', 'rejected'));
    END IF;
END $$;

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

-- Add admin policies if they don't exist
DO $$
BEGIN
    -- Add policy for admins to view all tasks
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'automation_tasks' 
        AND policyname = 'Admins can view all automation tasks'
    ) THEN
        CREATE POLICY "Admins can view all automation tasks"
          ON automation_tasks FOR SELECT
          USING (
            EXISTS (
              SELECT 1 FROM auth.users 
              WHERE auth.users.id = auth.uid() 
              AND auth.users.raw_user_meta_data->>'role' = 'admin'
            )
          );
    END IF;

    -- Add policy for admins to update tasks
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'automation_tasks' 
        AND policyname = 'Admins can update automation tasks'
    ) THEN
        CREATE POLICY "Admins can update automation tasks"
          ON automation_tasks FOR UPDATE
          USING (
            EXISTS (
              SELECT 1 FROM auth.users 
              WHERE auth.users.id = auth.uid() 
              AND auth.users.raw_user_meta_data->>'role' = 'admin'
            )
          );
    END IF;
END $$;