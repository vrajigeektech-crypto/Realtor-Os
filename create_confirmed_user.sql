-- If user doesn't exist, create a confirmed test user
-- Run this in Supabase SQL Editor

-- Create a confirmed user (email already verified)
INSERT INTO auth.users (
  id,
  email,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_user_meta_data
) 
VALUES (
  gen_random_uuid(),
  'test@example.com',
  NOW(),  -- Email is already confirmed
  NOW(),
  NOW(),
  '{"name": "Test User"}'
) 
ON CONFLICT (email) DO NOTHING;

-- After creating the user, you need to set a password
-- Go to Supabase Dashboard -> Authentication -> Users
-- Find the user and click "Reset Password" to set the password
