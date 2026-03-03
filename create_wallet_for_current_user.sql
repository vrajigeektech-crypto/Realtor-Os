-- Create wallet and test data for the current authenticated user
-- Run this after a user logs in to create their wallet and test data

-- First, let's see what users exist in the auth system
SELECT id, email, created_at FROM auth.users LIMIT 5;

-- Create wallet for a specific user (replace with actual user ID from above)
-- This example uses the ID from the Flutter code, but you should use the actual logged-in user ID

-- Step 1: Create wallet for user
SELECT create_wallet_for_user('c819a131-ca23-4296-a26a-aed7e430c735') as wallet_id;

-- Step 2: Add initial tokens (purchase)
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  id, 
  'purchase', 
  1000, 
  'Initial token purchase'
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

-- Step 3: Add earned tokens
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  id, 
  'earn', 
  500, 
  'Task completion reward'
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

-- Step 4: Create some sample spend transactions
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  id, 
  'spend', 
  50, 
  'AI cleanup task'
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

-- Step 5: Create active commitments
INSERT INTO wallet_commitments (wallet_id, commitment_type, reserved_amount, status, related_object_id)
SELECT 
  id, 
  'ai_cleanup', 
  15, 
  'active', 
  gen_random_uuid()
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

INSERT INTO wallet_commitments (wallet_id, commitment_type, reserved_amount, status, related_object_id)
SELECT 
  id, 
  'live_transfer', 
  100, 
  'active', 
  gen_random_uuid()
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

-- Step 6: Create automation tasks
INSERT INTO automation_tasks (user_id, task_type, status, related_commitment_id)
SELECT 
  'c819a131-ca23-4296-a26a-aed7e430c735',
  'ai_cleanup',
  'queued',
  id
FROM wallet_commitments 
WHERE wallet_id = (SELECT id FROM wallets WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735')
  AND commitment_type = 'ai_cleanup'
  AND status = 'active'
LIMIT 1;

-- Verification query
SELECT 
  'WALLET SETUP VERIFICATION' as test_name,
  w.id as wallet_id,
  w.user_id,
  (SELECT get_wallet_balance(w.id)) as available_balance,
  (SELECT COUNT(*) FROM wallet_commitments wc WHERE wc.wallet_id = w.id AND wc.status = 'active') as active_commitments,
  (SELECT COUNT(*) FROM token_ledger tl WHERE tl.wallet_id = w.id) as total_transactions
FROM wallets w
WHERE w.user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';
