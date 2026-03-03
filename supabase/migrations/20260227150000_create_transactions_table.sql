-- Create transactions table to fix missing table error
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('credit', 'debit')),
    amount BIGINT NOT NULL DEFAULT 0,
    description TEXT,
    source TEXT,
    reference_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON public.transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON public.transactions(created_at DESC);

-- Grant necessary permissions
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to see their own transactions
CREATE POLICY IF NOT EXISTS "Users can view their own transactions" ON public.transactions
    FOR SELECT USING (
        auth.uid() = (SELECT wallet_id FROM public.wallets WHERE user_id = auth.uid())
    );

-- Create policy to allow service to insert transactions
CREATE POLICY IF NOT EXISTS "Service can insert transactions" ON public.transactions
    FOR INSERT WITH CHECK (true);

-- Create policy to allow users to update their own transactions
CREATE POLICY IF NOT EXISTS "Users can update their own transactions" ON public.transactions
    FOR UPDATE USING (
        auth.uid() = (SELECT wallet_id FROM public.wallets WHERE user_id = auth.uid())
    );
