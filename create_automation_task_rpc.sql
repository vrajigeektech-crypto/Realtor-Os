-- Create RPC function to safely insert automation tasks
CREATE OR REPLACE FUNCTION create_automation_task(
    p_user_id UUID,
    p_task_type TEXT,
    p_status TEXT DEFAULT 'queued'
)
RETURNS TABLE (
    task_id UUID,
    user_id UUID,
    task_type TEXT,
    status TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Insert automation task with proper security
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
        id as task_id,
        user_id,
        task_type,
        status,
        created_at;
END;
$$;
