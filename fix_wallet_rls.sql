-- Fix RLS issues and ensure wallet exists for authenticated user
-- Run this script to resolve the RLS policy violation

-- First, let's check what users exist in auth.users
SELECT id, email, created_at FROM auth.users ORDER BY created_at DESC LIMIT 5;

-- Check if wallets exist for these users
SELECT 
  u.id as user_id,
  u.email,
  w.id as wallet_id,
  w.created_at as wallet_created_at
FROM auth.users u
LEFT JOIN wallets w ON u.id = w.user_id
ORDER BY u.created_at DESC
LIMIT 5;

-- If no wallet exists for the current user, create one
-- This will be called by the RPC function when needed

-- Let's also add a policy to allow users to create wallets via RPC
-- The create_wallet_for_user function should handle this, but let's make sure

-- Drop existing policies and recreate them with proper permissions
DROP POLICY IF EXISTS "Users can view their own wallet" ON wallets;
DROP POLICY IF EXISTS "Users can insert their own wallet" ON wallets;

-- Recreate wallet policies
CREATE POLICY "Users can view their own wallet"
  ON wallets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own wallet"
  ON wallets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Also add a policy for updating wallets (might be needed)
CREATE POLICY "Users can update their own wallet"
  ON wallets FOR UPDATE
  USING (auth.uid() = user_id);

-- Check token_ledger policies
DROP POLICY IF EXISTS "Users can view their own token ledger" ON token_ledger;

CREATE POLICY "Users can view their own token ledger"
  ON token_ledger FOR SELECT
  USING (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- Add policy for inserting token ledger entries
CREATE POLICY "Users can insert their own token ledger"
  ON token_ledger FOR INSERT
  WITH CHECK (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- Check wallet_commitments policies
DROP POLICY IF EXISTS "Users can view their own commitments" ON wallet_commitments;

CREATE POLICY "Users can view their own commitments"
  ON wallet_commitments FOR SELECT
  USING (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- Add policy for inserting commitments
CREATE POLICY "Users can insert their own commitments"
  ON wallet_commitments FOR INSERT
  WITH CHECK (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- Add policy for updating commitments
CREATE POLICY "Users can update their own commitments"
  ON wallet_commitments FOR UPDATE
  USING (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- Add policy for deleting commitments
CREATE POLICY "Users can delete their own commitments"
  ON wallet_commitments FOR DELETE
  USING (
    wallet_id IN (
      SELECT id FROM wallets WHERE user_id = auth.uid()
    )
  );

-- Check automation_tasks policies
DROP POLICY IF EXISTS "Users can view their own automation tasks" ON automation_tasks;

CREATE POLICY "Users can view their own automation tasks"
  ON automation_tasks FOR SELECT
  USING (auth.uid() = user_id);

-- Add policy for inserting automation tasks
CREATE POLICY "Users can insert their own automation tasks"
  ON automation_tasks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Add policy for updating automation tasks
CREATE POLICY "Users can update their own automation tasks"
  ON automation_tasks FOR UPDATE
  USING (auth.uid() = user_id);

-- Now let's create a wallet for any user that doesn't have one
-- This is a helper function you can run manually

-- Create wallets for all existing auth users who don't have one
INSERT INTO wallets (user_id)
SELECT id 
FROM auth.users 
WHERE id NOT IN (SELECT user_id FROM wallets);

-- Verify the wallets were created
SELECT 
  u.id as user_id,
  u.email,
  w.id as wallet_id,
  w.created_at as wallet_created_at
FROM auth.users u
JOIN wallets w ON u.id = w.user_id
ORDER BY u.created_at DESC
LIMIT 5;

-- Now add some test data for these wallets
INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  w.id, 
  'purchase', 
  1000, 
  'Initial token purchase'
FROM wallets w
WHERE w.id NOT IN (SELECT DISTINCT wallet_id FROM token_ledger);

INSERT INTO token_ledger (wallet_id, entry_type, amount, source)
SELECT 
  w.id, 
  'earn', 
  500, 
  'Welcome bonus'
FROM wallets w
WHERE w.id NOT IN (
  SELECT DISTINCT wallet_id 
  FROM token_ledger 
  WHERE entry_type = 'earn'
);

-- Final verification
SELECT 
  'FINAL VERIFICATION' as test_name,
  u.email,
  w.id as wallet_id,
  (SELECT COALESCE(SUM(CASE WHEN entry_type IN ('earn', 'purchase') THEN amount ELSE 0 END), 0) 
   FROM token_ledger tl WHERE tl.wallet_id = w.id) as total_tokens,
  (SELECT COUNT(*) FROM token_ledger tl WHERE tl.wallet_id = w.id) as transaction_count
FROM auth.users u
JOIN wallets w ON u.id = w.user_id
ORDER BY u.created_at DESC
LIMIT 5;
