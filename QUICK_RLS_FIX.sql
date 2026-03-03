-- QUICK FIX FOR RLS POLICY VIOLATION
-- Run this in Supabase SQL Editor

-- Step 1: Create wallets for all existing users
INSERT INTO wallets (user_id)
SELECT id 
FROM auth.users 
WHERE id NOT IN (SELECT user_id FROM wallets);

-- Step 2: Add initial tokens for new wallets
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  w.id, 
  'purchase', 
  1000, 
  'Initial token purchase'
FROM wallets w
WHERE w.id NOT IN (SELECT DISTINCT wallet_id FROM token_ledger);

-- Step 3: Add welcome bonus
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  w.id, 
  'earn', 
  500, 
  'Welcome bonus'
FROM wallets w
WHERE w.id NOT IN (
  SELECT DISTINCT wallet_id 
  FROM token_ledger 
  WHERE entry_type = 'earn'
);

-- Step 4: Verify everything is working
SELECT 
  'WALLET SETUP COMPLETE' as status,
  u.email,
  w.id as wallet_id,
  (SELECT COALESCE(SUM(CASE WHEN entry_type IN ('earn', 'purchase') THEN amount ELSE 0 END), 0) 
   FROM token_ledger tl WHERE tl.wallet_id = w.id) as total_tokens,
  (SELECT COUNT(*) FROM token_ledger tl WHERE tl.wallet_id = w.id) as transaction_count
FROM auth.users u
JOIN wallets w ON u.id = w.user_id
ORDER BY u.created_at DESC
LIMIT 10;
