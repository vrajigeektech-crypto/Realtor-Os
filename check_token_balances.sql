-- ============================================================================
-- Check Token Balances in Database
-- Run this to see what token balances actually exist
-- ============================================================================

-- 1. Check if tokens_balance column exists and has data
SELECT 
  'TOKEN_BALANCE_COLUMN_CHECK' as info,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'tokens_balance';

-- 2. Show all users with their token balances
SELECT 
  'ALL_USER_TOKEN_BALANCES' as info,
  id::text,
  name,
  email,
  role,
  status,
  tokens_balance,
  is_deleted
FROM public.users 
ORDER BY name;

-- 3. Count users by token balance ranges
SELECT 
  'TOKEN_BALANCE_DISTRIBUTION' as info,
  COUNT(*) as user_count,
  CASE 
    WHEN tokens_balance = 0 THEN 'Zero Balance'
    WHEN tokens_balance > 0 AND tokens_balance <= 100 THEN '1-100 Tokens'
    WHEN tokens_balance > 100 AND tokens_balance <= 500 THEN '101-500 Tokens'
    WHEN tokens_balance > 500 AND tokens_balance <= 1000 THEN '501-1000 Tokens'
    WHEN tokens_balance > 1000 THEN '1000+ Tokens'
    ELSE 'Unknown'
  END as balance_range
FROM public.users 
WHERE is_deleted = false
GROUP BY 
  CASE 
    WHEN tokens_balance = 0 THEN 'Zero Balance'
    WHEN tokens_balance > 0 AND tokens_balance <= 100 THEN '1-100 Tokens'
    WHEN tokens_balance > 100 AND tokens_balance <= 500 THEN '101-500 Tokens'
    WHEN tokens_balance > 500 AND tokens_balance <= 1000 THEN '501-1000 Tokens'
    WHEN tokens_balance > 1000 THEN '1000+ Tokens'
    ELSE 'Unknown'
  END
ORDER BY user_count DESC;

-- 4. Check if there are any users with tokens
SELECT 
  'SUMMARY_STATS' as info,
  COUNT(*) as total_users,
  COUNT(CASE WHEN tokens_balance > 0 THEN 1 END) as users_with_tokens,
  COUNT(CASE WHEN tokens_balance = 0 THEN 1 END) as users_with_zero_balance,
  COALESCE(AVG(tokens_balance), 0) as average_balance,
  COALESCE(SUM(tokens_balance), 0) as total_tokens_in_system
FROM public.users 
WHERE is_deleted = false;
