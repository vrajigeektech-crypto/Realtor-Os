-- ============================================================================
-- Update Token Balances for Testing
-- Use this to add some test token balances to your users
-- ============================================================================

-- Update specific users with different token amounts
-- Replace 'user-email-here' with actual user emails from your database

-- Example: Give admin 1000 tokens
UPDATE public.users 
SET tokens_balance = 1000.00 
WHERE email = 'admin@example.com';

-- Example: Give agent 250 tokens  
UPDATE public.users 
SET tokens_balance = 250.50 
WHERE email = 'agent@example.com';

-- Example: Give another user 75 tokens
UPDATE public.users 
SET tokens_balance = 75.25 
WHERE email = 'user@example.com';

-- Or update all users with random amounts (for testing)
UPDATE public.users 
SET tokens_balance = 
  CASE 
    WHEN role = 'admin' THEN 1000.00
    WHEN role = 'broker' THEN 500.00
    WHEN role = 'agent' THEN 250.00
    ELSE 100.00
  END
WHERE is_deleted = false;

-- Verify the updates
SELECT 
  'UPDATED_TOKEN_BALANCES' as info,
  id::text,
  name,
  email,
  role,
  tokens_balance
FROM public.users 
WHERE is_deleted = false
ORDER BY tokens_balance DESC;
