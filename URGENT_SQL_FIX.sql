-- URGENT FIX - Run this immediately in Supabase SQL Editor
-- This will fix the balance_tokens column error

-- First, check what's actually in the get_all_wallets_for_user function
SELECT prosrc FROM pg_proc WHERE proname = 'get_all_wallets_for_user';

-- Drop the problematic function completely
DROP FUNCTION IF EXISTS get_all_wallets_for_user(UUID);

-- Recreate it with correct column names
CREATE OR REPLACE FUNCTION get_all_wallets_for_user(p_user_id UUID)
RETURNS TABLE (
  wallet_id UUID,
  wallet_type TEXT,
  balance INTEGER,
  org_id UUID,
  agent_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    w.id as wallet_id,
    'personal' as wallet_type,
    COALESCE(
      (SELECT COALESCE(SUM(amount), 0) 
       FROM token_ledger tl 
       WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) -
      (SELECT COALESCE(SUM(amount), 0) 
       FROM token_ledger tl 
       WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend'),
      0
    ) as balance,
    NULL as org_id,
    NULL as agent_id
  FROM wallets w
  WHERE w.user_id = p_user_id;
END;
$$;

-- Also check if there are any other functions with balance_tokens
SELECT routine_name, routine_definition 
FROM information_schema.routines 
WHERE routine_definition LIKE '%balance_tokens%'
AND routine_schema = 'public';

-- Test the function with your user ID
SELECT 'Testing fixed function' as test;
SELECT * FROM get_all_wallets_for_user('77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9');

-- If no wallet exists, create one
INSERT INTO wallets (user_id)
SELECT '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9'
WHERE NOT EXISTS (SELECT 1 FROM wallets WHERE user_id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9');

-- Add some test tokens if needed
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  w.id, 
  'purchase', 
  1000, 
  'Initial token purchase'
FROM wallets w
WHERE w.user_id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9'
AND NOT EXISTS (SELECT 1 FROM token_ledger tl WHERE tl.wallet_id = w.id);

-- Test again
SELECT 'Final test' as test;
SELECT * FROM get_all_wallets_for_user('77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9');
