# Debug Console Analysis Guide

## 🔍 What to Look For in Your Debug Console

When you run the app, you'll see detailed logs with emoji prefixes. Here's what each means:

### ✅ Success Indicators

```
🔧 [Supabase] Initializing...
✅ [Supabase] Initialized successfully
✅ User already signed in: approver@test.com
✅ Auth User ID: [uuid]
✅ Session is active and valid
📡 [RPC] Calling get_task_queue_table...
✅ [RPC] get_task_queue_table response received
✅ [RPC] Parsed X tasks
```

### ❌ Error Indicators

```
❌ Sign in failed: [error details]
❌ [RPC] get_task_queue_table failed: [error]
⚠️ WARNING: Session is null after sign in
```

## 📊 Expected Log Flow

### 1. App Startup
```
🔧 [Supabase] Initializing...
   URL: https://macenrukodfgfeowrqqf.supabase.co
   Anon Key: eyJhbGciOiJIUzI1NiIsIn...
✅ [Supabase] Initialized successfully
   Initial auth state:
   - User: null
   - Session: null
```

### 2. Authentication
```
🔐 Attempting to sign in test user...
✅ Successfully signed in test user: approver@test.com
✅ Auth User ID: [uuid]
✅ Session token exists: true
✅ Session is active and valid
```

### 3. Screen Load
```
🔍 Checking authentication before loading data...
Current user: approver@test.com
User ID: [uuid]
Session exists: true
```

### 4. RPC Calls
```
🔍 [RPC] get_task_queue_table - Auth check:
   User: approver@test.com
   User ID: [uuid]
   Session: exists
   Access Token: exists
📡 [RPC] Calling get_task_queue_table...
✅ [RPC] get_task_queue_table response received
✅ [RPC] Parsed X tasks
```

## 🐛 Common Issues & Solutions

### Issue 1: "User not authenticated" in RPC
**Logs you'll see:**
```
❌ [RPC] get_task_queue_table failed: User not authenticated
```

**Possible causes:**
1. Session expired or lost
2. Auth user not created in Supabase Dashboard
3. Password mismatch
4. User not linked to public.users table

**Fix:**
- Check if sign-in succeeded (look for ✅ Successfully signed in)
- Verify auth user exists in Supabase Dashboard
- Run `link_auth_user.sql` to link auth user to public.users

### Issue 2: Session is null after sign in
**Logs you'll see:**
```
✅ Successfully signed in test user: approver@test.com
⚠️ WARNING: Session is null after sign in
```

**Possible causes:**
- Supabase configuration issue
- Session not being stored properly

**Fix:**
- Check Supabase project settings
- Verify anon key is correct
- Check Supabase dashboard for errors

### Issue 3: Sign in fails
**Logs you'll see:**
```
❌ Sign in failed: [error message]
Stack trace: [details]
```

**Common errors:**
- `Invalid login credentials` → Wrong password or user doesn't exist
- `Email not confirmed` → Need to enable "Auto Confirm User" in dashboard
- `Database error` → Auth user not created properly

**Fix:**
- Create auth user in Supabase Dashboard
- Enable "Auto Confirm User"
- Verify password matches code

### Issue 4: RPC function not found
**Logs you'll see:**
```
❌ [RPC] get_task_queue_table failed: PostgrestException (404)
```

**Fix:**
- Run `fix_get_task_queue_table.sql` to create/update function
- Verify function exists in Supabase SQL Editor

## 🔧 Debugging Steps

1. **Check Initialization**
   - Look for `✅ [Supabase] Initialized successfully`
   - If missing, check URL and anon key

2. **Check Authentication**
   - Look for `✅ Successfully signed in`
   - If missing, check error message and fix accordingly

3. **Check Session**
   - Look for `✅ Session is active and valid`
   - If `⚠️ WARNING: Session is null`, there's a session issue

4. **Check RPC Auth**
   - Look for `🔍 [RPC] get_task_queue_table - Auth check:`
   - Verify User ID and Session are not null

5. **Check RPC Response**
   - Look for `✅ [RPC] get_task_queue_table response received`
   - If `❌ [RPC] failed`, check the error message

## 📝 What to Share

If you're still having issues, share these logs:
1. All logs from app startup
2. Authentication logs (sign-in success/failure)
3. RPC call logs (especially the auth check)
4. Any error messages with stack traces

This will help identify exactly where the issue is occurring.
