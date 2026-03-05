-- ============================================================================
-- Debug Token Balance Issue
-- Check field names and data types
-- ============================================================================

-- 1. Check exact column names in users table
SELECT 
  'COLUMN_NAMES' as info,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
  AND (column_name LIKE '%token%' OR column_name LIKE '%balance%')
ORDER BY column_name;

-- 2. Check if tokens_balance has any data
SELECT 
  'TOKEN_BALANCE_DATA' as info,
  COUNT(*) as total_rows,
  COUNT(CASE WHEN tokens_balance IS NOT NULL THEN 1 END) as rows_with_values,
  COUNT(CASE WHEN tokens_balance > 0 THEN 1 END) as rows_with_positive_balance,
  MIN(tokens_balance) as min_balance,
  MAX(tokens_balance) as max_balance,
  AVG(tokens_balance) as avg_balance
FROM public.users;

-- 3. Show sample users with all balance-related fields
SELECT 
  'SAMPLE_USERS' as info,
  id::text,
  name,
  email,
  tokens_balance,
  tokens_balance::text as balance_text,
  COALESCE(tokens_balance, 0) as balance_with_default,
  CASE WHEN tokens_balance IS NULL THEN 'NULL' WHEN tokens_balance = 0 THEN 'ZERO' ELSE 'HAS_VALUE' END as balance_status
FROM public.users 
WHERE is_deleted = false
ORDER BY tokens_balance DESC NULLS LAST
LIMIT 5;

-- 4. Test the exact RPC query structure
SELECT 
  'RPC_TEST' as info,
  jsonb_build_object(
    'id', u.id::text,
    'name', u.name,
    'email', u.email,
    'role', u.role,
    'status', u.status,
    'last_login', u.last_login,
    'tokens_balance', COALESCE(u.tokens_balance::numeric, 0),
    'xp_total', COALESCE(u.xp_total, 0),
    'level', COALESCE(u.level, 1),
    'current_streak', COALESCE(u.current_streak, 0),
    'longest_streak', COALESCE(u.longest_streak, 0),
    'total_orders', 0,
    'has_flags', false
  ) as sample_rpc_output
FROM public.users u 
WHERE u.is_deleted = false 
LIMIT 1;
