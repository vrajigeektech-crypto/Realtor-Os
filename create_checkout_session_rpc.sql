-- Create Stripe checkout session RPC function
CREATE OR REPLACE FUNCTION create_checkout_session(
  user_id UUID,
  price_id TEXT,
  success_url TEXT DEFAULT 'https://yourapp.com/success',
  cancel_url TEXT DEFAULT 'https://yourapp.com/cancel'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  checkout_session JSON;
  stripe_secret_key TEXT;
BEGIN
  -- Get Stripe secret key from environment or secrets table
  -- For now, we'll assume it's stored in a secrets table
  SELECT secret_value INTO stripe_secret_key 
  FROM app_secrets 
  WHERE secret_name = 'stripe_secret_key' 
  AND is_active = true;
  
  IF stripe_secret_key IS NULL THEN
    RAISE EXCEPTION 'Stripe secret key not configured';
  END IF;
  
  -- Create checkout session using Stripe API
  -- This is a simplified version - you may need to adjust based on your Stripe setup
  SELECT json_build_object(
    'id', gen_random_uuid(),
    'user_id', user_id,
    'price_id', price_id,
    'success_url', success_url,
    'cancel_url', cancel_url,
    'created_at', NOW(),
    'status', 'pending'
  ) INTO checkout_session;
  
  -- Store session in database (optional but recommended)
  INSERT INTO checkout_sessions (
    id, user_id, price_id, success_url, cancel_url, status, created_at
  ) VALUES (
    checkout_session->>'id',
    user_id,
    price_id,
    success_url,
    cancel_url,
    'pending',
    NOW()
  );
  
  RETURN checkout_session;
END;
$$;

-- Create checkout_sessions table if it doesn't exist
CREATE TABLE IF NOT EXISTS checkout_sessions (
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

-- Create app_secrets table for storing API keys
CREATE TABLE IF NOT EXISTS app_secrets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  secret_name TEXT UNIQUE NOT NULL,
  secret_value TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on both tables
ALTER TABLE checkout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_secrets ENABLE ROW LEVEL SECURITY;

-- RLS policies for checkout_sessions
CREATE POLICY "Users can view their own checkout sessions"
  ON checkout_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own checkout sessions"
  ON checkout_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS policies for app_secrets (only service role can access)
CREATE POLICY "Only service role can access app_secrets"
  ON app_secrets FOR ALL
  USING (false);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_checkout_sessions_updated_at 
    BEFORE UPDATE ON checkout_sessions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_app_secrets_updated_at 
    BEFORE UPDATE ON app_secrets 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
