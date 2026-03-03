-- =====================================================
-- FIX TOKEN LEDGER TABLE COLUMNS
-- =====================================================

-- Add missing description and reference_id columns to token_ledger
ALTER TABLE public.token_ledger 
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS reference_id TEXT;

-- Update entry_type constraint to include credit/debit if they are used by the app
-- First drop the old constraint if it exists
DO $$ 
BEGIN
    ALTER TABLE public.token_ledger DROP CONSTRAINT IF EXISTS token_ledger_entry_type_check;
END $$;

-- Add new constraint with all needed types
ALTER TABLE public.token_ledger 
ADD CONSTRAINT token_ledger_entry_type_check 
CHECK (entry_type IN ('earn', 'spend', 'purchase', 'transfer', 'credit', 'debit'));

-- Ensure RLS is correct (re-apply from FINAL_FIX_WALLET_RPC if needed)
-- (Assuming FINAL_FIX_WALLET_RPC was already run)

-- Verify columns
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'token_ledger' 
    AND table_schema = 'public';
