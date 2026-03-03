import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SYSTEM_NAME = 'Realtor_OS';
const SYSTEM_KEY = 'faf48c01b12e37eed790202040ff847f';

serve(async (req) => {
  try {
    console.log('🔄 [FUB Callback] Request received');

    // Handle GET request from Follow Up Boss OAuth redirect
    if (req.method !== 'GET') {
      return new Response(
        '<!DOCTYPE html><html><head><title>Error</title></head><body><h1>Method not allowed</h1></body></html>',
        { 
          status: 405, 
          headers: { 'Content-Type': 'text/html' } 
        },
      );
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const FUB_CLIENT_ID = Deno.env.get('FUB_CLIENT_ID');
    const FUB_CLIENT_SECRET = Deno.env.get('FUB_CLIENT_SECRET');
    const FUB_REDIRECT_URI = Deno.env.get('FUB_REDIRECT_URI');

    // Log environment variables (for debugging)
    console.log('🔐 [FUB Callback] FUB_CLIENT_ID:', FUB_CLIENT_ID ? `${FUB_CLIENT_ID.substring(0, 20)}...` : 'NOT SET');
    console.log('🔐 [FUB Callback] FUB_REDIRECT_URI:', FUB_REDIRECT_URI || 'NOT SET');
    console.log('🔐 [FUB Callback] FUB_CLIENT_SECRET:', FUB_CLIENT_SECRET ? 'SET' : 'NOT SET');

    // Validate environment variables
    if (!FUB_CLIENT_ID || !FUB_CLIENT_SECRET || !FUB_REDIRECT_URI) {
      console.error('❌ [FUB Callback] Missing environment variables');
      console.error('   FUB_CLIENT_ID:', FUB_CLIENT_ID ? 'SET' : 'MISSING');
      console.error('   FUB_CLIENT_SECRET:', FUB_CLIENT_SECRET ? 'SET' : 'MISSING');
      console.error('   FUB_REDIRECT_URI:', FUB_REDIRECT_URI ? 'SET' : 'MISSING');
      
      return new Response(
        `<!DOCTYPE html>
<html>
<head>
  <title>Configuration Error</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #1a1a1a; color: #fff; }
    .error { color: #ff6b35; }
  </style>
</head>
<body>
  <h1 class="error">Configuration Error</h1>
  <p>Server configuration is incomplete. Please contact support.</p>
  <script>
    setTimeout(() => window.close(), 3000);
  </script>
</body>
</html>`,
        { status: 500, headers: { 'Content-Type': 'text/html' } },
      );
    }

    // Parse URL to extract code and state
    const url = new URL(req.url);
    const code = url.searchParams.get('code');
    const state = url.searchParams.get('state'); // This is the User ID
    const error = url.searchParams.get('error');

    console.log('🔐 [FUB Callback] Code:', code ? 'PRESENT' : 'MISSING');
    console.log('🔐 [FUB Callback] State (User ID):', state || 'MISSING');
    console.log('🔐 [FUB Callback] Error:', error || 'NONE');

    // Handle OAuth errors from Follow Up Boss
    if (error) {
      console.error('❌ [FUB Callback] OAuth error:', error);
      return new Response(
        `<!DOCTYPE html>
<html>
<head>
  <title>Connection Failed</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #1a1a1a; color: #fff; }
    .error { color: #ff6b35; }
  </style>
</head>
<body>
  <h1 class="error">Connection Failed</h1>
  <p>Error: ${error}</p>
  <script>
    setTimeout(() => {
      window.location.href = 'realtoros://oauth-callback?error=${encodeURIComponent(error)}';
      setTimeout(() => window.close(), 1000);
    }, 2000);
  </script>
</body>
</html>`,
        { 
          status: 200,
          headers: { 'Content-Type': 'text/html' } 
        },
      );
    }

    // Validate required parameters
    if (!code || !state) {
      console.error('❌ [FUB Callback] Missing code or state parameter');
      return new Response(
        `<!DOCTYPE html>
<html>
<head>
  <title>Invalid Request</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #1a1a1a; color: #fff; }
    .error { color: #ff6b35; }
  </style>
</head>
<body>
  <h1 class="error">Invalid Request</h1>
  <p>Missing required parameters. Please try connecting again.</p>
  <script>
    setTimeout(() => {
      window.location.href = 'realtoros://oauth-callback?error=${encodeURIComponent('Missing code or state parameter')}';
      setTimeout(() => window.close(), 1000);
    }, 2000);
  </script>
</body>
</html>`,
        { 
          status: 400,
          headers: { 'Content-Type': 'text/html' } 
        },
      );
    }

    const userIdFromState = state; // State contains the User ID from public.users

    // Validate that the user exists in public.users (single source of truth)
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);
    const { data: publicUser, error: userError } = await supabaseAdmin
      .from('users')
      .select('id')
      .eq('id', userIdFromState)
      .single();

    if (userError || !publicUser) {
      console.error('❌ [FUB Callback] User not found in public.users:', userError?.message);
      return new Response(
        `<!DOCTYPE html>
<html>
<head>
  <title>User Not Found</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #1a1a1a; color: #fff; }
    .error { color: #ff6b35; }
  </style>
</head>
<body>
  <h1 class="error">Connection Failed</h1>
  <p>User not found in system. Please contact support.</p>
  <script>
    setTimeout(() => {
      window.location.href = 'realtoros://oauth-callback?error=${encodeURIComponent('User not found')}';
      setTimeout(() => window.close(), 1000);
    }, 2000);
  </script>
</body>
</html>`,
        { 
          status: 404,
          headers: { 'Content-Type': 'text/html' } 
        },
      );
    }

    const userId = publicUser.id; // Use user ID from public.users (single source of truth)
    console.log('✅ [FUB Callback] User validated in public.users:', userId);
    console.log('🔄 [FUB Callback] Exchanging code for tokens for user:', userId);

    // Step 1: Exchange authorization code for access token
    const tokenResponse = await fetch('https://app.followupboss.com/oauth/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-System': SYSTEM_NAME,
        'X-System-Key': SYSTEM_KEY,
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: FUB_REDIRECT_URI,
        client_id: FUB_CLIENT_ID,
        client_secret: FUB_CLIENT_SECRET,
      }),
    });

    if (!tokenResponse.ok) {
      const errorText = await tokenResponse.text();
      console.error('❌ [FUB Callback] Token exchange failed:', errorText);
      return new Response(
        `<!DOCTYPE html>
<html>
<head>
  <title>Token Exchange Failed</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #1a1a1a; color: #fff; }
    .error { color: #ff6b35; }
  </style>
</head>
<body>
  <h1 class="error">Connection Failed</h1>
  <p>Failed to exchange authorization code for tokens.</p>
  <script>
    setTimeout(() => {
      window.location.href = 'realtoros://oauth-callback?error=${encodeURIComponent('Token exchange failed')}';
      setTimeout(() => window.close(), 1000);
    }, 2000);
  </script>
</body>
</html>`,
        { 
          status: 200,
          headers: { 'Content-Type': 'text/html' } 
        },
      );
    }

    const tokenData = await tokenResponse.json();
    const accessToken = tokenData.access_token;
    const refreshToken = tokenData.refresh_token;
    const expiresIn = tokenData.expires_in || 3600; // Default to 1 hour if not provided

    console.log('✅ [FUB Callback] Tokens received successfully');

    // Calculate expiration time
    const expiresAt = new Date();
    expiresAt.setSeconds(expiresAt.getSeconds() + expiresIn);

    console.log('💾 [FUB Callback] Saving tokens to database for user:', userId);

    // Step 2: Save tokens to database using user.id from public.users
    // supabaseAdmin already initialized above
    // UPSERT tokens into user_crm_connections table using user.id from public.users
    const { error: dbError } = await supabaseAdmin
      .from('user_crm_connections')
      .upsert(
        {
          user_id: userId, // user.id from public.users (single source of truth)
          provider: 'follow_up_boss', // Using snake_case as per table structure
          access_token: accessToken,
          refresh_token: refreshToken,
          expires_at: expiresAt.toISOString(),
          metadata: {
            token_type: tokenData.token_type || 'Bearer',
            scope: tokenData.scope || '',
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          },
        },
        {
          onConflict: 'user_id,provider', // Assuming composite primary key
        },
      );

    if (dbError) {
      console.error('❌ [FUB Callback] Database error:', dbError);
      return new Response(
        `<!DOCTYPE html>
<html>
<head>
  <title>Database Error</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #1a1a1a; color: #fff; }
    .error { color: #ff6b35; }
  </style>
</head>
<body>
  <h1 class="error">Connection Failed</h1>
  <p>Failed to save connection to database.</p>
  <script>
    setTimeout(() => {
      window.location.href = 'realtoros://oauth-callback?error=${encodeURIComponent('Failed to save connection')}';
      setTimeout(() => window.close(), 1000);
    }, 2000);
  </script>
</body>
</html>`,
        { 
          status: 200,
          headers: { 'Content-Type': 'text/html' } 
        },
      );
    }

    console.log('✅ [FUB Callback] Connection saved successfully for user:', userId);

    // Step 3: Return auto-closing HTML response with deep link
    return new Response(
      `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Successfully Connected!</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
      color: #ffffff;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      padding: 20px;
    }
    .container {
      text-align: center;
      max-width: 400px;
      width: 100%;
    }
    .success-icon {
      width: 80px;
      height: 80px;
      margin: 0 auto 30px;
      background: #10b981;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      animation: scaleIn 0.5s ease-out;
    }
    .success-icon::before {
      content: '✓';
      font-size: 48px;
      color: white;
      font-weight: bold;
    }
    @keyframes scaleIn {
      from {
        transform: scale(0);
        opacity: 0;
      }
      to {
        transform: scale(1);
        opacity: 1;
      }
    }
    h1 {
      font-size: 28px;
      margin-bottom: 15px;
      color: #10b981;
    }
    p {
      font-size: 16px;
      line-height: 1.6;
      color: #d1d5db;
      margin-bottom: 30px;
    }
    .loading-dots {
      display: inline-block;
    }
    .loading-dots::after {
      content: '...';
      animation: dots 1.5s steps(4, end) infinite;
    }
    @keyframes dots {
      0%, 20% { content: '.'; }
      40% { content: '..'; }
      60%, 100% { content: '...'; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="success-icon"></div>
    <h1>Successfully Connected!</h1>
    <p>Follow Up Boss has been connected to your account.</p>
    <p>Returning to Realtor OS<span class="loading-dots"></span></p>
  </div>
  <script>
    // Try to open deep link to trigger Flutter UI refresh
    function openDeepLink() {
      const deepLink = 'realtoros://fub-success';
      console.log('Attempting to open deep link:', deepLink);
      
      // Try multiple methods to open the deep link
      window.location.href = deepLink;
      
      // Fallback: try opening in a new window/tab
      setTimeout(() => {
        const link = document.createElement('a');
        link.href = deepLink;
        link.style.display = 'none';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      }, 500);
    }
    
    // Open deep link immediately
    openDeepLink();
    
    // Close window after 2 seconds
    setTimeout(() => {
      console.log('Closing window...');
      window.close();
      
      // Fallback: if window.close() doesn't work, try to redirect
      setTimeout(() => {
        window.location.href = 'about:blank';
      }, 500);
    }, 2000);
  </script>
</body>
</html>`,
      {
        status: 200,
        headers: {
          'Content-Type': 'text/html',
        },
      },
    );

  } catch (error) {
    console.error('❌ [FUB Callback] Fatal Error:', error.message);
    return new Response(
      `<!DOCTYPE html>
<html>
<head>
  <title>Error</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #1a1a1a; color: #fff; }
    .error { color: #ff6b35; }
  </style>
</head>
<body>
  <h1 class="error">An Error Occurred</h1>
  <p>${error.message}</p>
  <script>
    setTimeout(() => {
      window.location.href = 'realtoros://oauth-callback?error=${encodeURIComponent(error.message)}';
      setTimeout(() => window.close(), 1000);
    }, 2000);
  </script>
</body>
</html>`,
      { 
        status: 500,
        headers: { 'Content-Type': 'text/html' } 
      },
    );
  }
});
