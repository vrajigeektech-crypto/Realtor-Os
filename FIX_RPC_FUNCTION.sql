-- Fix the get_all_wallets_for_user RPC function
-- The function might be missing or incorrectly defined

-- Step 1: Check if the function exists
SELECT 'Step 1: Check if get_all_wallets_for_user exists' as debug_step;
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name = 'get_all_wallets_for_user';

-- Step 2: Drop and recreate the function with proper debugging
SELECT 'Step 2: Drop and recreate function' as debug_step;
DROP FUNCTION IF EXISTS get_all_wallets_for_user(p_user_id UUID);

CREATE OR REPLACE FUNCTION get_all_wallets_for_user(p_user_id UUID)
RETURNS TABLE (
  wallet_id UUID,
  wallet_type TEXT,
  balance INTEGER,
  org_id UUID,
  agent_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Debug: Log the input parameter
  RAISE NOTICE 'get_all_wallets_for_user called with user_id: %', p_user_id;
  
  -- Debug: Check if user exists
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = p_user_id) THEN
    RAISE NOTICE 'User % does not exist in auth.users', p_user_id;
    RETURN;
  END IF;
  
  -- Debug: Check if wallet exists
  IF NOT EXISTS (SELECT 1 FROM wallets WHERE user_id = p_user_id) THEN
    RAISE NOTICE 'No wallet found for user %', p_user_id;
    RETURN;
  END IF;
  
  -- Return the wallet data
  RETURN QUERY
  SELECT 
    w.id as wallet_id,
    COALESCE(w.wallet_type, 'personal') as wallet_type,
    COALESCE(
      (SELECT COALESCE(SUM(amount), 0) 
       FROM token_ledger tl 
       WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) -
      (SELECT COALESCE(SUM(amount), 0) 
       FROM token_ledger tl 
       WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend'),
      0
    ) as balance,
    w.org_id,
    w.agent_id
  FROM wallets w
  WHERE w.user_id = p_user_id;
  
  RAISE NOTICE 'Returning wallet data for user %', p_user_id;
END;
$$;

-- Step 3: Test the function with a real user ID
SELECT 'Step 3: Test function with real user' as debug_step;
-- Get the first user from auth.users
DO $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT id INTO v_user_id FROM auth.users LIMIT 1;
    
    IF v_user_id IS NOT NULL THEN
        RAISE NOTICE 'Testing with user ID: %', v_user_id;
        PERFORM get_all_wallets_for_user(v_user_id);
    ELSE
        RAISE NOTICE 'No users found in auth.users';
    END IF;
END $$;

-- Step 4: Test with all users
SELECT 'Step 4: Test function with all users' as debug_step;
SELECT 
    u.id as user_id,
    u.email,
    (SELECT COUNT(*) FROM get_all_wallets_for_user(u.id)) as wallet_count
FROM auth.users u;

-- Step 5: Manual verification of wallet data
SELECT 'Step 5: Manual wallet verification' as debug_step;
SELECT 
    w.id as wallet_id,
    w.user_id,
    u.email,
    w.wallet_type,
    w.org_id,
    w.agent_id,
    (SELECT COALESCE(SUM(amount), 0) 
     FROM token_ledger tl 
     WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) -
    (SELECT COALESCE(SUM(amount), 0) 
     FROM token_ledger tl 
     WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend') as calculated_balance
FROM wallets w
JOIN auth.users u ON w.user_id = u.id;

-- Step 6: Create a wallet for current SQL editor user if needed
SELECT 'Step 6: Ensure wallet for current SQL user' as debug_step;
INSERT INTO wallets (user_id)
VALUES (auth.uid())
ON CONFLICT (user_id) DO NOTHING;

-- Step 7: Test with current SQL editor user
SELECT 'Step 7: Test with current SQL user' as debug_step;
SELECT * FROM get_all_wallets_for_user(auth.uid());
