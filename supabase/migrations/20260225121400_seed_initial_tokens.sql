-- Seed initial tokens for testing
-- This adds some initial tokens to the wallet for testing purposes

-- Get the first user and add initial tokens
DO $$
DECLARE
    v_user_id UUID;
    v_wallet_id UUID;
BEGIN
    -- Get a user (you can replace this with a specific user ID)
    SELECT id INTO v_user_id 
    FROM auth.users 
    LIMIT 1;
    
    IF v_user_id IS NOT NULL THEN
        -- Get or create wallet for this user
        SELECT id INTO v_wallet_id
        FROM wallets
        WHERE user_id = v_user_id;
        
        IF v_wallet_id IS NULL THEN
            -- Create wallet if it doesn't exist
            INSERT INTO wallets (user_id) VALUES (v_user_id) RETURNING id INTO v_wallet_id;
        END IF;
        
        -- Add initial tokens (500 tokens as shown in the UI)
        INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
        VALUES (v_wallet_id, 'purchase', 500, 'Initial balance')
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Seeded 500 initial tokens for user %', v_user_id;
    ELSE
        RAISE NOTICE 'No users found to seed tokens';
    END IF;
END $$;
