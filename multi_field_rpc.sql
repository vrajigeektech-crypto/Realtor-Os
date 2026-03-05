-- RPC that tries multiple wallet/balance field names
-- Run this in Supabase SQL Editor

DROP FUNCTION IF EXISTS public.get_users_list() CASCADE;

CREATE OR REPLACE FUNCTION public.get_users_list()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_users jsonb;
BEGIN
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
          u.wallet_balance,    -- Try wallet_balance first
          u.tokens_balance,    -- Then tokens_balance  
          u.balance,           -- Then balance
          u.wallet,            -- Then wallet
          0                    -- Default to 0
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
