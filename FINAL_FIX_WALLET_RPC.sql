-- =====================================================================================
-- REALTOR OS: FINAL CONSOLIDATED WALLET & EXECUTION SYSTEM
-- =====================================================================================
-- This script deploys the complete wallet architecture including:
-- 1. Tables (wallets, token_ledger, wallet_commitments, automation_tasks)
-- 2. Row Level Security (RLS) policies
-- 3. Core RPC Functions (execute_action, complete_task, get_wallet_health, etc.)
--
-- Resolve Issue: "Backend RPC missing: execute_action / complete_task"
-- =====================================================================================

-- 🟦 DROP EXISTING TABLES (Clean Slate)
DROP TABLE IF EXISTS public.automation_tasks CASCADE;
DROP TABLE IF EXISTS public.wallet_commitments CASCADE;
DROP TABLE IF EXISTS public.token_ledger CASCADE;
DROP TABLE IF EXISTS public.wallets CASCADE;

-- 🟦 1. WALLETS TABLE
CREATE TABLE public.wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  org_id UUID,
  agent_id UUID,
  wallet_type TEXT DEFAULT 'personal',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 🟦 2. TOKEN LEDGER TABLE (Final transactions)
CREATE TABLE public.token_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID REFERENCES public.wallets(id) ON DELETE CASCADE,
  entry_type TEXT NOT NULL CHECK (entry_type IN ('earn', 'spend', 'purchase', 'transfer', 'credit', 'debit')),
  amount INTEGER NOT NULL,
  description TEXT,
  source TEXT,
  reference_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 🟦 3. WALLET COMMITMENTS TABLE (Tokens reserved but not yet spent)
CREATE TABLE public.wallet_commitments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID REFERENCES public.wallets(id) ON DELETE CASCADE,
  commitment_type TEXT NOT NULL,
  reserved_amount INTEGER NOT NULL CHECK (reserved_amount > 0),
  status TEXT NOT NULL CHECK (status IN ('active', 'executed', 'cancelled')),
  related_object_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 🟦 4. AUTOMATION TASKS TABLE (Box 4 Execution)
CREATE TABLE public.automation_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  task_type TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('queued', 'running', 'completed', 'failed')),
  related_commitment_id UUID REFERENCES public.wallet_commitments(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 🟦 INDEXES FOR PERFORMANCE
CREATE INDEX idx_wallets_user_id ON public.wallets(user_id);
CREATE INDEX idx_token_ledger_wallet_id ON public.token_ledger(wallet_id);
CREATE INDEX idx_token_ledger_created_at ON public.token_ledger(created_at DESC);
CREATE INDEX idx_wallet_commitments_wallet_id ON public.wallet_commitments(wallet_id);
CREATE INDEX idx_wallet_commitments_status ON public.wallet_commitments(status);
CREATE INDEX idx_automation_tasks_user_id ON public.automation_tasks(user_id);
CREATE INDEX idx_automation_tasks_status ON public.automation_tasks(status);
CREATE INDEX idx_automation_tasks_commitment_id ON public.automation_tasks(related_commitment_id);

-- 🟦 ENABLE ROW LEVEL SECURITY
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.token_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_commitments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.automation_tasks ENABLE ROW LEVEL SECURITY;

-- 🟦 RLS POLICIES
CREATE POLICY "Users can view their own wallet" ON public.wallets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own wallet" ON public.wallets FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own ledger" ON public.token_ledger FOR SELECT 
USING (wallet_id IN (SELECT id FROM public.wallets WHERE user_id = auth.uid()));

CREATE POLICY "Users can view their own commitments" ON public.wallet_commitments FOR SELECT 
USING (wallet_id IN (SELECT id FROM public.wallets WHERE user_id = auth.uid()));

CREATE POLICY "Users can view their own tasks" ON public.automation_tasks FOR SELECT 
USING (user_id = auth.uid());

-- 🟦 CORE RPC FUNCTIONS (Backend Source of Truth)

-- 1. Available Wallet Balance (Total - Active Commitments)
CREATE OR REPLACE FUNCTION get_wallet_balance(p_wallet_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_total INTEGER;
  v_reserved_amount INTEGER;
BEGIN
  -- Verify wallet ownership (optional but recommended)
  -- SELECT user_id FROM wallets WHERE id = p_wallet_id; -- Should check auth.uid()
  
  -- Calculate Total (Earnings + Purchases + Credits - Spent - Debits)
  SELECT (
    COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = p_wallet_id AND entry_type IN ('earn', 'purchase', 'credit')), 0) -
    COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = p_wallet_id AND entry_type IN ('spend', 'debit')), 0)
  ) INTO v_wallet_total;
  
  -- Calculate Reserved (Active commitments only)
  SELECT COALESCE(SUM(reserved_amount), 0) INTO v_reserved_amount
  FROM wallet_commitments 
  WHERE wallet_id = p_wallet_id AND status = 'active';
  
  RETURN v_wallet_total - v_reserved_amount;
