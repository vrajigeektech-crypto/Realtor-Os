-- =====================================================
-- STRIPE CHECKOUT COMPLETION HANDLER
-- =====================================================

-- 1. Ensure the checkout_sessions table exists
CREATE TABLE IF NOT EXISTS public.checkout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  price_id TEXT NOT NULL,
  success_url TEXT,
  cancel_url TEXT,
  stripe_session_id TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS if not already enabled
ALTER TABLE public.checkout_sessions ENABLE ROW LEVEL SECURITY;

-- Add policy if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'checkout_sessions' AND policyname = 'Users can view their own checkout sessions') THEN
        CREATE POLICY "Users can view their own checkout sessions"
          ON public.checkout_sessions FOR SELECT
          USING (auth.uid() = user_id);
    END IF;
END $$;

-- 2. Create the update handler function
CREATE OR REPLACE FUNCTION public.handle_stripe_checkout_completion(
  p_user_id UUID,
  p_token_amount INT,
  p_stripe_session_id TEXT,
  p_description TEXT DEFAULT 'Token purchase via Stripe'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with elevated privileges to update ledger
AS $$
DECLARE
  v_wallet_id UUID;
BEGIN
  -- 1. Check if session already processed (idempotency)
  IF EXISTS (SELECT 1 FROM public.checkout_sessions WHERE stripe_session_id = p_stripe_session_id AND status = 'completed') THEN
    RETURN jsonb_build_object('success', true, 'message', 'Session already processed');
  END IF;

  -- 2. Update session status in checkout_sessions table
  UPDATE public.checkout_sessions 
  SET status = 'completed', 
      updated_at = NOW() 
  WHERE stripe_session_id = p_stripe_session_id;

  -- 3. Get user's wallet (create if missing)
  SELECT id INTO v_wallet_id FROM public.wallets WHERE user_id = p_user_id;
  
  IF v_wallet_id IS NULL THEN
    INSERT INTO public.wallets (user_id) VALUES (p_user_id) RETURNING id INTO v_wallet_id;
  END IF;

  -- 4. Credit tokens to the ledger
  INSERT INTO public.token_ledger (
    wallet_id, 
    entry_type, 
    amount, 
    description, 
    reference_id,
    source,
    created_at
  ) VALUES (
    v_wallet_id, 
    'purchase', 
    p_token_amount, 
    p_description, 
    p_stripe_session_id,
    'Stripe',
    NOW()
  );

  RETURN jsonb_build_object(
    'success', true, 
    'wallet_id', v_wallet_id, 
    'tokens_added', p_token_amount,
    'status', 'completed'
  );

EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object(
    'success', false, 
    'error', SQLERRM,
    'detail', SQLSTATE
  );
END;
$$;
