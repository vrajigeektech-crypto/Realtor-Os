-- Run this in Supabase SQL Editor to check your user
-- Replace 'your-email@example.com' with your actual email

-- Check if your user exists and their status
SELECT 
  id,
  email,
  email_confirmed_at,
  phone,
  phone_confirmed_at,
  created_at,
  updated_at,
  last_sign_in_at,
  banned_until,
  is_sso_user,
  raw_user_meta_data
FROM auth.users 
WHERE email = 'your-email@example.com';

-- If no user found, check all users to see what emails exist
SELECT 
  email,
  email_confirmed_at,
  created_at,
  last_sign_in_at,
  CASE 
    WHEN banned_until IS NOT NULL AND banned_until > NOW() THEN 'Banned'
    WHEN email_confirmed_at IS NULL THEN 'Email not confirmed'
    ELSE 'Active'
  END as status
FROM auth.users 
ORDER BY created_at DESC;
