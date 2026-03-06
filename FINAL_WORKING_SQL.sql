-- FINAL WORKING SQL - Copy this ENTIRE content into Supabase SQL Editor
-- DO NOT use any other SQL files - this one works without placeholders

-- PART 1: Setup database functions (run once)
ALTER TABLE automation_tasks 
DROP CONSTRAINT IF EXISTS automation_tasks_status_check;

ALTER TABLE automation_tasks 
ADD CONSTRAINT automation_tasks_status_check 
CHECK (status IN ('pending', 'queued', 'running', 'completed', 'failed', 'rejected'));

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
        automation_tasks.status = 'pending'
    RETURNING 
        id as task_id,
        user_id,
        task_type,
        automation_tasks.status,
        created_at,
        created_at as updated_at;
END;
$$;

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
        automation_tasks.status = 'pending'
    RETURNING 
        id as task_id,
        user_id,
        task_type,
        automation_tasks.status,
        created_at,
        created_at as updated_at,
        p_rejection_reason as rejection_reason;
END;
$$;

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
        COALESCE(u.raw_user_meta_data->>'name', u.email::text)::text as user_name
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

GRANT EXECUTE ON FUNCTION approve_automation_task TO authenticated;
GRANT EXECUTE ON FUNCTION reject_automation_task TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_tasks_for_admin TO authenticated;

-- PART 2: Test with real data (run after PART 1)

-- Step 1: See your users
SELECT 
    id as user_id,
    email,
    created_at
FROM auth.users 
ORDER BY created_at DESC
LIMIT 3;

-- Step 2: Create a test pending task using subquery (NO PLACEHOLDERS)
INSERT INTO automation_tasks (user_id, task_type, status) 
VALUES (
    (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1), 
    'test_approval_workflow', 
    'pending'
)
RETURNING id, user_id, task_type, status, created_at;

-- Step 3: Check if admin function works
SELECT * FROM get_pending_tasks_for_admin();

-- Step 4: Test approval on the task you just created
SELECT approve_automation_task(
    (SELECT id FROM automation_tasks WHERE task_type = 'test_approval_workflow' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM auth.users ORDER BY created_at DESC LIMIT 1)
);

-- Step 5: Check final result
SELECT * FROM automation_tasks WHERE task_type = 'test_approval_workflow' ORDER BY created_at DESC;
