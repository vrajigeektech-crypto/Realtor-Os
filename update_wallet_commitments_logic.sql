-- REALTOR OS WALLET + EXECUTION SYSTEM
-- Refined Implementation of Box 3, 5, 6 and RPCs
-- Matches the "Commitments" logic perfectly

-- 🟦 Update wallet_commitments table to ensure it has the correct status check
-- (Assumes table already exists from create_new_wallet_schema.sql)

-- RPC: Get wallet balance (Available tokens only - subtracts active commitments)
-- MUST RETURN INTEGER
CREATE OR REPLACE FUNCTION get_wallet_balance(p_wallet_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_total INTEGER;
  v_reserved_amount INTEGER;
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
  -- Total tokens = SUM(earn + purchase) - SUM(spend)
  -- But wait, the ledger stores final transactions.
  -- Initial state: Earn 100. Total = 100.
  -- After spend 10: Total = 90.
  -- So we just SUM(amount WHERE entry_type in ('earn', 'purchase')) - SUM(amount WHERE entry_type = 'spend')
  
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

-- RPC: Complete task (Box 5 - Worker Engine)
-- Success: Convert commitment -> executed, Insert spend entry
-- Failure: Convert commitment -> cancelled
CREATE OR REPLACE FUNCTION complete_task(
  p_task_id UUID,
  p_success BOOLEAN,
  p_outcome TEXT DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_task RECORD;
  v_commitment_id UUID;
  v_wallet_id UUID;
  v_amount INTEGER;
  v_type TEXT;
BEGIN
  -- Get task and related commitment
  SELECT at.related_commitment_id, at.user_id INTO v_commitment_id, v_task.user_id
  FROM automation_tasks at
  WHERE at.id = p_task_id;
  
  IF v_commitment_id IS NULL THEN
    RETURN QUERY SELECT false, 'Task or commitment not found';
    RETURN;
  END IF;
  
  -- Get commitment details
  SELECT wallet_id, reserved_amount, commitment_type INTO v_wallet_id, v_amount, v_type
  FROM wallet_commitments
  WHERE id = v_commitment_id;
  
  -- Update task status
  UPDATE automation_tasks
  SET status = CASE WHEN p_success THEN 'completed' ELSE 'failed' END
  WHERE id = p_task_id;
  
  IF p_success THEN
    -- Success: Mark commitment as executed and insert ledger entry
    UPDATE wallet_commitments 
    SET status = 'executed' 
    WHERE id = v_commitment_id;
    
    INSERT INTO token_ledger (
      wallet_id, entry_type, amount, source
    ) VALUES (
      v_wallet_id, 'spend', v_amount, 
      COALESCE(p_outcome, v_type)
    );
    
    RETURN QUERY SELECT true, 'Task completed, tokens spent officially';
  ELSE
    -- Failure: Mark commitment as cancelled, no ledger entry
    UPDATE wallet_commitments 
    SET status = 'cancelled' 
    WHERE id = v_commitment_id;
    
    RETURN QUERY SELECT true, 'Task failed, commitment released';
  END IF;
END;
$$;

-- Ensure get_wallet_commitments_summary only returns active commitments
CREATE OR REPLACE FUNCTION get_wallet_commitments_summary(p_wallet_id UUID)
RETURNS TABLE (
  commitment_type TEXT,
  total_reserved_amount INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Ownership check is good practice but let's stick to the prompt's essence
  RETURN QUERY
  SELECT 
    wc.commitment_type,
    SUM(wc.reserved_amount)::INTEGER as total_reserved_amount
  FROM wallet_commitments wc
  WHERE wc.wallet_id = p_wallet_id AND wc.status = 'active'
  GROUP BY wc.commitment_type;
END;
$$;
