-- Simple approach to create Super Admin user
-- Run this in your Supabase SQL Editor

-- Step 1: Check if user exists
SELECT 'Checking if user exists...' as status;
SELECT id, email, created_at FROM auth.users WHERE email = 'admin@gmail.com';

-- Step 2: Create the user using direct insert (minimal approach)
INSERT INTO auth.users (
    instance_id,
    id,
    email,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_user_meta_data
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'admin@gmail.com',
    now(),
    now(),
    now(),
    '{"role": "Super Admin", "is_super_admin": true}'
);

-- Step 3: Create the user metadata
INSERT INTO auth.users_metadata (
    user_id,
    display_name,
    avatar_url
) 
SELECT 
    id,
    'Super Admin',
    NULL
FROM auth.users 
WHERE email = 'admin@gmail.com';

-- Step 4: Verify user was created
SELECT 'User created successfully!' as status;
SELECT 
    id,
    email,
    email_confirmed_at,
    raw_user_meta_data,
    created_at
FROM auth.users 
WHERE email = 'admin@gmail.com';

-- Step 5: Set password hash (this is a simplified approach)
-- In production, you'd use the proper auth.signup function
-- For now, you'll need to set the password through the Supabase Dashboard

SELECT 'IMPORTANT: Go to Supabase Dashboard > Authentication > Users > admin@gmail.com > Reset Password > Set to 111111' as next_step;
