-- REALTOR OS WALLET + EXECUTION SYSTEM
-- Test Data Creation and Verification Scripts

-- Test user ID (matches the one used in Flutter)
-- This should be a real user from your auth.users table
-- For testing, we'll use the ID from the Flutter code

-- Step 1: Create test wallet for user
SELECT create_wallet_for_user('c819a131-ca23-4296-a26a-aed7e430c735') as wallet_id;

-- Step 2: Add some initial tokens (purchase)
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  id, 
  'purchase', 
  1000, 
  'Initial token purchase'
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

-- Step 3: Add some earned tokens
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

INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  id, 
  'spend', 
  25, 
  'Live transfer escalation'
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

-- Step 5: Create some active commitments
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

INSERT INTO wallet_commitments (wallet_id, commitment_type, reserved_amount, status, related_object_id)
SELECT 
  id, 
  'broker_funded', 
  10, 
  'active', 
  gen_random_uuid()
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

-- Step 6: Create some automation tasks
INSERT INTO automation_tasks (user_id, task_type, status, related_commitment_id)
SELECT 
  'c819a131-ca23-4296-a26a-aed7e430c735',
  'ai_cleanup',
  'queued',
  id
FROM wallet_commitments 
WHERE wallet_id = (SELECT id FROM wallets WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735')
  AND commitment_type = 'ai_cleanup'
  AND status = 'active';

INSERT INTO automation_tasks (user_id, task_type, status, related_commitment_id)
SELECT 
  'c819a131-ca23-4296-a26a-aed7e430c735',
  'live_transfer',
  'running',
  id
FROM wallet_commitments 
WHERE wallet_id = (SELECT id FROM wallets WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735')
  AND commitment_type = 'live_transfer'
  AND status = 'active';

-- Step 7: Create some completed tasks with ledger entries
-- First, create a commitment that will be executed
INSERT INTO wallet_commitments (wallet_id, commitment_type, reserved_amount, status, related_object_id)
SELECT 
  id, 
  'ai_cleanup', 
  20, 
  'executed', 
  gen_random_uuid()
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735'
RETURNING id INTO executed_commitment_id;

-- Then create the corresponding task
INSERT INTO automation_tasks (user_id, task_type, status, related_commitment_id)
VALUES (
  'c819a131-ca23-4296-a26a-aed7e430c735',
  'ai_cleanup',
  'completed',
  executed_commitment_id
);

-- Finally, create the ledger entry for the executed task
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  id, 
  'spend', 
  20, 
  'Completed AI cleanup'
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

-- Step 8: Create some cancelled tasks (no ledger entry)
INSERT INTO wallet_commitments (wallet_id, commitment_type, reserved_amount, status, related_object_id)
SELECT 
  id, 
  'live_transfer', 
  50, 
  'cancelled', 
  gen_random_uuid()
FROM wallets 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735'
RETURNING id INTO cancelled_commitment_id;

INSERT INTO automation_tasks (user_id, task_type, status, related_commitment_id)
VALUES (
  'c819a131-ca23-4296-a26a-aed7e430c735',
  'live_transfer',
  'failed',
  cancelled_commitment_id
);

-- VERIFICATION QUERIES

-- Verify wallet balance calculation
SELECT 
  'WALLET BALANCE VERIFICATION' as test_name,
  w.id as wallet_id,
  (SELECT COALESCE(SUM(amount), 0) FROM token_ledger tl WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) as total_earned,
  (SELECT COALESCE(SUM(amount), 0) FROM token_ledger tl WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend') as total_spent,
  (SELECT COALESCE(SUM(reserved_amount), 0) FROM wallet_commitments wc WHERE wc.wallet_id = w.id AND wc.status = 'active') as reserved,
  (SELECT get_wallet_balance(w.id)) as available_balance_rpc
FROM wallets w
WHERE w.user_id = 'c819a131-ca23-4296-a26a-aed7e430c735';

-- Verify commitments summary
SELECT 
  'COMMITMENTS SUMMARY VERIFICATION' as test_name,
  commitment_type,
  SUM(reserved_amount) as total_reserved,
  status
FROM wallet_commitments wc
JOIN wallets w ON wc.wallet_id = w.id
WHERE w.user_id = 'c819a131-ca23-4296-a26a-aed7e430c735'
GROUP BY commitment_type, status
ORDER BY commitment_type, status;

-- Verify automation tasks
SELECT 
  'AUTOMATION TASKS VERIFICATION' as test_name,
  at.task_type,
  at.status,
  wc.commitment_type,
  wc.reserved_amount,
  wc.status as commitment_status
FROM automation_tasks at
JOIN wallet_commitments wc ON at.related_commitment_id = wc.id
JOIN wallets w ON wc.wallet_id = w.id
WHERE w.user_id = 'c819a131-ca23-4296-a26a-aed7e430c735'
ORDER BY at.task_type, at.status;

-- Verify token ledger
SELECT 
  'TOKEN LEDGER VERIFICATION' as test_name,
  tl.entry_type,
  tl.amount,
  tl.source,
  tl.created_at
FROM token_ledger tl
JOIN wallets w ON tl.wallet_id = w.id
WHERE w.user_id = 'c819a131-ca23-4296-a26a-aed7e430c735'
ORDER BY tl.created_at DESC;

-- Test the execute_action RPC
SELECT execute_action(
  'c819a131-ca23-4296-a26a-aed7e430c735',
  'ai_cleanup',
  10,
  gen_random_uuid()
);

-- Test the complete_task RPC (simulate task completion)
-- First get a task ID
SELECT id INTO test_task_id 
FROM automation_tasks 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735' 
  AND status = 'queued'
LIMIT 1;

-- Then complete it successfully
SELECT complete_task(test_task_id, true, 'Test task completed successfully');

-- Test failure case
SELECT id INTO test_task_id_2 
FROM automation_tasks 
WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735' 
  AND status = 'queued'
LIMIT 1;

SELECT complete_task(test_task_id_2, false, 'Test task failed');

-- Final verification after tests
SELECT 
  'FINAL SYSTEM VERIFICATION' as test_name,
  (SELECT get_wallet_balance(w.id)) as final_available_balance,
  (SELECT COUNT(*) FROM wallet_commitments wc JOIN wallets w ON wc.wallet_id = w.id WHERE w.user_id = 'c819a131-ca23-4296-a26a-aed7e430c735' AND wc.status = 'active') as active_commitments,
  (SELECT COUNT(*) FROM automation_tasks WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735' AND status = 'completed') as completed_tasks,
  (SELECT COUNT(*) FROM automation_tasks WHERE user_id = 'c819a131-ca23-4296-a26a-aed7e430c735' AND status = 'failed') as failed_tasks;
