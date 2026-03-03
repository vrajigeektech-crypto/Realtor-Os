-- TOKEN FIX - Run this when you can access Supabase Dashboard
-- Go to: https://supabase.com/dashboard/project/macenrukodfgfeowrqqf/sql

-- Step 1: Check if user has wallet
SELECT 'Checking wallet...' as status;

-- Step 2: Create wallet if needed and add tokens
DO $$
DECLARE
    v_user_id UUID := '9d5a641a-eb8d-4f25-9651-a8f5217effc9';
    v_wallet_id UUID;
BEGIN
    -- Get existing wallet or create new one
    SELECT id INTO v_wallet_id FROM wallets WHERE user_id = v_user_id;
    
    IF v_wallet_id IS NULL THEN
        INSERT INTO wallets (user_id) VALUES (v_user_id) RETURNING id INTO v_wallet_id;
        RAISE NOTICE 'Created new wallet: %', v_wallet_id;
    ELSE
        RAISE NOTICE 'Found existing wallet: %', v_wallet_id;
    END IF;
    
    -- Add 500 tokens
    INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
    VALUES (v_wallet_id, 'purchase', 500, 'Token fix - added 500 tokens');
    
    RAISE NOTICE 'Successfully added 500 tokens to wallet %', v_wallet_id;
END $$;

-- Step 3: Verify the result
SELECT 
    'Final Result' as step,
    w.user_id,
    w.id as wallet_id,
    COALESCE(
        (SELECT SUM(amount) FROM token_ledger tl 
         WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')), 0
    ) - COALESCE(
        (SELECT SUM(amount) FROM token_ledger tl 
         WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend'), 0
    ) as final_balance
FROM wallets w
WHERE w.user_id = '9d5a641a-eb8d-4f25-9651-a8f5217effc9';
