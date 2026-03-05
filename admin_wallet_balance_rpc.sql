-- ============================================================================
-- get_users_list (Admin with Wallet Balance)
-- Uses the same wallet system as the wallet screen
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
  -- Get all users with their wallet balances from the wallets table
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', u.id::text,
        'name', u.name,
        'email', u.email,
        'role', u.role,
        'status', u.status,
        'last_login', u.last_login,
        'token_balance', COALESCE(
          (SELECT get_wallet_balance(w.id) 
           FROM wallets w 
           WHERE w.user_id = u.id 
           LIMIT 1), 0
        ),
        'total_orders', 0,
        'has_flags', false
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

GRANT EXECUTE ON FUNCTION public.get_users_list() TO authenticated;

-- Test the function with demo user
SELECT 
  'TEST_DEMO_USER' as info,
  u.name,
  u.email,
  COALESCE(
    (SELECT get_wallet_balance(w.id) 
     FROM wallets w 
     WHERE w.user_id = u.id 
     LIMIT 1), 0
  ) as wallet_balance
FROM public.users u 
WHERE u.email = 'demo@gmail.com';
