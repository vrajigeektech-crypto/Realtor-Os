-- Fix UUID NULL types in get_all_wallets_for_user function
-- Drop and recreate with proper NULL::UUID casting

DROP FUNCTION IF EXISTS get_all_wallets_for_user(p_user_id UUID);

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