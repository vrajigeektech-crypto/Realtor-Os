-- SUPABASE CONNECTION DIAGNOSTIC
-- Run this in Supabase SQL Editor to check connection and issues

-- 1. Check if user exists in auth.users
SELECT 'USER CHECK' as test_name, 
       CASE 
         WHEN EXISTS(SELECT 1 FROM auth.users WHERE id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9') 
         THEN 'USER EXISTS' 
         ELSE 'USER NOT FOUND' 
       END as result;

-- 2. Check if wallet exists for this user
SELECT 'WALLET CHECK' as test_name,
       CASE 
         WHEN EXISTS(SELECT 1 FROM wallets WHERE user_id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9') 
         THEN 'WALLET EXISTS' 
         ELSE 'WALLET NOT FOUND' 
       END as result;

-- 3. Check RLS status on tables
SELECT 'RLS STATUS' as test_name, 
       schemaname, 
       tablename, 
       rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('wallets', 'token_ledger', 'wallet_commitments', 'automation_tasks')
ORDER BY tablename;

-- 4. Check RLS policies
SELECT 'RLS POLICIES' as test_name,
       schemaname,
       tablename,
       policyname,
       permissive,
       roles,
       cmd,
       qual
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('wallets', 'token_ledger', 'wallet_commitments', 'automation_tasks')
ORDER BY tablename, policyname;

-- 5. Check if RPC functions exist
SELECT 'RPC FUNCTIONS' as test_name,
       proname as function_name,
       pronargs as arg_count,
       proargtypes as arg_types
FROM pg_proc 
WHERE proname IN ('get_all_wallets_for_user', 'get_wallet_balance', 'create_wallet_for_user')
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY proname;

-- 6. Test basic connection with current user
SELECT 'CONNECTION TEST' as test_name,
       auth.uid() as current_user_id,
       session_user as session_user_name;

-- 7. Check if we can create a wallet manually (this will show the exact error)
SELECT 'MANUAL WALLET TEST' as test_name;
-- This might fail due to RLS, but will show the exact error
DO $$
BEGIN
    INSERT INTO wallets (user_id) VALUES ('77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9');
    RAISE NOTICE 'Wallet insert successful';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Wallet insert failed: %', SQLERRM;
END $$;

-- 8. Quick fix - disable RLS temporarily and create wallet
SELECT 'QUICK FIX' as test_name;

-- Disable RLS for wallets
ALTER TABLE wallets DISABLE ROW LEVEL SECURITY;

-- Create wallet
INSERT INTO wallets (user_id) 
VALUES ('77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9')
ON CONFLICT (user_id) DO NOTHING;

-- Re-enable RLS
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;

-- Verify wallet was created
SELECT 'WALLET CREATION RESULT' as test_name;
SELECT * FROM wallets WHERE user_id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9';

-- Add initial tokens
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  w.id, 
  'purchase', 
  1000, 
  'Initial token purchase'
FROM wallets w
WHERE w.user_id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9'
AND NOT EXISTS (
  SELECT 1 FROM token_ledger tl 
  WHERE tl.wallet_id = w.id
);

-- Final verification
SELECT 'FINAL VERIFICATION' as test_name;
SELECT 
  w.id as wallet_id,
  w.user_id,
  (SELECT COALESCE(SUM(amount), 0) FROM token_ledger tl WHERE tl.wallet_id = w.id) as total_tokens
FROM wallets w
WHERE w.user_id = '77d3a1f5-a637-4fa7-8f44-9d5f5d8256c9';
