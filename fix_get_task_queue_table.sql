-- ============================================================================
-- Fix get_task_queue_table Function - Window Function Error
-- Fixes: "aggregate function calls cannot contain window function calls"
-- ============================================================================

-- Drop both overloaded versions (CASCADE removes dependencies)
DROP FUNCTION IF EXISTS public.get_task_queue_table() CASCADE;
DROP FUNCTION IF EXISTS public.get_task_queue_table(p_status text) CASCADE;

-- Create single function with optional parameter (DEFAULT NULL)
-- Fixed: Calculate ROW_NUMBER in CTE first, then use in aggregate
CREATE OR REPLACE FUNCTION public.get_task_queue_table(
  p_status text DEFAULT NULL
)
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

  -- Calculate queue_position first using CTE, then aggregate
  WITH ordered_tasks AS (
    SELECT 
      t.*,
      ROW_NUMBER() OVER (ORDER BY t.created_at ASC) as queue_position
    FROM public.tasks t
    WHERE t.user_id = v_user_id
      AND t.status != 'complete'
      AND (
        p_status IS NULL 
        OR p_status = ''
        OR t.status = p_status
      )
  )
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', t.id::text,
        'task_type', COALESCE(t.category, 'Uncategorized'),
        'status', t.status,
        'priority', NULL, -- Not in schema
        'sla_countdown', CASE 
          WHEN t.sla_breached_at IS NULL THEN NULL
          ELSE GREATEST(EXTRACT(EPOCH FROM (t.sla_breached_at - NOW()))::int, 0)::text
        END,
        'queue_position', t.queue_position,
        'assigned_admin_id', NULL, -- Not in schema
        'assigned_admin_name', NULL -- Not in schema
      )
      ORDER BY t.created_at DESC
    ),
    '[]'::jsonb
  )
  INTO v_tasks
  FROM ordered_tasks t;

  RETURN v_tasks;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_task_queue_table(text) TO authenticated;
