-- ============================================================================
-- Test RPC Function Directly
-- This will test if the RPC function is returning correct data
-- ============================================================================

-- Test the exact query that RPC uses
SELECT 
  'DIRECT_QUERY_TEST' as info,
  id::text,
  name,
  email,
  role,
  status,
  tokens_balance,
  CASE WHEN tokens_balance > 0 THEN 'HAS_TOKENS' ELSE 'ZERO_TOKENS' END as token_status
FROM public.users 
WHERE is_deleted = false
ORDER BY tokens_balance DESC;

-- Test the RPC function itself
SELECT get_users_list() as rpc_result;
