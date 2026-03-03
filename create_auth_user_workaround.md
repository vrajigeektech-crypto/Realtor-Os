# Workaround: Create Auth User When Database Error Occurs

## Quick Fix Steps

### Option 1: Use Supabase Dashboard (Easiest)

1. **Go to Supabase Dashboard** → Your Project → **Authentication** → **Users**

2. **Click "Add User"** or **"Invite User"**

3. **Fill in the form:**
   - Email: `approver@test.com`
   - Password: `TestPassword123!` (or your preferred password)
   - **IMPORTANT:** Check **"Auto Confirm User"**
   - **IMPORTANT:** Uncheck **"Send Invite Email"** (for testing)

4. **Click "Create User"**

5. **If it still fails:**
   - Check the error message in the dashboard
   - Look for specific field names or constraint violations
   - See solutions below

### Option 2: Use Supabase CLI (If Available)

```bash
# Install Supabase CLI if not installed
npm install -g supabase

# Login
supabase login

# Create user via CLI
supabase auth admin create-user \
  --email approver@test.com \
  --password TestPassword123! \
  --email-confirm true
```

### Option 3: Use Management API (Service Role Required)

If you have your service role key, you can use the Management API:

```bash
curl -X POST 'https://macenrukodfgfeowrqqf.supabase.co/auth/v1/admin/users' \
  -H "apikey: YOUR_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "approver@test.com",
    "password": "TestPassword123!",
    "email_confirm": true,
    "user_metadata": {}
  }'
```

## Common Causes & Fixes

### Cause 1: Trigger Failure
**Symptom:** Error mentions trigger or function failure

**Fix:** Run `fix_auth_user_creation.sql` to create/update the trigger function

### Cause 2: Foreign Key Constraint
**Symptom:** Error mentions foreign key or constraint violation

**Fix:** 
1. Temporarily disable triggers: `ALTER TABLE auth.users DISABLE TRIGGER ALL;`
2. Create user in dashboard
3. Re-enable triggers: `ALTER TABLE auth.users ENABLE TRIGGER ALL;`
4. Run `link_auth_user.sql`

### Cause 3: Missing Required Fields
**Symptom:** Error mentions specific column names

**Fix:** Update the trigger function in `fix_auth_user_creation.sql` to include all required fields

### Cause 4: RLS Policy Blocking
**Symptom:** Error mentions "policy" or "row level security"

**Fix:** Check RLS policies on `public.users` table and ensure the trigger function has proper permissions

## After Creating Auth User

Once the auth user is created successfully:

1. **Note the User ID** from the dashboard (it will be a UUID)

2. **Run the linking SQL:**
   ```sql
   -- Run link_auth_user.sql
   -- OR manually:
   INSERT INTO public.users (id, email, role, status, ...)
   SELECT id, email, 'admin', 'active', ...
   FROM auth.users
   WHERE email = 'approver@test.com'
   ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;
   ```

3. **Update password in Flutter code** if different from `TestPassword123!`

4. **Test the app** - it should now sign in successfully

## Verification

After creating the user, verify:

```sql
-- Check auth user exists
SELECT id, email, created_at 
FROM auth.users 
WHERE email = 'approver@test.com';

-- Check public.users record exists
SELECT id, email, role, status 
FROM public.users 
WHERE email = 'approver@test.com';

-- Verify they're linked (same ID)
SELECT 
  au.id as auth_id,
  au.email as auth_email,
  pu.id as public_id,
  pu.email as public_email
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE au.email = 'approver@test.com';
```

Both should return the same UUID for `id`.
