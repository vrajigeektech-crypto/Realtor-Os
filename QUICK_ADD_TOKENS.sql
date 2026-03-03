-- QUICK ADD 500 TOKENS - Run this in Supabase SQL Editor
-- Go to: https://supabase.com/dashboard/project/macenrukodfgfeowrqqf/sql

-- Add 500 tokens to user demo4@gmail.com (ID: 9d5a641a-eb8d-4f25-9651-a8f5217effc9)
DO $$
DECLARE
    v_user_id UUID := '9d5a641a-eb8d-4f25-9651-a8f5217effc9';
    v_wallet_id UUID;
    v_current_balance BIGINT;
BEGIN
    -- Get or create wallet for this user
    SELECT id INTO v_wallet_id
    FROM wallets
    WHERE user_id = v_user_id;
    
    IF v_wallet_id IS NULL THEN
        -- Create wallet if it doesn't exist
        INSERT INTO wallets (user_id) VALUES (v_user_id) RETURNING id INTO v_wallet_id;
        RAISE NOTICE 'Created new wallet for user %', v_user_id;
    END IF;
    
    -- Add 500 tokens
    INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
    VALUES (v_wallet_id, 'purchase', 500, 'Added 500 tokens');
    
    -- Get current balance
    SELECT (
        COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = v_wallet_id AND entry_type IN ('earn', 'purchase')), 0) -
        COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = v_wallet_id AND entry_type = 'spend'), 0)
    ) INTO v_current_balance;
    
    RAISE NOTICE 'Added 500 tokens to wallet. Current balance: %', v_current_balance;
END $$;

-- Check the result
SELECT 
    w.user_id,
    w.id as wallet_id,
    COALESCE(
        (SELECT SUM(amount) FROM token_ledger tl WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) -
        (SELECT SUM(amount) FROM token_ledger tl WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend'),
        0
    ) as current_balance
FROM wallets w
WHERE w.user_id = '9d5a641a-eb8d-4f25-9651-a8f5217effc9';
