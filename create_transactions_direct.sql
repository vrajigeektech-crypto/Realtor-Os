-- Create transactions table directly
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

-- Allow users to see their own transactions
CREATE POLICY IF NOT EXISTS "Users can view own transactions" ON public.transactions
    FOR SELECT USING (
        auth.uid() = (SELECT wallet_id FROM public.wallets WHERE user_id = auth.uid())
    );

-- Allow service to insert transactions
CREATE POLICY IF NOT EXISTS "Service can insert transactions" ON public.transactions
    FOR INSERT WITH CHECK (true);
