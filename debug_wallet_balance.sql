-- Check token_ledger entries and wallet balance calculation
SELECT 
  tl.wallet_id,
  tl.entry_type,
  tl.amount,
  tl.description,
  tl.created_at
FROM token_ledger tl 
ORDER BY tl.created_at DESC 
LIMIT 10;

-- Check wallet balance calculation
SELECT 
  w.id as wallet_id,
  w.user_id,
  COALESCE(
    (SELECT COALESCE(SUM(amount), 0) 
     FROM token_ledger tl 
     WHERE tl.wallet_id = w.id AND tl.entry_type IN ('earn', 'purchase')) -
    (SELECT COALESCE(SUM(amount), 0) 
     FROM token_ledger tl 
     WHERE tl.wallet_id = w.id AND tl.entry_type = 'spend'),
    0
  ) as calculated_balance
FROM wallets w
WHERE w.user_id = 'demo@gmail.com' OR w.user_id LIKE '%demo%';

-- Check if wallets exist
SELECT * FROM wallets LIMIT 5;
