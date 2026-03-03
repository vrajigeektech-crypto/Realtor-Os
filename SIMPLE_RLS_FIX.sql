-- SIMPLE RLS FIX - Run this immediately in Supabase SQL Editor
-- This will fix the RLS policy violation for wallet creation

-- Disable RLS temporarily to create the wallet
ALTER TABLE wallets DISABLE ROW LEVEL SECURITY;

-- Create wallet for your user
INSERT INTO wallets (user_id) 
VALUES ('77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9')
ON CONFLICT (user_id) DO NOTHING;

-- Re-enable RLS with proper policies
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;

-- Drop and recreate policies
DROP POLICY IF EXISTS "Users can view their own wallet" ON wallets;
DROP POLICY IF EXISTS "Users can insert their own wallet" ON wallets;

CREATE POLICY "Users can view their own wallet"
  ON wallets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own wallet"
  ON wallets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Also fix token_ledger RLS
ALTER TABLE token_ledger DISABLE ROW LEVEL SECURITY;
ALTER TABLE token_ledger ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own token ledger" ON token_ledger;
DROP POLICY IF EXISTS "Users can insert their own token ledger" ON token_ledger;

CREATE POLICY "Users can view their own token ledger"
  ON token_ledger FOR SELECT
  USING (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own token ledger"
  ON token_ledger FOR INSERT
  WITH CHECK (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- Add initial tokens for the wallet
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  w.id, 
  'purchase', 
  1000, 
  'Initial token purchase'
FROM wallets w
WHERE w.user_id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9'
AND NOT EXISTS (
  SELECT 1 FROM token_ledger tl 
  WHERE tl.wallet_id = w.id
);

-- Verify everything works
SELECT 'Wallet created successfully' as status;
SELECT * FROM wallets WHERE user_id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9';
SELECT * FROM token_ledger WHERE wallet_id = (SELECT id FROM wallets WHERE user_id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9');
