-- Fix wallet balance field name
-- Run this in Supabase SQL Editor

-- Check what wallet field actually exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name LIKE '%wallet%' OR column_name LIKE '%balance%';

-- Update RPC to use correct field
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
        'token_balance', COALESCE(u.wallet_balance, 0), -- Try wallet_balance instead
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
