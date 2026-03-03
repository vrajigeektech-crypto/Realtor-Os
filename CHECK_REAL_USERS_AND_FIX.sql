-- Check what users actually exist in auth.users and fix wallet creation

-- Step 1: Check all users in auth.users
SELECT 'Step 1: All users in auth.users' as debug_step;
SELECT id, email, created_at, last_sign_in_at 
FROM auth.users 
ORDER BY created_at DESC;

-- Step 2: Check current auth.uid() in SQL editor
SELECT 'Step 2: Current auth.uid() in SQL editor' as debug_step;
SELECT auth.uid() as current_sql_user_id;

-- Step 3: Check if the hardcoded user ID from Flutter logs exists
SELECT 'Step 3: Does hardcoded user exist?' as debug_step;
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM auth.users WHERE id = 'c819a131-ca23-4296-a26a-aed7e430c735') 
    THEN 'YES - User exists in auth.users'
    ELSE 'NO - User does not exist in auth.users'
  END as user_exists;

-- Step 4: Clean up any existing wallets that reference non-existent users
SELECT 'Step 4: Clean up orphaned wallets' as debug_step;
DELETE FROM wallets WHERE user_id NOT IN (SELECT id FROM auth.users);

-- Step 5: Create wallets for all existing users that don't have one
SELECT 'Step 5: Create wallets for all existing users' as debug_step;
INSERT INTO wallets (user_id)
SELECT id FROM auth.users 
WHERE id NOT IN (SELECT user_id FROM wallets);

-- Step 6: Add initial tokens for newly created wallets
SELECT 'Step 6: Add initial tokens for new wallets' as debug_step;
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT w.id, 'purchase', 1000, 'Initial token purchase'
FROM wallets w
LEFT JOIN token_ledger tl ON w.id = tl.wallet_id
WHERE w.user_id IN (SELECT id FROM auth.users)
AND tl.wallet_id IS NULL;

INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT w.id, 'earn', 500, 'Welcome bonus'
FROM wallets w
LEFT JOIN token_ledger tl ON w.id = tl.wallet_id AND tl.entry_type = 'earn'
WHERE w.user_id IN (SELECT id FROM auth.users)
AND tl.wallet_id IS NULL;

-- Step 7: Verify all wallets now exist
SELECT 'Step 7: Verify all wallets' as debug_step;
SELECT w.id, w.user_id, u.email, w.created_at
FROM wallets w
JOIN auth.users u ON w.user_id = u.id
ORDER BY w.created_at DESC;

-- Step 8: Test RPC function for each user
SELECT 'Step 8: Test RPC for each user' as debug_step;
SELECT 
  w.user_id,
  u.email,
  (SELECT COUNT(*) FROM get_all_wallets_for_user(w.user_id)) as wallet_count
FROM wallets w
JOIN auth.users u ON w.user_id = u.id;

-- Step 9: Show token ledger for verification
SELECT 'Step 9: Token ledger verification' as debug_step;
SELECT tl.wallet_id, tl.entry_type, tl.amount, tl.source, u.email
FROM token_ledger tl
JOIN wallets w ON tl.wallet_id = w.id
JOIN auth.users u ON w.user_id = u.id
ORDER BY tl.created_at DESC;
