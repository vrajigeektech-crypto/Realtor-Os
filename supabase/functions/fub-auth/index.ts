import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Shared auth helper - inlined because Supabase Edge Functions don't support parent directory imports
interface AuthenticatedUser {
  id: string;
  email: string | null;
  [key: string]: any;
}

async function requireUser(req: Request): Promise<AuthenticatedUser> {
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceKey) {
    throw new Error('Missing Supabase environment variables');
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('Missing or invalid Authorization header. Please log in first.');
  }

  const token = authHeader.replace('Bearer ', '');

  const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });

  const { data: { user: authUser }, error: authError } = await supabaseClient.auth.getUser(token);

  if (authError || !authUser) {
    console.error('❌ [Auth] Authentication failed:', authError?.message);
    throw new Error('User not authenticated. Please log in first.');
  }

  if (!authUser.id) {
    throw new Error('Invalid user token: missing user ID');
  }

  console.log('✅ [Auth] User authenticated from auth.users:', authUser.id);

  const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

  const { data: publicUser, error: userError } = await supabaseAdmin
    .from('users')
    .select('*')
    .eq('id', authUser.id)
    .single();

  if (userError || !publicUser) {
    console.error('❌ [Auth] User not found in public.users:', userError?.message);
    throw new Error('User not found in system. Please contact support.');
  }

  console.log('✅ [Auth] User resolved from public.users:', publicUser.id);

  return publicUser as AuthenticatedUser;
}

const SYSTEM_NAME = 'Realtor_OS';
const SYSTEM_KEY = 'faf48c01b12e37eed790202040ff847f';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-system, x-system-key',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    console.log('🔐 [FUB Auth] Request received');

    // Validate system identification headers
    const systemHeader = req.headers.get('X-System');
    const systemKeyHeader = req.headers.get('X-System-Key');

    if (systemHeader !== SYSTEM_NAME || systemKeyHeader !== SYSTEM_KEY) {
      console.log('❌ [FUB Auth] Invalid system headers');
      return new Response(
        JSON.stringify({ error: 'Invalid system credentials' }),
        { status: 403, headers: corsHeaders },
      );
    }

    // REQUIRE AUTHENTICATION - Get user from public.users via shared auth helper
    let user;
    try {
      user = await requireUser(req);
      console.log('✅ [FUB Auth] User authenticated:', user.id);
    } catch (authError) {
      console.error('❌ [FUB Auth] Authentication failed:', authError.message);
      return new Response(
        JSON.stringify({ 
          error: 'Authentication required',
          details: authError.message 
        }),
        { status: 401, headers: corsHeaders },
      );
    }

    // Get environment variables
    const FUB_CLIENT_ID = Deno.env.get('FUB_CLIENT_ID');
    const FUB_REDIRECT_URI_ENV = Deno.env.get('FUB_REDIRECT_URI'); // default (mobile/server)

    console.log('🔐 [FUB Auth] FUB_CLIENT_ID from env:', FUB_CLIENT_ID ? `${FUB_CLIENT_ID.substring(0, 20)}...` : 'NOT SET');
    console.log('🔐 [FUB Auth] FUB_REDIRECT_URI from env:', FUB_REDIRECT_URI_ENV || 'NOT SET');

    if (!FUB_CLIENT_ID) {
      console.error('❌ [FUB Auth] FUB_CLIENT_ID is missing from environment');
      return new Response(
        JSON.stringify({ error: 'Server configuration error', details: 'FUB_CLIENT_ID not set' }),
        { status: 500, headers: corsHeaders },
      );
    }

    if (!FUB_REDIRECT_URI_ENV) {
      console.error('❌ [FUB Auth] FUB_REDIRECT_URI is missing from environment');
      return new Response(
        JSON.stringify({ error: 'Server configuration error', details: 'FUB_REDIRECT_URI not set' }),
        { status: 500, headers: corsHeaders },
      );
    }

    // -------------------------------------------------------------------------
    // Allow callers to override redirect_uri (e.g. Flutter Web uses the app's
    // hash-based URL; mobile uses the server-side fub-callback function).
    // Validate against an allowlist to prevent open-redirect attacks.
    // -------------------------------------------------------------------------
    const FLUTTER_WEB_URL = Deno.env.get('FLUTTER_WEB_URL') ?? 'https://realtor--os.web.app';
    const WEB_REDIRECT_URI = `${FLUTTER_WEB_URL}/#/oauth/callback`;

    const ALLOWED_REDIRECT_URIS = new Set([
      FUB_REDIRECT_URI_ENV,  // server-side callback (mobile / legacy)
      WEB_REDIRECT_URI,      // Flutter Web direct callback
    ]);

    // Parse optional JSON body sent by the Flutter Web client
    let requestBody: { redirect_uri?: string } = {};
    try {
      if (req.headers.get('content-type')?.includes('application/json')) {
        requestBody = await req.json();
      }
    } catch (_) { /* no body – use env default */ }

    const redirectUri = requestBody.redirect_uri?.trim() ?? FUB_REDIRECT_URI_ENV;

    if (!ALLOWED_REDIRECT_URIS.has(redirectUri)) {
      console.error('❌ [FUB Auth] redirect_uri not in allowlist:', redirectUri);
      return new Response(
        JSON.stringify({ error: 'Invalid redirect_uri', details: 'Not in server allowlist' }),
        { status: 400, headers: corsHeaders },
      );
    }

    // Use user.id from public.users (single source of truth)
    const userId = user.id;

    // Build OAuth URL for Follow Up Boss
    const authUrl = new URL('https://app.followupboss.com/oauth/authorize');
    authUrl.searchParams.set('client_id', FUB_CLIENT_ID);
    authUrl.searchParams.set('redirect_uri', redirectUri);
    authUrl.searchParams.set('response_type', 'auth_code'); // FUB uses 'auth_code' not standard 'code'
    authUrl.searchParams.set('scope', 'people notes calls textMessages emEvents stages users deals pipelines webhooks');
    authUrl.searchParams.set('state', userId); // echoed back by FUB; used to identify the user on return

    console.log('✅ [FUB Auth] OAuth URL generated for user:', userId);
    console.log('🔐 [FUB Auth] Using redirect_uri:', redirectUri);

    // Return the OAuth URL in JSON format
    return new Response(
      JSON.stringify({ url: authUrl.toString() }),
      { status: 200, headers: corsHeaders },
    );

  } catch (error) {
    console.error('❌ [FUB Auth] Fatal Error:', error.message);
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error', 
        details: error.message 
      }),
      { status: 500, headers: corsHeaders },
    );
  }
});
