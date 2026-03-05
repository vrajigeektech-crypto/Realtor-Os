-- ============================================================================
-- get_users_list (Debug Version - Shows current user info and all users)
-- Helps debug why only 1 user shows when 2 exist in database
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_users_list() CASCADE;

CREATE OR REPLACE FUNCTION public.get_users_list()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_user_role text;
  v_all_users jsonb;
  v_debug_info jsonb;
BEGIN
  -- Get the current authenticated user ID
  v_user_id := auth.uid();
  
  -- Debug: Show current user info
  SELECT jsonb_build_object(
    'current_user_id', COALESCE(v_user_id::text, 'NULL'),
    'current_user_role', COALESCE(u.role, 'NOT_FOUND'),
    'current_user_name', COALESCE(u.name, 'NOT_FOUND'),
    'current_user_deleted', COALESCE(u.is_deleted, false)
  )
  INTO v_debug_info
  FROM public.users u
  WHERE u.id = v_user_id;
  
  -- Get ALL users for debugging (no role restrictions)
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', u.id::text,
        'name', u.name,
        'email', u.email,
        'role', u.role,
        'status', u.status,
        'last_login', u.last_login,
        'is_deleted', u.is_deleted,
        'broker_id', u.broker_id::text,
        'total_orders', 0,
        'token_balance', COALESCE(u.tokens_balance, 0),
        'has_flags', false
      )
      ORDER BY u.name ASC
    ),
    '[]'::jsonb
  )
  INTO v_all_users
  FROM public.users u;
  
  -- Return debug info + all users
  RETURN jsonb_build_object(
    'debug', v_debug_info,
    'all_users', v_all_users,
    'total_count', COALESCE((SELECT COUNT(*) FROM public.users), 0),
    'active_count', COALESCE((SELECT COUNT(*) FROM public.users WHERE is_deleted = false), 0)
  );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_users_list() TO authenticated;
