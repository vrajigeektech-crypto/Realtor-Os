-- Verify and update the existing admin@gmail.com user
-- The user already exists, now we need to check and update it

-- Step 1: Check the existing user
SELECT 'Checking existing admin@gmail.com user...' as status;
SELECT 
    id,
    email,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at
FROM auth.users 
WHERE email = 'admin@gmail.com';

-- Step 2: Update user metadata if needed
UPDATE auth.users 
SET raw_user_meta_data = '{"role": "Super Admin", "is_super_admin": true}'
WHERE email = 'admin@gmail.com';

-- Step 3: Verify the metadata was updated
SELECT 'User metadata updated!' as status;
SELECT 
    id,
    email,
    email_confirmed_at,
    raw_user_meta_data
FROM auth.users 
WHERE email = 'admin@gmail.com';

-- Step 4: Skip metadata table (doesn't exist in this setup)
-- The user metadata is stored in raw_user_meta_data column

-- FINAL RESULT: User exists and is ready
SELECT '✅ admin@gmail.com user is ready!' as final_status;
SELECT 'Now set the password in Supabase Dashboard' as next_step;
