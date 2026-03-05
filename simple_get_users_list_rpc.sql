-- ============================================================================
-- get_users_list (Simple Version - Only existing fields)
-- Returns all users for user management table
-- Input: None (uses auth.uid() for permissions - admins see all, brokers see their agents)
-- Output: jsonb array of users with basic fields that definitely exist
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
  v_users jsonb;
BEGIN
  -- Get the current authenticated user ID
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
  -- Admins see all users, Brokers see their agents, others see only themselves
  IF v_user_role = 'admin' THEN
    -- Admin: Get all users with basic data
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', u.id::text,
          'name', u.name,
          'email', u.email,
          'role', u.role,
          'status', u.status,
          'last_login', u.last_login,
          'total_orders', 0, -- Default to 0 since tasks table doesn't exist
          'token_balance', COALESCE(u.tokens_balance, 0),
          'has_flags', false -- TODO: Implement flag logic if needed
        )
        ORDER BY u.name ASC
      ),
      '[]'::jsonb
    )
    INTO v_users
    FROM public.users u
    WHERE u.is_deleted = false;
  ELSIF v_user_role = 'broker' THEN
    -- Broker: Get their agents with basic data
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', u.id::text,
          'name', u.name,
          'email', u.email,
          'role', u.role,
          'status', u.status,
          'last_login', u.last_login,
          'total_orders', 0, -- Default to 0 since tasks table doesn't exist
          'token_balance', COALESCE(u.tokens_balance, 0),
          'has_flags', false
        )
        ORDER BY u.name ASC
      ),
      '[]'::jsonb
    )
    INTO v_users
    FROM public.users u
    WHERE (u.broker_id = v_user_id OR u.id = v_user_id)
      AND u.is_deleted = false;
  ELSE
    -- Agent/Team Lead: See only themselves with basic data
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', u.id::text,
          'name', u.name,
          'email', u.email,
          'role', u.role,
          'status', u.status,
          'last_login', u.last_login,
          'total_orders', 0, -- Default to 0 since tasks table doesn't exist
          'token_balance', COALESCE(u.tokens_balance, 0),
          'has_flags', false
        )
      ),
      '[]'::jsonb
    )
    INTO v_users
    FROM public.users u
    WHERE u.id = v_user_id
      AND u.is_deleted = false;
  END IF;

  RETURN COALESCE(v_users, '[]'::jsonb);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_users_list() TO authenticated;
