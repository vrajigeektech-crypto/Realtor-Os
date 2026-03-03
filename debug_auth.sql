-- Check if user exists and their status
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
  is_sso_user
FROM auth.users 
WHERE email = 'your-email@example.com';  -- Replace with your email

-- Check all users (for debugging)
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at,
  last_sign_in_at,
  banned_until
FROM auth.users 
ORDER BY created_at DESC;
