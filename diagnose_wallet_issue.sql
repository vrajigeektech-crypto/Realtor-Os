-- Diagnose the wallet issue step by step

-- 1. Check current user ID
SELECT 'Current user ID:' as info, auth.uid() as user_id;

-- 2. Check if wallets table exists and has data
SELECT 'Wallets table count:' as info, COUNT(*) as count FROM wallets;

-- 3. Show all wallets (if any)
SELECT 'All wallets:' as info, id, user_id, created_at FROM wallets;

-- 4. Check if current user has a wallet
SELECT 'Current user wallet:' as info, id, user_id, created_at 
FROM wallets 
WHERE user_id = auth.uid();

-- 5. Check if token_ledger exists and has data
SELECT 'Token ledger count:' as info, COUNT(*) as count FROM token_ledger;

-- 6. Show token ledger entries for current user's wallet
SELECT 'Token ledger for current user:' as info, 
       tl.wallet_id, tl.entry_type, tl.amount, tl.source, tl.created_at
FROM token_ledger tl
JOIN wallets w ON tl.wallet_id = w.id
WHERE w.user_id = auth.uid();

-- 7. Test the RPC function directly with current user ID
SELECT 'Testing RPC function:' as info;
SELECT * FROM get_all_wallets_for_user(auth.uid());

-- 8. If no wallet exists, create one manually
INSERT INTO wallets (user_id)
VALUES (auth.uid())
ON CONFLICT (user_id) DO NOTHING;

-- 9. Get the wallet ID we just created
SELECT 'Created wallet ID:' as info, id, user_id 
FROM wallets 
WHERE user_id = auth.uid();

-- 10. Create initial token ledger entry
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT id, 'earn', 100, 'welcome_bonus'
FROM wallets 
WHERE user_id = auth.uid()
AND NOT EXISTS (
  SELECT 1 FROM token_ledger WHERE wallet_id = wallets.id
);

-- 11. Test RPC function again
SELECT 'Testing RPC function after setup:' as info;
SELECT * FROM get_all_wallets_for_user(auth.uid());
