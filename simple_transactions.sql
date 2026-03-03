-- Simple transactions table creation
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL,
    type TEXT NOT NULL,
    amount BIGINT NOT NULL DEFAULT 0,
    description TEXT,
    source TEXT,
    reference_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
