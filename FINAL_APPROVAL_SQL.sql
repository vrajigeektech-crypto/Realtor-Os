-- FINAL APPROVAL SQL - Copy this ENTIRE content into Supabase SQL Editor
-- All issues resolved

-- Part 1: Update table constraint
ALTER TABLE automation_tasks 
DROP CONSTRAINT IF EXISTS automation_tasks_status_check;

ALTER TABLE automation_tasks 
ADD CONSTRAINT automation_tasks_status_check 
CHECK (status IN ('pending', 'queued', 'running', 'completed', 'failed', 'rejected'));

-- Part 2: Approval function
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
    UPDATE automation_tasks t
    SET 
        status = 'queued',
        created_at = NOW()
    WHERE 
        t.id = p_task_id AND 
        t.status = 'pending'
    RETURNING 
        t.id as task_id,
        t.user_id,
        t.task_type,
        t.status,
        t.created_at,
        t.created_at as updated_at;
END;
$$;

-- Part 3: Rejection function
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
    UPDATE automation_tasks t
    SET 
        status = 'rejected',
        created_at = NOW()
    WHERE 
        t.id = p_task_id AND 
        t.status = 'pending'
    RETURNING 
        t.id as task_id,
        t.user_id,
        t.task_type,
        t.status,
        t.created_at,
        t.created_at as updated_at,
        p_rejection_reason as rejection_reason;
END;
$$;

-- Part 4: Get pending tasks function
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
        u.email::text as user_email,
        COALESCE(u.raw_user_meta_data->>'name', u.email::text) as user_name
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

-- Part 5: Grant permissions
GRANT EXECUTE ON FUNCTION approve_automation_task TO authenticated;
GRANT EXECUTE ON FUNCTION reject_automation_task TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_tasks_for_admin TO authenticated;

-- Part 6: Test data
SELECT 
    id as user_id,
    email,
    created_at
FROM auth.users 
ORDER BY created_at DESC
LIMIT 3;

INSERT INTO automation_tasks (user_id, task_type, status) 
VALUES (
    (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1), 
    'test_approval_workflow', 
    'pending'
)
RETURNING id, user_id, task_type, status, created_at;

SELECT * FROM get_pending_tasks_for_admin();

SELECT approve_automation_task(
    (SELECT id FROM automation_tasks WHERE task_type = 'test_approval_workflow' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1)
);

SELECT * FROM automation_tasks WHERE task_type = 'test_approval_workflow' ORDER BY created_at DESC;
