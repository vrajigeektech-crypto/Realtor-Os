-- Simplified version of get_users_list function
-- This version focuses on just the core functionality and approved queue count

DROP FUNCTION IF EXISTS public.get_users_list_simple() CASCADE;

CREATE OR REPLACE FUNCTION public.get_users_list_simple()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_user_role text;
  v_users jsonb;
BEGIN
  -- Get current authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Get current user's role
  SELECT role INTO v_user_role
  FROM public.users
  WHERE id = v_user_id AND is_deleted = false;

  IF v_user_role IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  -- Build query based on user role
  IF v_user_role = 'admin' THEN
    -- Admin: Get all users with essential data including approved queue count
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', u.id::text,
          'name', COALESCE(u.name, 'Unknown'),
          'email', u.email,
          'role', u.role,
          'status', u.status,
          'total_orders', COALESCE(u.total_orders, 0),
          'approved_queue_count', COALESCE((
            SELECT COUNT(*)::int
            FROM public.automation_tasks at
            WHERE at.user_id = u.id AND at.status = 'queued'
          ), 0),
          'token_balance', COALESCE(u.token_balance, 0),
          'last_login', u.last_login,
          'has_flags', false
        )
        ORDER BY u.name ASC
      ),
      '[]'::jsonb
    )
    INTO v_users
    FROM public.users u
    WHERE u.is_deleted = false;
  ELSE
    -- Non-admin: See only themselves
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', u.id::text,
          'name', COALESCE(u.name, 'Unknown'),
          'email', u.email,
          'role', u.role,
          'status', u.status,
          'total_orders', COALESCE(u.total_orders, 0),
          'approved_queue_count', COALESCE((
            SELECT COUNT(*)::int
            FROM public.automation_tasks at
            WHERE at.user_id = u.id AND at.status = 'queued'
          ), 0),
          'token_balance', COALESCE(u.token_balance, 0),
          'last_login', u.last_login,
          'has_flags', false
        )
      ),
      '[]'::jsonb
    )
    INTO v_users
    FROM public.users u
    WHERE u.id = v_user_id AND u.is_deleted = false;
  END IF;

  RETURN COALESCE(v_users, '[]'::jsonb);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_users_list_simple() TO authenticated;

-- Test the function
-- SELECT public.get_users_list_simple();
