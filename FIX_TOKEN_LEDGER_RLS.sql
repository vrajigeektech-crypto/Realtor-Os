-- =====================================================
-- FIX RLS FOR TOKEN LEDGER
-- =====================================================

-- 1. Enable RLS
ALTER TABLE public.token_ledger ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies to start fresh
DROP POLICY IF EXISTS "Users can view their own token ledger entries" ON public.token_ledger;
DROP POLICY IF EXISTS "Users can insert their own token ledger entries" ON public.token_ledger;
DROP POLICY IF EXISTS "Service role can do everything on token ledger" ON public.token_ledger;

-- 3. Create view policy
-- Allows users to see transactions for wallets THEY own
CREATE POLICY "Users can view their own token ledger entries" 
ON public.token_ledger 
FOR SELECT 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM public.wallets 
    WHERE public.wallets.id = public.token_ledger.wallet_id 
    AND public.wallets.user_id = auth.uid()
  )
);

-- 4. Create insert policy
-- Allows users to add transactions for wallets THEY own
CREATE POLICY "Users can insert their own token ledger entries" 
ON public.token_ledger 
FOR INSERT 
TO authenticated 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.wallets 
    WHERE public.wallets.id = public.token_ledger.wallet_id 
    AND public.wallets.user_id = auth.uid()
  )
);

-- 5. Create service role policy (emergency bypass)
CREATE POLICY "Service role can do everything on token ledger" 
ON public.token_ledger 
FOR ALL 
TO service_role 
USING (true) 
WITH CHECK (true);

-- 6. Grant sequence permissions just in case
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- 7. Verify
SELECT tablename, policyname, roles, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'token_ledger';
