# Super Admin User Setup Guide

## Problem: 400 Error - Invalid Credentials

The error occurs because `admin@gmail.com` doesn't exist in Supabase Authentication yet.

## Solution: Manual Setup (Easiest & Most Reliable)

### Step 1: Go to Supabase Dashboard
1. Open your Supabase project
2. Navigate to **Authentication** → **Users**

### Step 2: Create the User
1. Click **"Add user"** button
2. Fill in the form:
   - **Email**: `admin@gmail.com`
   - **Password**: `111111`
   - **✅ Check "Auto-confirm email"**
3. Click **"Save"**

### Step 3: Add User Metadata
1. Click on the newly created `admin@gmail.com` user
2. In the "User metadata" section, add:
   ```json
   {
     "role": "Super Admin",
     "is_super_admin": true
   }
   ```
3. Click **"Save"**

### Step 4: Verify
You should now see `admin@gmail.com` in your users list with:
- ✅ Email confirmed
- ✅ User metadata set

## Alternative: Run SQL Script

If you prefer SQL, run `create_admin_simple.sql` in your Supabase SQL Editor, then:
1. Go to Authentication → Users
2. Find `admin@gmail.com`
3. Click "Reset password"
4. Set password to `111111`

## Test the Login

After setup:
1. Open your Flutter app
2. Select "Super Admin" from dropdown
3. Enter email: `admin@gmail.com`
4. Enter password: `111111`
5. Click Login

✅ Should now work without 400 error!

## Why This Happens

Supabase requires users to exist in the `auth.users` table with proper password hashes. The 400 error means the authentication system can't find the user or the password doesn't match.
