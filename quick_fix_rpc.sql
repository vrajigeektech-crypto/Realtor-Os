-- Quick fix for the create_automation_task RPC function
-- Run this directly in Supabase Dashboard -> SQL Editor

-- First, drop the existing function completely
DROP FUNCTION IF EXISTS create_automation_task(p_user_id UUID, p_task_type TEXT, p_status TEXT);

-- Then recreate it with the proper fix
CREATE FUNCTION create_automation_task(
    p_user_id UUID,
    p_task_type TEXT,
    p_status TEXT DEFAULT 'queued'
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    task_type TEXT,
    status TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Insert automation task and return the inserted row using RETURNING clause
    RETURN QUERY
    INSERT INTO automation_tasks (
        id,
        user_id,
        task_type,
        status,
        created_at
    ) VALUES (
        gen_random_uuid(),
        p_user_id,
        p_task_type,
        p_status,
        NOW()
    )
    RETURNING 
        automation_tasks.id,
        automation_tasks.user_id,
        automation_tasks.task_type,
        automation_tasks.status,
        automation_tasks.created_at;
END;
$$;
