-- Create wallet and transactions schema
CREATE TABLE IF NOT EXISTS wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  balance DECIMAL(10,2) DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('credit', 'debit')),
  amount DECIMAL(10,2) NOT NULL,
  description TEXT,
  reference_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);

-- Enable RLS
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- RLS policies for wallets
CREATE POLICY "Users can view their own wallet"
  ON wallets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own wallet"
  ON wallets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own wallet"
  ON wallets FOR UPDATE
  USING (auth.uid() = user_id);

-- RLS policies for transactions
CREATE POLICY "Users can view their own transactions"
  ON transactions FOR SELECT
  USING (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own transactions"
  ON transactions FOR INSERT
  WITH CHECK (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- RPC function to get or create wallet
CREATE OR REPLACE FUNCTION get_or_create_wallet(user_id UUID)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  balance DECIMAL,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  wallet_record RECORD;
BEGIN
  -- Try to get existing wallet
  SELECT * INTO wallet_record FROM wallets WHERE user_id = get_or_create_wallet.user_id;
  
  -- If wallet doesn't exist, create one
  IF wallet_record IS NULL THEN
    INSERT INTO wallets (user_id, balance) VALUES (get_or_create_wallet.user_id, 0.00)
    RETURNING * INTO wallet_record;
  END IF;
  
  -- Return the wallet record
  RETURN QUERY SELECT 
    wallet_record.id,
    wallet_record.user_id,
    wallet_record.balance,
    wallet_record.created_at,
    wallet_record.updated_at;
END;
$$;

-- RPC function to add transaction and update balance
CREATE OR REPLACE FUNCTION add_transaction(
  wallet_id UUID,
  transaction_type TEXT,
  amount DECIMAL,
  description TEXT DEFAULT NULL,
  reference_id TEXT DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  new_balance DECIMAL,
  transaction_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_balance DECIMAL;
  new_balance DECIMAL;
  transaction_record UUID;
  wallet_user_id UUID;
BEGIN
  -- Get current wallet and verify ownership
  SELECT balance, user_id INTO current_balance, wallet_user_id
  FROM wallets 
  WHERE id = add_transaction.wallet_id;
  
  IF wallet_user_id IS NULL OR wallet_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Wallet not found or access denied';
  END IF;
  
  -- Calculate new balance
  IF transaction_type = 'credit' THEN
    new_balance := current_balance + amount;
  ELSIF transaction_type = 'debit' THEN
    IF current_balance < amount THEN
      RAISE EXCEPTION 'Insufficient balance';
    END IF;
    new_balance := current_balance - amount;
  ELSE
    RAISE EXCEPTION 'Invalid transaction type';
  END IF;
  
  -- Insert transaction
  INSERT INTO transactions (wallet_id, type, amount, description, reference_id)
  VALUES (wallet_id, transaction_type, amount, description, reference_id)
  RETURNING id INTO transaction_record;
  
  -- Update wallet balance
  UPDATE wallets 
  SET balance = new_balance, updated_at = NOW()
  WHERE id = wallet_id;
  
  -- Return results
  RETURN QUERY SELECT 
    true,
    new_balance,
    transaction_record;
END;
$$;

-- RPC function to get transaction history
CREATE OR REPLACE FUNCTION get_transaction_history(wallet_id UUID, limit_count INTEGER DEFAULT 50)
RETURNS TABLE (
  id UUID,
  wallet_id UUID,
  type TEXT,
  amount DECIMAL,
  description TEXT,
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
    t.wallet_id,
    t.type,
    t.amount,
    t.description,
    t.reference_id,
    t.created_at
  FROM transactions t
  JOIN wallets w ON t.wallet_id = w.id
  WHERE t.wallet_id = get_transaction_history.wallet_id
    AND w.user_id = auth.uid()
  ORDER BY t.created_at DESC
  LIMIT limit_count;
END;
$$;

-- Function to get wallet balance
CREATE OR REPLACE FUNCTION get_wallet_balance(wallet_id UUID)
RETURNS DECIMAL
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  wallet_balance DECIMAL;
  wallet_user_id UUID;
BEGIN
  SELECT balance, user_id INTO wallet_balance, wallet_user_id
  FROM wallets 
  WHERE id = get_wallet_balance.wallet_id;
  
  IF wallet_user_id IS NULL OR wallet_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Wallet not found or access denied';
  END IF;
  
  RETURN wallet_balance;
END;
$$;

-- Triggers for updated_at
CREATE TRIGGER update_wallets_updated_at 
    BEFORE UPDATE ON wallets 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
