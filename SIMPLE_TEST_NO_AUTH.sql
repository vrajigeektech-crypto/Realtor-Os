-- Simple test without authentication requirements
-- This will help identify if the issue is with auth or the function itself

-- Create a public function that doesn't require authentication
CREATE OR REPLACE FUNCTION public_test_wallet()
RETURNS TABLE (
  wallet_id UUID,
  wallet_type TEXT,
  balance INTEGER,
  org_id UUID,
  agent_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    w.id as wallet_id,
    w.wallet_type,
    COALESCE(
      (SELECT COALESCE(SUM(tl.amount), 0) FROM token_ledger tl WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) -
      (SELECT COALESCE(SUM(tl.amount), 0) FROM token_ledger tl WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend'),
      0
    )::INTEGER as balance,
    NULL::UUID as org_id,
    NULL::UUID as agent_id
  FROM wallets w
  LIMIT 1;
END;
$$;

-- Grant public access
GRANT EXECUTE ON FUNCTION public_test_wallet TO public;
GRANT EXECUTE ON FUNCTION public_test_wallet TO authenticated;
GRANT EXECUTE ON FUNCTION public_test_wallet TO service_role;

-- Test it
SELECT '=== PUBLIC TEST FUNCTION ===' as info;
SELECT * FROM public_test_wallet();

-- Also test the bypass function directly
SELECT '=== BYPASS FUNCTION DIRECT TEST ===' as info;
SELECT * FROM get_all_wallets_for_user_bypass(
  (SELECT id FROM auth.users LIMIT 1)
);

-- Show all users again
SELECT '=== ALL USERS FOR REFERENCE ===' as info;
SELECT id, email FROM auth.users;
