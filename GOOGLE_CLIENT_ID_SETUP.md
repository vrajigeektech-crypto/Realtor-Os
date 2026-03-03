# Google Sign-In Configuration

## ⚠️ ACTION REQUIRED: Configure Google Client ID

Your Google Sign-In is failing because the Google Client ID is not properly configured.

### Step 1: Get Your Google Client ID

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create a new one)
3. Go to **APIs & Services > Credentials**
4. Click **Create Credentials > OAuth 2.0 Client IDs**
5. Select **Web application** as the application type
6. Add your authorized redirect URIs:
   - `http://localhost:3000/auth/callback` (for local testing)
   - `https://macenrukodfgfeowrqqf.supabase.co/auth/v1/callback` (for production)
7. Copy the **Client ID** (it looks like: `123456789-abcdef.apps.googleusercontent.com`)

### Step 2: Update the Configuration

Replace the placeholder in `lib/supabase_config.dart`:

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId: 'YOUR_ACTUAL_WEB_CLIENT_ID_HERE', // Replace this
  serverClientId: 'YOUR_ACTUAL_WEB_CLIENT_ID_HERE', // Replace this
);
```

### Step 3: Configure Supabase

1. Go to your [Supabase Dashboard](https://app.supabase.com/)
2. Navigate to **Authentication > Providers**
3. Find **Google** and click to configure
4. Enable the Google provider
5. Paste your **Client ID** and **Client Secret** from Google Cloud Console
6. Make sure the redirect URL matches: `https://macenrukodfgfeowrqqf.supabase.co/auth/v1/callback`

### Step 4: Test the Configuration

After updating the client ID:

1. Run `flutter clean && flutter pub get`
2. Restart your app: `flutter run`
3. Try Google Sign-In again

### Common Issues & Solutions

**Issue**: "Failed to get ID token from Google"
- **Solution**: Make sure your Google Client ID is correctly set in `supabase_config.dart`

**Issue**: "Web client type is required"
- **Solution**: Add the web client ID to `web/index.html`:
  ```html
  <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID_HERE">
  ```

**Issue**: "Invalid redirect URI"
- **Solution**: Check that the redirect URI in Google Cloud Console matches exactly what's in Supabase

### Need Help?

Check the full setup guide in `GOOGLE_AUTH_SETUP.md` for detailed instructions.

---

**Once you configure your Google Client ID, Google Sign-In should work properly! 🚀**
