-- Manual SQL to set up approval workflow
-- Run this in Supabase SQL Editor to enable live data

-- Step 1: Update the status constraint to include pending and rejected
ALTER TABLE automation_tasks 
DROP CONSTRAINT IF EXISTS automation_tasks_status_check;

ALTER TABLE automation_tasks 
ADD CONSTRAINT automation_tasks_status_check 
CHECK (status IN ('pending', 'queued', 'running', 'completed', 'failed', 'rejected'));

-- Step 2: Create approval function
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
    UPDATE automation_tasks 
    SET 
        status = 'queued',
        created_at = NOW()
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

-- Step 3: Create rejection function
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
    UPDATE automation_tasks 
    SET 
        status = 'rejected',
        created_at = NOW()
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

-- Step 4: Create function to get pending tasks
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

-- Step 5: Grant permissions
GRANT EXECUTE ON FUNCTION approve_automation_task TO authenticated;
GRANT EXECUTE ON FUNCTION reject_automation_task TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_tasks_for_admin TO authenticated;

-- Step 6: Test the functions
-- Create a test pending task (replace USER_ID with actual user ID)
INSERT INTO automation_tasks (user_id, task_type, status) 
VALUES ('USER_ID_HERE', 'test_approval_workflow', 'pending')
RETURNING id, user_id, task_type, status, created_at;

-- Test getting pending tasks
SELECT * FROM get_pending_tasks_for_admin();

-- Test approving (replace TASK_ID with actual task ID from above)
-- SELECT * FROM approve_automation_task('TASK_ID_HERE', 'ADMIN_USER_ID_HERE');
