-- Create Super Admin user in Supabase Authentication
-- This will create the admin@gmail.com user with password 111111

-- First, let's check if the user already exists
SELECT * FROM auth.users WHERE email = 'admin@gmail.com';

-- Create a function to create the Super Admin user using the proper auth system
CREATE OR REPLACE FUNCTION create_super_admin_user()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_exists boolean;
    user_id uuid;
BEGIN
    -- Check if user already exists
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = 'admin@gmail.com') INTO user_exists;
    
    IF user_exists THEN
        RETURN 'User already exists';
    END IF;
    
    -- Generate a UUID for the new user
    user_id := gen_random_uuid();
    
    -- Insert the user into auth.users table with proper structure
    INSERT INTO auth.users (
        instance_id,
        id,
        email,
        email_confirmed_at,
        created_at,
        updated_at,
        raw_user_meta_data,
        email_confirmed
    ) VALUES (
        '00000000-0000-0000-0000-000000000000', -- default instance_id
        user_id,
        'admin@gmail.com',
        now(),
        now(),
        now(),
        '{"role": "Super Admin", "is_super_admin": true}',
        true
    );
    
    -- Create user metadata entry
    INSERT INTO auth.users_metadata (
        user_id,
        display_name,
        avatar_url
    ) VALUES (
        user_id,
        'Super Admin',
        NULL
    );
    
    RETURN 'User created successfully';
END;
$$;

-- Execute the function to create the user
SELECT create_super_admin_user();

-- Verify the user was created
SELECT 
    id,
    email,
    email_confirmed_at,
    raw_user_meta_data,
    created_at
FROM auth.users 
WHERE email = 'admin@gmail.com';

-- Alternative approach: Use the auth.signup function if available
-- This is the recommended way to create users with passwords

-- Create a secure function to sign up the Super Admin user
CREATE OR REPLACE FUNCTION signup_super_admin()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Use the auth.signup function to create the user with password
    -- Note: This requires the auth schema to be accessible
    PERFORM auth.signup(
        email := 'admin@gmail.com',
        password := '111111',
        data := '{"role": "Super Admin", "is_super_admin": true}'
    );
    
    RETURN 'Super Admin user created with password';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error creating user: ' || SQLERRM;
END;
$$;

-- Try the signup approach
SELECT signup_super_admin();

-- Final verification
SELECT 
    id,
    email,
    email_confirmed_at,
    raw_user_meta_data,
    created_at
FROM auth.users 
WHERE email = 'admin@gmail.com';

-- IMPORTANT: After running this script, you may need to:
-- 1. Go to Supabase Dashboard > Authentication > Users
-- 2. Find admin@gmail.com user
-- 3. If password is not set, use "Reset password" to set it to "111111"