END;
$$;

-- 2. Wallet History (Running Balance)
CREATE OR REPLACE FUNCTION get_wallet_history(p_wallet_id UUID)
RETURNS TABLE (day DATE, net_change INTEGER, running_balance INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH daily_changes AS (
    SELECT 
      DATE(created_at) as d,
      SUM(CASE 
        WHEN entry_type IN ('earn', 'purchase', 'credit') THEN amount 
        WHEN entry_type IN ('spend', 'debit') THEN -amount 
        ELSE 0 
      END) as change
    FROM public.token_ledger
    WHERE wallet_id = p_wallet_id
    GROUP BY DATE(created_at)
  )
  SELECT 
    d,
    change,
    SUM(change) OVER (ORDER BY d ASC)::INTEGER as rb
  FROM daily_changes
  ORDER BY d DESC;
END;
$$;

-- 3. Wallet Transactions (Updated to include description and reference_id)
CREATE OR REPLACE FUNCTION get_wallet_transactions(p_wallet_id UUID)
RETURNS TABLE (
  created_at TIMESTAMP WITH TIME ZONE, 
  entry_type TEXT, 
  amount INTEGER, 
  description TEXT,
  source TEXT,
  reference_id TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT tl.created_at, tl.entry_type, tl.amount, tl.description, tl.source, tl.reference_id
  FROM token_ledger tl
  WHERE tl.wallet_id = p_wallet_id
  ORDER BY tl.created_at DESC;
END;
$$;

-- 4. Active Commitments Summary (Grouped)
CREATE OR REPLACE FUNCTION get_wallet_commitments_summary(p_wallet_id UUID)
RETURNS TABLE (commitment_type TEXT, total_reserved_amount INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT wc.commitment_type, SUM(wc.reserved_amount)::INTEGER
  FROM wallet_commitments wc
  WHERE wc.wallet_id = p_wallet_id AND wc.status = 'active'
  GROUP BY wc.commitment_type;
END;
$$;

-- 5. Wallet Health (Aggregated for UI)
CREATE OR REPLACE FUNCTION get_wallet_health(p_user_id UUID, p_wallet_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_available INTEGER;
  v_reserved INTEGER;
  v_spent_30d INTEGER;
BEGIN
  v_available := get_wallet_balance(p_wallet_id);
  
  SELECT COALESCE(SUM(reserved_amount), 0) INTO v_reserved
  FROM wallet_commitments WHERE wallet_id = p_wallet_id AND status = 'active';
  
  SELECT COALESCE(SUM(amount), 0) INTO v_spent_30d
  FROM token_ledger WHERE wallet_id = p_wallet_id AND entry_type = 'spend' AND created_at >= NOW() - INTERVAL '30 days';
  
  RETURN JSON_BUILD_OBJECT(
    'availableTokens', v_available,
    'reservedTokens', v_reserved,
    'tokensSpentLast30Days', v_spent_30d,
    'expiringNext7Days', 0
  );
END;
$$;

-- 6. Recommended Interventions (Mock)
CREATE OR REPLACE FUNCTION get_recommended_interventions(p_user_id UUID)
RETURNS TABLE (intervention_type TEXT, description TEXT, token_cost INTEGER, action_key TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 'system'::TEXT, '3 stalled buyers detected - activate AI call cleanup'::TEXT, 15::INTEGER, 'activate_ai_cleanup'::TEXT
  UNION ALL
  SELECT 'alert'::TEXT, '1 deal at risk - live transfer recommended'::TEXT, 100::INTEGER, 'escalate_live_call'::TEXT;
END;
$$;

-- 7. Operational Trust Level (Mock)
CREATE OR REPLACE FUNCTION get_operational_trust(p_user_id UUID)
RETURNS TABLE (current_level INTEGER, next_level INTEGER, progress_percent INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY SELECT 18::INTEGER, 19::INTEGER, 65::INTEGER;
END;
$$;

-- 8. Automation Summary
CREATE OR REPLACE FUNCTION get_automation_summary(p_user_id UUID)
RETURNS TABLE (va_status TEXT, active_assignments_count INTEGER, running_tasks_count INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY SELECT 'online'::TEXT, 3::INTEGER, 2::INTEGER;
END;
$$;

-- 9. BOX 2: EXECUTE ACTION (The critical missing RPC)
CREATE OR REPLACE FUNCTION execute_action(
  p_user_id UUID,
  p_action_type TEXT,
  p_token_cost INTEGER,
  p_related_object_id UUID DEFAULT NULL
)
RETURNS TABLE (success BOOLEAN, commitment_id UUID, task_id UUID, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_id UUID;
  v_balance INTEGER;
  v_comm_id UUID;
  v_task_id UUID;
BEGIN
  -- 1. Get Wallet
  SELECT id INTO v_wallet_id FROM wallets WHERE user_id = p_user_id;
  IF v_wallet_id IS NULL THEN
    RETURN QUERY SELECT false, NULL::UUID, NULL::UUID, 'Wallet not found'::TEXT;
    RETURN;
  END IF;
  
  -- 2. Check Balance
  v_balance := get_wallet_balance(v_wallet_id);
  IF v_balance < p_token_cost THEN
    RETURN QUERY SELECT false, NULL::UUID, NULL::UUID, 'Insufficient tokens'::TEXT;
    RETURN;
  END IF;
  
  -- 3. Create Commitment (Box 3)
  INSERT INTO wallet_commitments (wallet_id, commitment_type, reserved_amount, status, related_object_id)
  VALUES (v_wallet_id, p_action_type, p_token_cost, 'active', p_related_object_id)
  RETURNING id INTO v_comm_id;
  
  -- 4. Create Task (Box 4)
  INSERT INTO automation_tasks (user_id, task_type, status, related_commitment_id)
  VALUES (p_user_id, p_action_type, 'queued', v_comm_id)
  RETURNING id INTO v_task_id;
  
  RETURN QUERY SELECT true, v_comm_id, v_task_id, 'Action initiated successfully'::TEXT;
END;
$$;

-- 10. BOX 5: COMPLETE TASK (The critical missing RPC)
CREATE OR REPLACE FUNCTION complete_task(
  p_task_id UUID,
  p_success BOOLEAN,
  p_outcome TEXT DEFAULT NULL
)
RETURNS TABLE (success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_comm_id UUID;
  v_wallet_id UUID;
  v_amount INTEGER;
  v_type TEXT;
BEGIN
  -- 1. Get Task & Commitment info
  SELECT related_commitment_id INTO v_comm_id FROM automation_tasks WHERE id = p_task_id;
  IF v_comm_id IS NULL THEN
    RETURN QUERY SELECT false, 'Task not found'::TEXT;
    RETURN;
  END IF;
  
  SELECT wallet_id, reserved_amount, commitment_type INTO v_wallet_id, v_amount, v_type
  FROM wallet_commitments WHERE id = v_comm_id;
  
  -- 2. Update Task Status
  UPDATE automation_tasks SET status = CASE WHEN p_success THEN 'completed' ELSE 'failed' END WHERE id = p_task_id;
  
  IF p_success THEN
    -- 3. Mark Commitment as Executed
    UPDATE wallet_commitments SET status = 'executed' WHERE id = v_comm_id;
    -- 4. Create Ledger Entry (Box 6)
    INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
    VALUES (v_wallet_id, 'spend', v_amount, COALESCE(p_outcome, v_type));
    
    RETURN QUERY SELECT true, 'Task completed and tokens spent'::TEXT;
  ELSE
    -- 5. Cancel Commitment (Tokens returned automatically to available balance)
    UPDATE wallet_commitments SET status = 'cancelled' WHERE id = v_comm_id;
    RETURN QUERY SELECT true, 'Task failed and tokens released'::TEXT;
  END IF;
END;
$$;

-- 🟦 HELPER: Get all wallets for user (RPC)
CREATE OR REPLACE FUNCTION get_all_wallets_for_user(p_user_id UUID)
RETURNS TABLE (wallet_id UUID, wallet_type TEXT, balance INTEGER, org_id UUID, agent_id UUID)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT w.id, w.wallet_type, get_wallet_balance(w.id), w.org_id, w.agent_id
  FROM wallets w WHERE w.user_id = p_user_id;
END;
$$;

-- 🟦 HELPER: Create wallet for user
CREATE OR REPLACE FUNCTION create_wallet_for_user(p_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO public.wallets (user_id) VALUES (p_user_id)
  ON CONFLICT (user_id) DO UPDATE SET created_at = NOW()
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

-- =====================================================================================
-- END OF SCRIPT
-- =====================================================================================
