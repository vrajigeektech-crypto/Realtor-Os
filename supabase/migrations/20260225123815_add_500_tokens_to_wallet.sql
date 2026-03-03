-- Add 500 tokens to the current user's wallet
-- This will add tokens for user demo4@gmail.com (ID: 9d5a641a-eb8d-4f25-9651-a8f5217effc9)

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
    VALUES (v_wallet_id, 'purchase', 500, 'Added 500 tokens')
    ON CONFLICT DO NOTHING;
    
    -- Get current balance
    SELECT (
        COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = v_wallet_id AND entry_type IN ('earn', 'purchase')), 0) -
        COALESCE((SELECT SUM(amount) FROM token_ledger WHERE wallet_id = v_wallet_id AND entry_type = 'spend'), 0)
    ) INTO v_current_balance;
    
    RAISE NOTICE 'Added 500 tokens to wallet. Current balance: %', v_current_balance;
END $$;