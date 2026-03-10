-- Patch: store admin rejection comments on automation tasks
-- Run this in Supabase SQL editor or psql once.

-- 1) Add a rejection_reason column to automation_tasks if it doesn't exist yet
ALTER TABLE automation_tasks
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- 2) Update reject_automation_task() to persist the rejection_reason on the row
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
    RETURN QUERY
    UPDATE automation_tasks t
    SET 
        status = 'rejected',
        created_at = NOW(),
        rejection_reason = p_rejection_reason
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
        t.rejection_reason;
END;
$$;

