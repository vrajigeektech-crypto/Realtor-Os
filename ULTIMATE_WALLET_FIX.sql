-- ULTIMATE WALLET FIX - Create wallet for ACTUAL current user
-- This will fix the wallet issue for the real logged-in user

-- First, drop and recreate everything cleanly
DROP TABLE IF EXISTS automation_tasks CASCADE;
DROP TABLE IF EXISTS wallet_commitments CASCADE;
DROP TABLE IF EXISTS token_ledger CASCADE;
DROP TABLE IF EXISTS wallets CASCADE;

-- Recreate tables with correct structure
CREATE TABLE wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  org_id UUID,
  agent_id UUID,
  wallet_type TEXT DEFAULT 'personal',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE token_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
  entry_type TEXT NOT NULL CHECK (entry_type IN ('earn', 'spend', 'purchase', 'transfer')),
  amount INTEGER NOT NULL,
  source TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE wallet_commitments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
  commitment_type TEXT NOT NULL,
  reserved_amount INTEGER NOT NULL CHECK (reserved_amount > 0),
  status TEXT NOT NULL CHECK (status IN ('active', 'executed', 'cancelled')),
  related_object_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE automation_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  task_type TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('queued', 'running', 'completed', 'failed')),
  related_commitment_id UUID REFERENCES wallet_commitments(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_token_ledger_wallet_id ON token_ledger(wallet_id);
CREATE INDEX idx_token_ledger_created_at ON token_ledger(created_at DESC);
CREATE INDEX idx_wallet_commitments_wallet_id ON wallet_commitments(wallet_id);
CREATE INDEX idx_wallet_commitments_status ON wallet_commitments(status);
CREATE INDEX idx_automation_tasks_user_id ON automation_tasks(user_id);
CREATE INDEX idx_automation_tasks_status ON automation_tasks(status);

-- Enable RLS
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE token_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_commitments ENABLE ROW LEVEL SECURITY;
ALTER TABLE automation_tasks ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own wallet" ON wallets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own wallet" ON wallets FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own ledger" ON token_ledger FOR SELECT 
USING (wallet_id IN (SELECT id FROM wallets WHERE user_id = auth.uid()));

CREATE POLICY "Users can view their own commitments" ON wallet_commitments FOR SELECT 
USING (wallet_id IN (SELECT id FROM wallets WHERE user_id = auth.uid()));

CREATE POLICY "Users can view their own tasks" ON automation_tasks FOR SELECT 
USING (user_id = auth.uid());

-- Create RPC functions
CREATE OR REPLACE FUNCTION get_wallet_balance(p_wallet_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_wallet_total INTEGER;
  v_reserved_amount INTEGER;
BEGIN
  SELECT (
    COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = p_wallet_id AND entry_type IN ('earn', 'purchase')), 0) -
    COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = p_wallet_id AND entry_type = 'spend'), 0)
  ) INTO v_wallet_total;
  
  SELECT COALESCE(SUM(reserved_amount), 0) INTO v_reserved_amount
  FROM wallet_commitments 
  WHERE wallet_id = p_wallet_id AND status = 'active';
  
  RETURN v_wallet_total - v_reserved_amount;
END;
$$;

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

CREATE OR REPLACE FUNCTION create_wallet_for_user(p_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO wallets (user_id) VALUES (p_user_id)
  ON CONFLICT (user_id) DO UPDATE SET created_at = NOW()
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

-- NOW CREATE WALLET FOR THE ACTUAL CURRENT USER
SELECT 'Creating wallet for current user:' as step;
SELECT create_wallet_for_user(auth.uid()) as wallet_id;

-- Add initial tokens for the current user
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT id, 'purchase', 1000, 'Initial token purchase'
FROM wallets WHERE user_id = auth.uid();

INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT id, 'earn', 500, 'Welcome bonus'
FROM wallets WHERE user_id = auth.uid();

-- Verify everything worked
SELECT 'Verification - Current user:' as step;
SELECT auth.uid() as current_user_id;

SELECT 'Verification - Wallet created:' as step;
SELECT id, user_id, wallet_type, created_at FROM wallets WHERE user_id = auth.uid();

SELECT 'Verification - Token ledger entries:' as step;
SELECT wallet_id, entry_type, amount, source, created_at FROM token_ledger 
WHERE wallet_id IN (SELECT id FROM wallets WHERE user_id = auth.uid());

SELECT 'Verification - RPC function test:' as step;
SELECT * FROM get_all_wallets_for_user(auth.uid());

SELECT 'Verification - Wallet balance test:' as step;
SELECT get_wallet_balance(w.id) as available_balance
FROM wallets w 
WHERE w.user_id = auth.uid();
