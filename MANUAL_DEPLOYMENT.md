# Manual Edge Function Deployment Instructions

## 🚀 Deploy Without Docker

Since Docker isn't installed, use this manual deployment method:

### Step 1: Go to Supabase Dashboard
1. Visit https://supabase.com/dashboard
2. Select your project: `macenrukodfgfeowrqqf`

### Step 2: Create Edge Function
1. Navigate to **Edge Functions** in the sidebar
2. Click **"New Function"**
3. Function name: `create-checkout-session`
4. Click **"Create Function"**

### Step 3: Add Function Code
Copy the entire content from this file:
```
/Users/igeek/Vraj Workspace/demo 2/supabase/functions/create-checkout-session/index.ts
```

Paste it into the Supabase editor and save.

### Step 4: Add Environment Variables
In the Edge Function settings, add:
- **Name**: `STRIPE_SECRET_KEY`
- **Value**: `sk_test_...` (your Stripe secret key)

### Step 5: Deploy
Click the **Deploy** button.

### Step 6: Test the Function
The function will be available at:
```
https://macenrukodfgfeowrqqf.supabase.co/functions/v1/create-checkout-session
```

## 🔧 Alternative: Install Docker for Local Development

If you want to use the CLI for future deployments:

1. Download Docker Desktop: https://docs.docker.com/desktop
2. Install and start Docker Desktop
3. Run: `supabase functions deploy create-checkout-session`

## 📱 Test Your Flutter App

After deployment, test the checkout flow:
1. Run `flutter run`
2. Navigate to checkout screen
3. Try purchasing tokens
