-- Create a test user (run in Supabase SQL Editor)
INSERT INTO auth.users (
  id,
  email,
  email_confirmed_at,
  created_at,
  updated_at
) 
VALUES (
  gen_random_uuid(),
  'test@example.com',
  NOW(),
  NOW(),
  NOW()
);

-- Set password for the user
-- Go to Supabase Dashboard -> Authentication -> Users
-- Find the user and click "Reset Password" or use the admin API
