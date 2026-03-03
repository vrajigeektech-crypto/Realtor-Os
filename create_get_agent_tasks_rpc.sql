-- ============================================================================
-- get_agent_tasks
-- Returns all tasks for the current authenticated agent
-- Input: None (uses auth.uid())
-- Output: jsonb array of tasks with id, task_number, title, status, created_at
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_agent_tasks() CASCADE;

CREATE OR REPLACE FUNCTION public.get_agent_tasks()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_tasks jsonb;
BEGIN
  -- Get the current authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Get all tasks for the current agent, ordered by created_at DESC
  -- Extract last 4 characters of UUID as task_number for display
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'task_id', t.id::text,
        'task_number', RIGHT(t.id::text, 4), -- Last 4 chars of UUID
        'title', COALESCE(t.title, 'Untitled Task'),
        'status', COALESCE(t.status, 'open'),
        'created_at', t.created_at
      )
      ORDER BY t.created_at DESC
    ),
    '[]'::jsonb
  )
  INTO v_tasks
  FROM public.tasks t
  WHERE t.user_id = v_user_id;

  RETURN COALESCE(v_tasks, '[]'::jsonb);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_agent_tasks() TO authenticated;
