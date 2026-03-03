-- Fix wallet balance type mismatch
-- The issue: SUM() returns BIGINT but function was defined with INTEGER
-- Solution: Update function to properly cast BIGINT to INTEGER

-- Drop and recreate get_all_wallets_for_user with correct types
DROP FUNCTION IF EXISTS get_all_wallets_for_user(p_user_id UUID);

CREATE FUNCTION get_all_wallets_for_user(p_user_id UUID)
RETURNS TABLE (
  wallet_id UUID,
  wallet_type TEXT,
  balance INTEGER,  -- Changed from BIGINT to INTEGER
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
    )::INTEGER as balance,  -- Cast BIGINT to INTEGER
    NULL::UUID as org_id,
    NULL::UUID as agent_id
  FROM wallets w
  WHERE w.user_id = p_user_id;
END;
$$;

-- Also fix get_wallet_balance if it has similar issues
DROP FUNCTION IF EXISTS get_wallet_balance(p_wallet_id UUID);

CREATE FUNCTION get_wallet_balance(p_wallet_id UUID)
RETURNS INTEGER  -- Changed from BIGINT to INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_total BIGINT;
  v_reserved_amount BIGINT;
  v_wallet_user_id UUID;
BEGIN
  -- Verify wallet ownership
  SELECT user_id INTO v_wallet_user_id
  FROM wallets 
  WHERE id = p_wallet_id;
  
  IF v_wallet_user_id IS NULL OR v_wallet_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Wallet not found or access denied';
  END IF;
  
  -- Calculate wallet total (ledger: purchase/earn minus spend)
  SELECT (
    COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = p_wallet_id AND entry_type IN ('earn', 'purchase')), 0) -
    COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = p_wallet_id AND entry_type = 'spend'), 0)
  ) INTO v_wallet_total;
  
  -- Calculate reserved amount (active commitments only)
  SELECT COALESCE(SUM(reserved_amount), 0) INTO v_reserved_amount
  FROM wallet_commitments 
  WHERE wallet_id = p_wallet_id AND status = 'active';
  
  -- Return available balance (Total - Reserved) cast to INTEGER
  RETURN (v_wallet_total - v_reserved_amount)::INTEGER;
END;
$$;

-- Test the function
SELECT 'Testing get_all_wallets_for_user function' as status;
SELECT * FROM get_all_wallets_for_user(auth.uid()) LIMIT 1;

SELECT 'Testing get_wallet_balance function' as status;
-- This will need a wallet ID from the previous query to test properly
