-- Create wallet for current user if they don't have one
-- Run this after the type fix

-- Check if current user has a wallet
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM wallets WHERE user_id = auth.uid()) 
    THEN 'Wallet exists for current user'
    ELSE 'No wallet for current user - creating one now'
  END as wallet_status;

-- Create wallet for current user if it doesn't exist
INSERT INTO wallets (user_id, balance)
SELECT auth.uid(), 0.00
WHERE NOT EXISTS (
  SELECT 1 FROM wallets WHERE user_id = auth.uid()
);

-- Verify wallet creation
SELECT 'Wallet created/verified' as status, id, user_id, balance, created_at 
FROM wallets 
WHERE user_id = auth.uid();

-- Test the RPC function again
SELECT 'Testing get_all_wallets_for_user after wallet creation' as test_status;
SELECT * FROM get_all_wallets_for_user(auth.uid());
