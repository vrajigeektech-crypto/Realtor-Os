-- SIMPLE DIRECT FIX - Create a working wallet system

-- Step 1: Drop everything and start fresh
DROP TABLE IF EXISTS automation_tasks CASCADE;
DROP TABLE IF EXISTS wallet_commitments CASCADE;
DROP TABLE IF EXISTS token_ledger CASCADE;
DROP TABLE IF EXISTS wallets CASCADE;

-- Step 2: Create simple tables
CREATE TABLE wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  wallet_type TEXT DEFAULT 'personal',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE token_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
  entry_type TEXT NOT NULL CHECK (entry_type IN ('earn', 'spend', 'purchase')),
  amount INTEGER NOT NULL DEFAULT 0,
  source TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 3: Enable RLS
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE token_ledger ENABLE ROW LEVEL SECURITY;

-- Step 4: Simple RLS policies
CREATE POLICY "Users can view own wallet" ON wallets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own wallet" ON wallets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view own ledger" ON token_ledger FOR SELECT 
USING (wallet_id IN (SELECT id FROM wallets WHERE user_id = auth.uid()));

-- Step 5: Create a very simple RPC function
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
    w.wallet_type,
    COALESCE(
      (SELECT SUM(amount) FROM token_ledger tl WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) -
      (SELECT SUM(amount) FROM token_ledger tl WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend'),
      0
    )::INTEGER as balance,
    NULL::UUID,
    NULL::UUID
  FROM wallets w
  WHERE w.user_id = p_user_id;
END;
$$;

-- Step 6: Create wallet for ALL users
INSERT INTO wallets (user_id, wallet_type)
SELECT id, 'personal' FROM auth.users
ON CONFLICT (user_id) DO NOTHING;

-- Step 7: Add tokens to ALL wallets
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT w.id, 'earn', 1000, 'Initial tokens'
FROM wallets w
LEFT JOIN token_ledger tl ON w.id = tl.wallet_id
WHERE tl.wallet_id IS NULL;

-- Step 8: Show what we have
SELECT '=== USERS ===' as info;
SELECT id, email FROM auth.users;

SELECT '=== WALLETS ===' as info;
SELECT w.id, w.user_id, u.email, w.wallet_type 
FROM wallets w
JOIN auth.users u ON w.user_id = u.id;

SELECT '=== TOKEN LEDGER ===' as info;
SELECT tl.wallet_id, tl.entry_type, tl.amount, u.email
FROM token_ledger tl
JOIN wallets w ON tl.wallet_id = w.id
JOIN auth.users u ON w.user_id = u.id;

-- Step 9: Test the function with each user
SELECT '=== TEST FUNCTION ===' as info;
SELECT 
  u.email,
  (SELECT COUNT(*) FROM get_all_wallets_for_user(u.id)) as wallet_count
FROM auth.users u;

-- Step 10: Show actual function results
SELECT '=== FUNCTION RESULTS ===' as info;
DO $$
DECLARE
    user_record RECORD;
    wallet_record RECORD;
BEGIN
    FOR user_record IN SELECT id, email FROM auth.users LOOP
        RAISE NOTICE 'User: % (%)', user_record.email, user_record.id;
        FOR wallet_record IN SELECT * FROM get_all_wallets_for_user(user_record.id) LOOP
            RAISE NOTICE '  Wallet ID: %, Type: %, Balance: %', 
                wallet_record.wallet_id, wallet_record.wallet_type, wallet_record.balance;
        END LOOP;
    END LOOP;
END $$;
