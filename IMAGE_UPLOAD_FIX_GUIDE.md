# Image Upload Fix Guide

## Problem
Images are not uploading and not saving to Supabase in the onboarding flow.

## Root Causes Found
1. **Missing RPC Function**: `complete_onboarding_step` function doesn't exist in database
2. **Storage Bucket Configuration**: `user_assets` bucket was set to private instead of public
3. **Storage Policies**: Conflicting policies and missing public access

## Fix Steps

### Step 1: Run Database Fixes
Execute these SQL files in Supabase SQL Editor **in order**:

1. **URGENT_DATABASE_FIX.sql** - Creates users table and basic storage setup
2. **CREATE_ONBOARDING_RPC.sql** - Creates the missing RPC function
3. **FIX_STORAGE_BUCKET_PUBLIC.sql** - Fixes storage bucket to be public
4. **VERIFY_IMAGE_UPLOAD_SETUP.sql** - Verify everything is working

### Step 2: Test the Fix
After running the SQL files:

1. **Check Storage Bucket**:
   ```sql
   SELECT * FROM storage.buckets WHERE name = 'user_assets';
   ```
   Should show: `public = true`

2. **Check RPC Function**:
   ```sql
   SELECT proname FROM pg_proc WHERE proname = 'complete_onboarding_step';
   ```
   Should return: `complete_onboarding_step`

3. **Test Upload**:
   - Log into your app
   - Go to onboarding flow
   - Try uploading photos in the photos step

### Step 3: Debug If Still Not Working

#### Check Console Logs
Look for these debug messages:
- `📤 [PhotoUpload] Upload started:`
- `✅ [PhotoUpload] Upload success URL:`
- `❌ [PhotoUpload] Upload failed:`

#### Common Issues & Solutions

**Issue: "User not authenticated" error**
- Make sure you're logged in
- Check `SupabaseService.instance.client.auth.currentUser` is not null

**Issue: "Permission denied" error**
- Run the storage policy fixes again
- Ensure bucket is set to public

**Issue: "Bucket not found" error**
- Run URGENT_DATABASE_FIX.sql to create the bucket
- Check bucket exists in Supabase Dashboard

**Issue: Images upload but don't display**
- Check if URLs are public (should work with bucket set to public)
- Verify the image URLs are correct format

### Step 4: Verify Database State
Run this to check your user data:
```sql
SELECT 
    id, 
    email, 
    onboarding_completed, 
    onboarding_step,
    gallery_urls,
    logo_url,
    headshot_url
FROM public.users 
WHERE id = auth.uid();
```

### Expected Behavior After Fix
1. ✅ Images upload to `user_assets` bucket
2. ✅ Public URLs are generated and work
3. ✅ URLs are saved to `users.gallery_urls` array
4. ✅ Onboarding step is marked complete
5. ✅ Images display in the grid

### Files Modified
- `CREATE_ONBOARDING_RPC.sql` - New file
- `FIX_STORAGE_BUCKET_PUBLIC.sql` - New file  
- `VERIFY_IMAGE_UPLOAD_SETUP.sql` - New file
- `IMAGE_UPLOAD_FIX_GUIDE.md` - This file

### Code Changes Required
None - the issue was database configuration, not app code.

---

**After applying these fixes, image upload should work correctly in the onboarding flow.**
