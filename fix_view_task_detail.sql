-- ============================================================================
-- Fix view_task_detail Function
-- Ensures it returns proper data and handles edge cases
-- ============================================================================

DROP FUNCTION IF EXISTS public.view_task_detail(p_task_id uuid) CASCADE;

CREATE OR REPLACE FUNCTION public.view_task_detail(p_task_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_task jsonb;
BEGIN
  -- Get the current authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Get task details with proper null handling
  SELECT jsonb_build_object(
    'id', COALESCE(t.id::text, ''),
    'user_id', COALESCE(t.user_id::text, ''),
    'title', COALESCE(t.title, ''),
    'description', COALESCE(t.description, ''),
    'category', COALESCE(t.category, ''),
    'status', COALESCE(t.status, ''),
    'token_cost', COALESCE(t.token_cost, 0),
    'xp_reward', COALESCE(t.xp_reward, 0),
    'created_at', COALESCE(t.created_at::text, ''),
    'updated_at', COALESCE(t.updated_at::text, '')
  )
  INTO v_task
  FROM public.tasks t
  WHERE t.id = p_task_id
    AND t.user_id = v_user_id;

  -- Check if task was found
  IF v_task IS NULL OR v_task = 'null'::jsonb THEN
    RAISE EXCEPTION 'Task not found or access denied. Task ID: %, User ID: %', p_task_id, v_user_id;
  END IF;

  RETURN v_task;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.view_task_detail(uuid) TO authenticated;

-- Test query to verify function works
-- SELECT public.view_task_detail('YOUR_TASK_UUID_HERE');
