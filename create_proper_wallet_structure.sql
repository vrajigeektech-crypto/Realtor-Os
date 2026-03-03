-- Create proper wallet structure for the token ledger system
-- The RPC function expects token_ledger table, not a simple balance column

-- First, check what tables we actually have
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check if token_ledger exists and its structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'token_ledger' 
ORDER BY ordinal_position;

-- If token_ledger doesn't exist, create it
CREATE TABLE IF NOT EXISTS token_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL,
  entry_type TEXT NOT NULL CHECK (entry_type IN ('earn', 'purchase', 'spend')),
  amount BIGINT NOT NULL DEFAULT 0,
  source TEXT,
  reference_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create wallets table if it doesn't exist (without balance column)
CREATE TABLE IF NOT EXISTS wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create wallet for current user if it doesn't exist
INSERT INTO wallets (user_id)
SELECT auth.uid()
WHERE NOT EXISTS (
  SELECT 1 FROM wallets WHERE user_id = auth.uid()
);

-- Get the created wallet ID
DO $$
DECLARE
    v_wallet_id UUID;
BEGIN
    SELECT id INTO v_wallet_id FROM wallets WHERE user_id = auth.uid();
    
    -- Insert initial ledger entry if wallet is new
    IF NOT EXISTS (SELECT 1 FROM token_ledger WHERE wallet_id = v_wallet_id) THEN
        INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
        VALUES (v_wallet_id, 'earn', 0, 'initial_balance');
    END IF;
    
    RAISE NOTICE 'Wallet created with ID: %', v_wallet_id;
END $$;

-- Test the RPC function
SELECT 'Testing get_all_wallets_for_user after wallet creation' as test_status;
SELECT * FROM get_all_wallets_for_user(auth.uid());
