-- Fix type mismatches in wallet RPC functions
-- Drop and recreate with BIGINT to match PostgreSQL SUM() return type

-- Drop existing functions
DROP FUNCTION IF EXISTS get_all_wallets_for_user(p_user_id UUID);
DROP FUNCTION IF EXISTS get_wallet_balance(p_wallet_id UUID);

-- Recreate get_all_wallets_for_user function with BIGINT
CREATE FUNCTION get_all_wallets_for_user(p_user_id UUID)
RETURNS TABLE (
  wallet_id UUID,
  wallet_type TEXT,
  balance BIGINT,
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
    NULL::UUID as org_id,
    NULL::UUID as agent_id
  FROM wallets w
  WHERE w.user_id = p_user_id;
END;
$$;

-- Recreate get_wallet_balance function with BIGINT
CREATE FUNCTION get_wallet_balance(p_wallet_id UUID)
RETURNS BIGINT
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
  
  -- Return available balance (Total - Reserved)
  RETURN v_wallet_total - v_reserved_amount;
END;
$$;