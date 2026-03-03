-- Fix transaction type mismatch
-- The issue: App uses 'credit'/'debit' but DB expects 'purchase'/'earn'/'spend'
-- Solution: Update balance calculation to handle both transaction type conventions

-- Drop and recreate get_all_wallets_for_user with updated transaction types
DROP FUNCTION IF EXISTS get_all_wallets_for_user(p_user_id UUID);

CREATE FUNCTION get_all_wallets_for_user(p_user_id UUID)
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
       WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase', 'credit')) -
      (SELECT COALESCE(SUM(amount), 0) 
       FROM token_ledger tl 
       WHERE tl.wallet_id = w.id AND tl.entry_type IN ('spend', 'debit')),
      0
    )::INTEGER as balance,
    NULL::UUID as org_id,
    NULL::UUID as agent_id
  FROM wallets w
  WHERE w.user_id = p_user_id;
END;
$$;

-- Also fix get_wallet_balance to handle both transaction types
DROP FUNCTION IF EXISTS get_wallet_balance(p_wallet_id UUID);

CREATE FUNCTION get_wallet_balance(p_wallet_id UUID)
RETURNS INTEGER
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
  
  -- Calculate wallet total (ledger: purchase/earn/credit minus spend/debit)
  SELECT (
    COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = p_wallet_id AND entry_type IN ('earn', 'purchase', 'credit')), 0) -
    COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = p_wallet_id AND entry_type IN ('spend', 'debit')), 0)
  ) INTO v_wallet_total;
  
  -- Calculate reserved amount (active commitments only)
  SELECT COALESCE(SUM(reserved_amount), 0) INTO v_reserved_amount
  FROM wallet_commitments 
  WHERE wallet_id = p_wallet_id AND status = 'active';
  
  -- Return available balance (Total - Reserved) cast to INTEGER
  RETURN (v_wallet_total - v_reserved_amount)::INTEGER;
END;
$$;

-- Test the functions
SELECT 'Testing get_all_wallets_for_user function' as status;
SELECT * FROM get_all_wallets_for_user(auth.uid()) LIMIT 1;

-- Check current transaction types in token_ledger
SELECT 'Current transaction types in token_ledger:' as info;
SELECT DISTINCT entry_type FROM token_ledger;

-- Check sample transactions
SELECT 'Sample transactions:' as info;
SELECT wallet_id, entry_type, amount, created_at FROM token_ledger ORDER BY created_at DESC LIMIT 5;
