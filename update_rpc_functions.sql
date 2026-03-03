-- ============================================================================
-- RPC Functions Update Script
-- Drops and recreates all RPC functions for the new unified users table schema
-- ============================================================================

-- ============================================================================
-- 1. get_agent_profile_header
-- Returns agent profile data from the users table
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_agent_profile_header() CASCADE;

CREATE OR REPLACE FUNCTION public.get_agent_profile_header()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_result jsonb;
BEGIN
  -- Get the current authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Build the result with user data and broker info
  SELECT jsonb_build_object(
    'id', u.id::text,
    'full_name', u.name,
    'first_name', NULL, -- Not in new schema
    'last_name', NULL,  -- Not in new schema
    'role', u.role,
    'status', u.status,
    'avatar_url', COALESCE(u.headshot_url, u.primary_headshot_url),
    'brokerage_id', COALESCE(u.broker_id::text, u.org_id::text),
    'brokerage_name', COALESCE(broker.name, org.name)
  )
  INTO v_result
  FROM public.users u
  LEFT JOIN public.users broker ON u.broker_id = broker.id
  LEFT JOIN public.organizations org ON u.org_id = org.id
  WHERE u.id = v_user_id
    AND u.is_deleted = false;

  IF v_result IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  RETURN v_result;
END;
$$;

-- ============================================================================
-- 2. update_agent_status
-- Updates the user's status
-- ============================================================================
DROP FUNCTION IF EXISTS public.update_agent_status(p_agent_id uuid, p_status text) CASCADE;

CREATE OR REPLACE FUNCTION public.update_agent_status(
  p_agent_id uuid,
  p_status text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_updated_user jsonb;
BEGIN
  -- Get the current authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Only allow users to update their own status, or admins to update any
  IF p_agent_id != v_user_id THEN
    -- Check if current user is admin
    IF NOT EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = v_user_id 
        AND role = 'admin' 
        AND is_deleted = false
    ) THEN
      RAISE EXCEPTION 'Unauthorized: Can only update own status';
    END IF;
  END IF;

  -- Validate status
  IF p_status NOT IN ('active', 'inactive', 'archived') THEN
    RAISE EXCEPTION 'Invalid status: %', p_status;
  END IF;

  -- Update the user status
  UPDATE public.users
  SET status = p_status
  WHERE id = p_agent_id
    AND is_deleted = false;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  -- Return the updated user record
  SELECT jsonb_build_object(
    'id', u.id::text,
    'full_name', u.name,
    'first_name', NULL,
    'last_name', NULL,
    'role', u.role,
    'status', u.status,
    'avatar_url', COALESCE(u.headshot_url, u.primary_headshot_url),
    'brokerage_id', COALESCE(u.broker_id::text, u.org_id::text),
    'brokerage_name', COALESCE(broker.name, org.name)
  )
  INTO v_updated_user
  FROM public.users u
  LEFT JOIN public.users broker ON u.broker_id = broker.id
  LEFT JOIN public.organizations org ON u.org_id = org.id
  WHERE u.id = p_agent_id;

  RETURN v_updated_user;
END;
$$;

-- ============================================================================
-- 3. get_agent_nav_tabs
-- Returns navigation tabs configuration
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_agent_nav_tabs() CASCADE;

CREATE OR REPLACE FUNCTION public.get_agent_nav_tabs()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  RETURN jsonb_build_array(
    jsonb_build_object('id', 'overview', 'label', 'Overview'),
    jsonb_build_object('id', 'wallet', 'label', 'Wallet'),
    jsonb_build_object('id', 'tasks', 'label', 'Tasks'),
    jsonb_build_object('id', 'settings', 'label', 'Settings')
  );
END;
$$;

-- ============================================================================
-- 4. get_active_tab_state
-- Returns the active tab (uses x-tab header if present, otherwise defaults to 'tasks')
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_active_tab_state() CASCADE;

CREATE OR REPLACE FUNCTION public.get_active_tab_state()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
  v_tab_header text;
BEGIN
  -- Try to get x-tab header from request
  -- Note: This requires PostgREST to pass headers, which may need additional setup
  -- For now, defaulting to 'tasks'
  v_tab_header := current_setting('request.headers', true);
  
  -- If header is available and contains x-tab, extract it
  -- Otherwise default to 'tasks'
  IF v_tab_header IS NOT NULL AND v_tab_header LIKE '%x-tab%' THEN
    -- Extract tab value from header (simplified - may need adjustment)
    RETURN COALESCE(
      NULLIF(TRIM(SPLIT_PART(SPLIT_PART(v_tab_header, 'x-tab:', 2), E'\n', 1)), ''),
      'tasks'
    );
  END IF;

  RETURN 'tasks';
END;
$$;

-- ============================================================================
-- 5. get_task_queue_table
-- Returns tasks (note: tasks table doesn't have priority, queue_position, or assigned_admin)
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_task_queue_table() CASCADE;

CREATE OR REPLACE FUNCTION public.get_task_queue_table()
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

  -- Get tasks with calculated fields
  -- Note: priority, queue_position, and assigned_admin don't exist in tasks table
  -- Fixed: Calculate ROW_NUMBER in CTE first, then use in aggregate
  WITH ordered_tasks AS (
    SELECT 
      t.*,
      ROW_NUMBER() OVER (ORDER BY t.created_at ASC) as calculated_queue_position
    FROM public.tasks t
    WHERE t.user_id = v_user_id
      AND t.status != 'complete'
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
        'queue_position', t.calculated_queue_position,
        'assigned_admin_id', NULL, -- Not in schema
        'assigned_admin_name', NULL -- Not in schema
      )
      ORDER BY t.created_at DESC
    ),
    '[]'::jsonb
  )
  INTO v_tasks
  FROM ordered_tasks t;

  RETURN COALESCE(v_tasks, '[]'::jsonb);
END;
$$;

-- ============================================================================
-- 6. view_task_detail
-- Returns full task details
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

  -- Get task details
  -- Ensure all fields return strings (not null) for proper JSON parsing
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

  IF v_task IS NULL THEN
    RAISE EXCEPTION 'Task not found or access denied';
  END IF;

  RETURN v_task;
END;
$$;

-- ============================================================================
-- 7. get_task_overview_counts
-- Returns task statistics for the current user
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_task_overview_counts() CASCADE;

CREATE OR REPLACE FUNCTION public.get_task_overview_counts()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_result jsonb;
BEGIN
  -- Get the current authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Calculate task counts using actual status values
  SELECT jsonb_build_object(
    'total_open_tasks', COUNT(*) FILTER (WHERE status != 'complete'),
    'awaiting_approval', COUNT(*) FILTER (WHERE status = 'waiting_admin'),
    'sla_breaches_today', COUNT(*) FILTER (
      WHERE status != 'complete'
        AND sla_breached_at IS NOT NULL
        AND DATE(sla_breached_at) = CURRENT_DATE
    )
  )
  INTO v_result
  FROM public.tasks
  WHERE user_id = v_user_id;

  RETURN COALESCE(v_result, jsonb_build_object(
    'total_open_tasks', 0,
    'awaiting_approval', 0,
    'sla_breaches_today', 0
  ));
END;
$$;

-- ============================================================================
-- Grant execute permissions to authenticated users
-- ============================================================================
GRANT EXECUTE ON FUNCTION public.get_agent_profile_header() TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_agent_status(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_agent_nav_tabs() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_active_tab_state() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_task_queue_table() TO authenticated;
GRANT EXECUTE ON FUNCTION public.view_task_detail(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_task_overview_counts() TO authenticated;
