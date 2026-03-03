-- REALTOR OS WALLET + EXECUTION SYSTEM
-- Complete database schema implementation

-- Drop existing tables if they exist (for clean migration)
DROP TABLE IF EXISTS automation_tasks CASCADE;
DROP TABLE IF EXISTS wallet_commitments CASCADE;
DROP TABLE IF EXISTS token_ledger CASCADE;
DROP TABLE IF EXISTS wallets CASCADE;

-- 🟦 1. wallets table
CREATE TABLE wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 🟦 2. token_ledger table (Final transactions only)
CREATE TABLE token_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
  entry_type TEXT NOT NULL CHECK (entry_type IN ('earn', 'spend', 'purchase', 'transfer')),
  amount INTEGER NOT NULL,
  source TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 🟦 3. wallet_commitments table
CREATE TABLE wallet_commitments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
  commitment_type TEXT NOT NULL,
  reserved_amount INTEGER NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('active', 'executed', 'cancelled')),
  related_object_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 🟦 4. automation_tasks table
CREATE TABLE automation_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  task_type TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('queued', 'running', 'completed', 'failed')),
  related_commitment_id UUID REFERENCES wallet_commitments(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_token_ledger_wallet_id ON token_ledger(wallet_id);
CREATE INDEX idx_token_ledger_created_at ON token_ledger(created_at DESC);
CREATE INDEX idx_wallet_commitments_wallet_id ON wallet_commitments(wallet_id);
CREATE INDEX idx_wallet_commitments_status ON wallet_commitments(status);
CREATE INDEX idx_automation_tasks_user_id ON automation_tasks(user_id);
CREATE INDEX idx_automation_tasks_status ON automation_tasks(status);
CREATE INDEX idx_automation_tasks_commitment_id ON automation_tasks(related_commitment_id);

-- Enable RLS
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE token_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_commitments ENABLE ROW LEVEL SECURITY;
ALTER TABLE automation_tasks ENABLE ROW LEVEL SECURITY;

-- RLS policies for wallets
CREATE POLICY "Users can view their own wallet"
  ON wallets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own wallet"
  ON wallets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS policies for token_ledger
CREATE POLICY "Users can view their own token ledger"
  ON token_ledger FOR SELECT
  USING (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- RLS policies for wallet_commitments
CREATE POLICY "Users can view their own commitments"
  ON wallet_commitments FOR SELECT
  USING (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- RLS policies for automation_tasks
CREATE POLICY "Users can view their own automation tasks"
  ON automation_tasks FOR SELECT
  USING (auth.uid() = user_id);

-- 🔷 CORE RPC FUNCTIONS

-- RPC: Get all wallets for user
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

-- RPC: Get wallet balance (Available tokens only - subtracts active commitments)
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
  
  -- Calculate wallet total (ledger only)
  SELECT COALESCE(SUM(amount), 0) INTO v_wallet_total
  FROM token_ledger 
  WHERE wallet_id = p_wallet_id AND entry_type IN ('earn', 'purchase');
  
  -- Calculate reserved amount (active commitments only)
  SELECT COALESCE(SUM(reserved_amount), 0) INTO v_reserved_amount
  FROM wallet_commitments 
  WHERE wallet_id = p_wallet_id AND status = 'active';
  
  -- Return available balance
  RETURN v_wallet_total - v_reserved_amount;
END;
$$;

-- RPC: Get wallet history with running balance
CREATE OR REPLACE FUNCTION get_wallet_history(p_wallet_id UUID)
RETURNS TABLE (
  day DATE,
  net_change INTEGER,
  running_balance INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_user_id UUID;
BEGIN
  -- Verify wallet ownership
  SELECT user_id INTO v_wallet_user_id
  FROM wallets 
  WHERE id = p_wallet_id;
  
  IF v_wallet_user_id IS NULL OR v_wallet_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Wallet not found or access denied';
  END IF;
  
  RETURN QUERY
  WITH daily_changes AS (
    SELECT 
      DATE(created_at) as day,
      SUM(CASE WHEN entry_type IN ('earn', 'purchase') THEN amount ELSE 0 END) -
      SUM(CASE WHEN entry_type = 'spend' THEN amount ELSE 0 END) as net_change
    FROM token_ledger
    WHERE wallet_id = p_wallet_id
    GROUP BY DATE(created_at)
  ),
  running_totals AS (
    SELECT 
      day,
      net_change,
      SUM(net_change) OVER (ORDER BY day) as running_balance
    FROM daily_changes
  )
  SELECT 
    rt.day,
    rt.net_change,
    rt.running_balance
  FROM running_totals rt
  ORDER BY rt.day DESC;
END;
$$;

-- RPC: Get wallet transactions
CREATE OR REPLACE FUNCTION get_wallet_transactions(p_wallet_id UUID)
RETURNS TABLE (
  created_at TIMESTAMP WITH TIME ZONE,
  entry_type TEXT,
  amount INTEGER,
  source TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_user_id UUID;
BEGIN
  -- Verify wallet ownership
  SELECT user_id INTO v_wallet_user_id
  FROM wallets 
  WHERE id = p_wallet_id;
  
  IF v_wallet_user_id IS NULL OR v_wallet_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Wallet not found or access denied';
  END IF;
  
  RETURN QUERY
  SELECT 
    tl.created_at,
    tl.entry_type,
    tl.amount,
    tl.source
  FROM token_ledger tl
  WHERE tl.wallet_id = p_wallet_id
  ORDER BY tl.created_at DESC;
END;
$$;

-- RPC: Get wallet commitments summary (grouped by type, active only)
CREATE OR REPLACE FUNCTION get_wallet_commitments_summary(p_wallet_id UUID)
RETURNS TABLE (
  commitment_type TEXT,
  total_reserved_amount INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_user_id UUID;
BEGIN
  -- Verify wallet ownership
  SELECT user_id INTO v_wallet_user_id
  FROM wallets 
  WHERE id = p_wallet_id;
  
  IF v_wallet_user_id IS NULL OR v_wallet_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Wallet not found or access denied';
  END IF;
  
  RETURN QUERY
  SELECT 
    wc.commitment_type,
    SUM(wc.reserved_amount) as total_reserved_amount
  FROM wallet_commitments wc
  WHERE wc.wallet_id = p_wallet_id AND wc.status = 'active'
  GROUP BY wc.commitment_type;
END;
$$;

-- RPC: Get recommended interventions
CREATE OR REPLACE FUNCTION get_recommended_interventions(p_user_id UUID)
RETURNS TABLE (
  intervention_type TEXT,
  description TEXT,
  token_cost INTEGER,
  action_key TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'ai_cleanup' as intervention_type,
    '3 stalled buyers detected - activate AI call cleanup' as description,
    15 as token_cost,
    'activate_ai_cleanup' as action_key
  UNION ALL
  SELECT 
    'live_transfer' as intervention_type,
    '1 deal at risk - live transfer recommended' as description,
    100 as token_cost,
    'escalate_live_call' as action_key;
END;
$$;

-- RPC: Get operational trust level
CREATE OR REPLACE FUNCTION get_operational_trust(p_user_id UUID)
RETURNS TABLE (
  current_level INTEGER,
  next_level INTEGER,
  progress_percent INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    18 as current_level,
    19 as next_level,
    65 as progress_percent;
END;
$$;

-- RPC: Get automation summary
CREATE OR REPLACE FUNCTION get_automation_summary(p_user_id UUID)
RETURNS TABLE (
  va_status TEXT,
  active_assignments_count INTEGER,
  running_tasks_count INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'online' as va_status,
    3 as active_assignments_count,
    2 as running_tasks_count;
END;
$$;

-- RPC: Execute action (6 Box Model - Box 2)
CREATE OR REPLACE FUNCTION execute_action(
  p_user_id UUID,
  p_action_type TEXT,
  p_token_cost INTEGER,
  p_related_object_id UUID DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  commitment_id UUID,
  task_id UUID,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_id UUID;
  v_available_balance INTEGER;
  v_commitment_id UUID;
  v_task_id UUID;
BEGIN
  -- Get wallet for user
  SELECT id INTO v_wallet_id
  FROM wallets
  WHERE user_id = p_user_id;
  
  IF v_wallet_id IS NULL THEN
    RETURN QUERY SELECT false, NULL::UUID, NULL::UUID, 'Wallet not found';
    RETURN;
  END IF;
  
  -- Check available balance
  SELECT get_wallet_balance(v_wallet_id) INTO v_available_balance;
  
  IF v_available_balance < p_token_cost THEN
    RETURN QUERY SELECT false, NULL::UUID, NULL::UUID, 'Insufficient balance';
    RETURN;
  END IF;
  
  -- Insert commitment (Box 3)
  INSERT INTO wallet_commitments (
    wallet_id, commitment_type, reserved_amount, status, related_object_id
  ) VALUES (
    v_wallet_id, p_action_type, p_token_cost, 'active', p_related_object_id
  ) RETURNING id INTO v_commitment_id;
  
  -- Insert automation task (Box 4)
  INSERT INTO automation_tasks (
    user_id, task_type, status, related_commitment_id
  ) VALUES (
    p_user_id, p_action_type, 'queued', v_commitment_id
  ) RETURNING id INTO v_task_id;
  
  RETURN QUERY SELECT true, v_commitment_id, v_task_id, 'Action queued successfully';
END;
$$;

-- RPC: Complete task (Box 5 - Worker Engine)
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
  v_commitment RECORD;
BEGIN
  -- Get task and related commitment
  SELECT at.*, wc.wallet_id, wc.reserved_amount, wc.commitment_type
  INTO v_task, v_commitment
  FROM automation_tasks at
  JOIN wallet_commitments wc ON at.related_commitment_id = wc.id
  WHERE at.id = p_task_id;
  
  IF v_task IS NULL THEN
    RETURN QUERY SELECT false, 'Task not found';
    RETURN;
  END IF;
  
  -- Update task status
  UPDATE automation_tasks
  SET status = CASE WHEN p_success THEN 'completed' ELSE 'failed' END
  WHERE id = p_task_id;
  
  IF p_success THEN
    -- Success: Delete commitment and insert ledger entry
    DELETE FROM wallet_commitments WHERE id = v_task.related_commitment_id;
    
    INSERT INTO token_ledger (
      wallet_id, entry_type, amount, source
    ) VALUES (
      v_commitment.wallet_id, 'spend', v_commitment.reserved_amount, 
      COALESCE(p_outcome, v_commitment.commitment_type)
    );
    
    RETURN QUERY SELECT true, 'Task completed successfully';
  ELSE
    -- Failure: Delete commitment, no ledger entry
    DELETE FROM wallet_commitments WHERE id = v_task.related_commitment_id;
    
    RETURN QUERY SELECT true, 'Task failed, tokens returned';
  END IF;
END;
$$;

-- Helper function to create wallet for user
CREATE OR REPLACE FUNCTION create_wallet_for_user(p_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_id UUID;
BEGIN
  INSERT INTO wallets (user_id) VALUES (p_user_id) RETURNING id INTO v_wallet_id;
  RETURN v_wallet_id;
END;
$$;
