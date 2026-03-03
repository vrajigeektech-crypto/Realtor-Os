# Update Password to 123456

## Quick Steps

### Method 1: Supabase Dashboard (Easiest)

1. Go to **Supabase Dashboard** → Your Project → **Authentication** → **Users**

2. **Find the user** with ID: `0db45541-2b25-4f78-aa5d-56336a6f1dd2`
   - You can search by ID in the users list
   - Or filter/search if the list is long

3. **Click on the user** to open user details

4. **Click "Reset Password"** or **"Update Password"** button

5. **Enter new password:** `123456`

6. **Save/Confirm**

### Method 2: Supabase Management API

If you have your **service role key**, you can use the API:

```bash
curl -X PUT 'https://macenrukodfgfeowrqqf.supabase.co/auth/v1/admin/users/0db45541-2b25-4f78-aa5d-56336a6f1dd2' \
  -H "apikey: YOUR_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "password": "123456"
  }'
```

### Method 3: Flutter App (If user can sign in)

If the user can currently sign in, you can add a password reset function in the app, but for testing, Method 1 is easiest.

## After Updating Password

1. ✅ Password is now: `123456`
2. ✅ Run `setup_existing_auth_user.sql` to set admin role
3. ✅ The Flutter app is already configured to use password `123456`
4. ✅ Test the app - it should sign in successfully

## Verification

After updating, test sign-in:
- Email: (check from auth.users table)
- Password: `123456`
- Should sign in successfully
