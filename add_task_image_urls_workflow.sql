-- Add per-task image storage so Admin previews the exact submitted images.
-- Run once in Supabase SQL editor.

-- 1) Add image_urls column to automation_tasks
ALTER TABLE automation_tasks
ADD COLUMN IF NOT EXISTS image_urls TEXT[];

-- 2) Update create_automation_task RPC to store image_urls (backward compatible param default)
DROP FUNCTION IF EXISTS create_automation_task(uuid, text, text);

CREATE OR REPLACE FUNCTION create_automation_task(
    p_user_id UUID,
    p_task_type TEXT,
    p_status TEXT DEFAULT 'queued',
    p_image_urls TEXT[] DEFAULT NULL
)
RETURNS TABLE (
    task_id UUID,
    user_id UUID,
    task_type TEXT,
    status TEXT,
    created_at TIMESTAMPTZ,
    image_urls TEXT[]
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    INSERT INTO automation_tasks (
        id,
        user_id,
        task_type,
        status,
        created_at,
        image_urls
    ) VALUES (
        gen_random_uuid(),
        p_user_id,
        p_task_type,
        p_status,
        NOW(),
        p_image_urls
    )
    RETURNING 
        id as task_id,
        automation_tasks.user_id,
        automation_tasks.task_type,
        automation_tasks.status,
        automation_tasks.created_at,
        automation_tasks.image_urls;
END;
$$;

GRANT EXECUTE ON FUNCTION create_automation_task TO authenticated;

-- 3) Update get_pending_tasks_for_admin RPC to include image_urls (so admin UI can preview)
CREATE OR REPLACE FUNCTION get_pending_tasks_for_admin()
RETURNS TABLE (
    task_id UUID,
    user_id UUID,
    task_type TEXT,
    status TEXT,
    created_at TIMESTAMPTZ,
    user_email TEXT,
    user_name TEXT,
    image_urls TEXT[]
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
        COALESCE(u.raw_user_meta_data->>'name', u.email::text) as user_name,
        t.image_urls
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

GRANT EXECUTE ON FUNCTION get_pending_tasks_for_admin TO authenticated;

