-- COMPREHENSIVE WALLET TEST - Find the exact issue

-- Step 1: Show all users
SELECT '=== ALL USERS ===' as section;
SELECT id, email, created_at FROM auth.users ORDER BY created_at DESC;

-- Step 2: Show all wallets
SELECT '=== ALL WALLETS ===' as section;
SELECT w.id, w.user_id, u.email, w.wallet_type, w.created_at 
FROM wallets w 
LEFT JOIN auth.users u ON w.user_id = u.id 
ORDER BY w.created_at DESC;

-- Step 3: Show all token ledger entries
SELECT '=== ALL TOKEN LEDGER ===' as section;
SELECT tl.id, tl.wallet_id, tl.entry_type, tl.amount, tl.source, u.email
FROM token_ledger tl
JOIN wallets w ON tl.wallet_id = w.id
LEFT JOIN auth.users u ON w.user_id = u.id
ORDER BY tl.created_at DESC;

-- Step 4: Test get_all_wallets_for_user with each user
SELECT '=== TEST RPC FUNCTION WITH EACH USER ===' as section;
DO $$
DECLARE
    user_record RECORD;
    wallet_record RECORD;
    wallet_count INTEGER;
BEGIN
    FOR user_record IN SELECT id, email FROM auth.users LOOP
        RAISE NOTICE 'Testing user: % (%)', user_record.email, user_record.id;
        
        SELECT COUNT(*) INTO wallet_count 
        FROM get_all_wallets_for_user(user_record.id);
        
        RAISE NOTICE 'Wallet count for user %: %', user_record.email, wallet_count;
        
        -- Show actual wallet data
        RAISE NOTICE 'Wallet data:';
        FOR wallet_record IN 
            SELECT * FROM get_all_wallets_for_user(user_record.id) LOOP
            RAISE NOTICE '  Wallet: %, Type: %, Balance: %', 
                wallet_record.wallet_id, wallet_record.wallet_type, wallet_record.balance;
        END LOOP;
        
        RAISE NOTICE '---';
    END LOOP;
END $$;

-- Step 5: Manual balance calculation for comparison
SELECT '=== MANUAL BALANCE CALCULATION ===' as section;
SELECT 
    w.id as wallet_id,
    u.email,
    w.wallet_type,
    (SELECT COALESCE(SUM(amount), 0) 
     FROM token_ledger tl 
     WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) as earned,
    (SELECT COALESCE(SUM(amount), 0) 
     FROM token_ledger tl 
     WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend') as spent,
    ((SELECT COALESCE(SUM(amount), 0) 
     FROM token_ledger tl 
     WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) -
     (SELECT COALESCE(SUM(amount), 0) 
     FROM token_ledger tl 
     WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend')) as net_balance
FROM wallets w
JOIN auth.users u ON w.user_id = u.id;

-- Step 6: Check function definition
SELECT '=== FUNCTION DEFINITION ===' as section;
SELECT 
    routine_name,
    routine_type,
    external_language,
    security_type
FROM information_schema.routines 
WHERE routine_name = 'get_all_wallets_for_user';

-- Step 7: Create a simple test function
SELECT '=== CREATE SIMPLE TEST FUNCTION ===' as section;
CREATE OR REPLACE FUNCTION test_wallet_function(p_user_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_wallet_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_wallet_count FROM wallets WHERE user_id = p_user_id;
    
    IF v_wallet_count = 0 THEN
        RETURN 'NO_WALLET';
    ELSIF v_wallet_count > 0 THEN
        RETURN 'HAS_WALLET';
    ELSE
        RETURN 'ERROR';
    END IF;
END;
$$;

-- Step 8: Test simple function
SELECT '=== TEST SIMPLE FUNCTION ===' as section;
SELECT 
    u.email,
    test_wallet_function(u.id) as result
FROM auth.users u;

-- Step 9: Create wallet for any user that doesn't have one
SELECT '=== ENSURE ALL USERS HAVE WALLETS ===' as section;
INSERT INTO wallets (user_id, wallet_type)
SELECT id, 'personal' FROM auth.users 
WHERE id NOT IN (SELECT user_id FROM wallets);

-- Step 10: Add tokens if needed
SELECT '=== ENSURE ALL WALLETS HAVE TOKENS ===' as section;
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT w.id, 'earn', 100, 'test_tokens'
FROM wallets w
LEFT JOIN token_ledger tl ON w.id = tl.wallet_id
WHERE tl.wallet_id IS NULL;

-- Step 11: Final test
SELECT '=== FINAL TEST ===' as section;
SELECT 
    u.email,
    (SELECT COUNT(*) FROM get_all_wallets_for_user(u.id)) as rpc_wallet_count,
    (SELECT COUNT(*) FROM wallets WHERE user_id = u.id) as direct_wallet_count
FROM auth.users u;
