-- ============================================================================
-- get_users_list (Show All Users with Balance)
-- Returns ALL users with their token balances, no role restrictions
-- Input: None 
-- Output: jsonb array of all active users with balance info
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_users_list() CASCADE;

CREATE OR REPLACE FUNCTION public.get_users_list()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_users jsonb;
BEGIN
  -- Get ALL users with token balance info, no role restrictions
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', u.id::text,
        'name', u.name,
        'email', u.email,
        'role', u.role,
        'status', u.status,
        'last_login', u.last_login,
        'tokens_balance', COALESCE(u.tokens_balance::numeric, 0),
        'xp_total', COALESCE(u.xp_total, 0),
        'level', COALESCE(u.level, 1),
        'current_streak', COALESCE(u.current_streak, 0),
        'longest_streak', COALESCE(u.longest_streak, 0),
        'total_orders', 0, -- Default to 0 since tasks table doesn't exist
        'has_flags', false -- TODO: Implement flag logic if needed
      )
      ORDER BY u.name ASC
    ),
    '[]'::jsonb
  )
  INTO v_users
  FROM public.users u
  WHERE u.is_deleted = false;

  RETURN COALESCE(v_users, '[]'::jsonb);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_users_list() TO authenticated;
