-- Create transactions table with new function name
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('credit', 'debit')),
    amount BIGINT NOT NULL DEFAULT 0,
    description TEXT,
    source TEXT,
    reference_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY IF NOT EXISTS "Users can view own transactions" ON public.transactions
    FOR SELECT USING (
        auth.uid() = (SELECT wallet_id FROM public.wallets WHERE user_id = auth.uid())
    );

CREATE POLICY IF NOT EXISTS "Service can insert transactions" ON public.transactions
    FOR INSERT WITH CHECK (true);

-- Create new function to get transactions
CREATE OR REPLACE FUNCTION get_wallet_transactions_v2(p_wallet_id UUID)
RETURNS TABLE (
    id UUID,
    type TEXT,
    amount BIGINT,
    description TEXT,
    source TEXT,
    reference_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.type,
        t.amount,
        t.description,
        t.source,
        t.reference_id,
        t.created_at
    FROM public.transactions t
    WHERE t.wallet_id = p_wallet_id
    ORDER BY t.created_at DESC;
END;
$$;
