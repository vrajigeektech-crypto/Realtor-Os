# 🚀 Realtor-Os Complete Deployment Guide

## 📋 Overview
This guide covers deploying the complete Realtor-Os application including:
- Flutter web app to Firebase hosting
- Database schema to Supabase
- Edge Functions to Supabase

## 🔧 Prerequisites
- Firebase CLI installed (`npm install -g firebase-tools`)
- Flutter SDK installed
- Access to Supabase dashboard

---

## 🌐 1. Deploy Flutter Web App to Firebase

### Option A: Using Firebase CLI (Recommended)

1. **Install Firebase CLI** (if not already installed):
```bash
npm install -g firebase-tools
```

2. **Login to Firebase**:
```bash
firebase login
```

3. **Build Flutter Web App**:
```bash
cd /Users/igeek/VrajWorkspace/demo\ 2
flutter build web --release
```

4. **Deploy to Firebase**:
```bash
firebase deploy --only hosting
```

### Option B: Manual Firebase Console Deployment

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select project**: `realtor--os`
3. **Go to Hosting section**
4. **Click "Add Firebase to your web app"**
5. **Upload build/web folder contents**:
   - Navigate to `/Users/igeek/VrajWorkspace/demo 2/build/web`
   - Drag and drop all files into Firebase hosting

---

## 🗄️ 2. Deploy Database Schema to Supabase

### Critical: Fix Missing CRM Functions First

1. **Go to Supabase SQL Editor**: https://supabase.com/dashboard/project/macenrukodfgfeowrqqf/sql
2. **Run the CRM Database Fix**:
   - Copy contents of `CRM_DATABASE_FIX.sql`
   - Paste into SQL editor
   - Click "Run"

### Deploy Complete Schema

3. **Run the Complete Database Schema**:
   - Copy the SQL from `MANUAL_DEPLOY_INSTRUCTIONS.md` (Step 2)
   - Paste into SQL editor
   - Click "Run"

4. **Run the RPC Functions**:
   - Copy the RPC functions SQL from `MANUAL_DEPLOY_INSTRUCTIONS.md` (Step 3)
   - Paste into SQL editor
   - Click "Run"

---

## ⚡ 3. Deploy Edge Functions to Supabase

### Manual Edge Function Deployment

1. **Go to Supabase Dashboard**: https://supabase.com/dashboard/project/macenrukodfgfeowrqqf
2. **Navigate to Edge Functions**
3. **Create New Function**: `create-checkout-session`
4. **Copy code from**: `/Users/igeek/VrajWorkspace/demo 2/supabase/functions/create-checkout-session/index.ts`
5. **Add Environment Variables**:
   - `STRIPE_SECRET_KEY`: Your Stripe secret key
6. **Click Deploy**

---

## ✅ 4. Verify Deployment

### Web App
- **URL**: https://realtor--os.web.app
- **Test**: Visit the URL and verify the app loads

### Database
- **Test CRM connections**: No more CRM errors
- **Test wallet functions**: AI Cleanup button works
- **Test user management**: Admin panel shows all users

### Edge Functions
- **Test checkout**: Token purchase flow works
- **URL**: https://macenrukodfgfeowrqqf.supabase.co/functions/v1/create-checkout-session

---

## 🚨 Troubleshooting

### Firebase Deployment Issues
```bash
# Check Firebase project
firebase projects:list

# Check hosting configuration
firebase hosting:status
```

### Database Issues
- Verify SQL scripts ran without errors
- Check Supabase logs for any issues
- Ensure RLS policies are correctly applied

### Edge Function Issues
- Check environment variables are set
- Verify function code matches the source
- Check Supabase function logs

---

## 📱 Final Testing Checklist

- [ ] Web app loads at https://realtor--os.web.app
- [ ] User authentication works
- [ ] CRM connections load without errors
- [ ] AI Cleanup button functions
- [ ] Token purchase flow works
- [ ] Admin panel shows all users
- [ ] Wallet balances display correctly

---

## 🎯 Success Indicators

✅ **Web app deployed** and accessible via Firebase URL  
✅ **Database schema** complete with all RPC functions  
✅ **Edge functions** deployed and working  
✅ **All features** functional without errors  

Your Realtor-Os application is now fully deployed! 🎉
