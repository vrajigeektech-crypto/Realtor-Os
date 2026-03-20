// supabase/functions/exchange-token/index.ts
//
// POST endpoint called by the Flutter Web OAuthCallbackScreen after the user
// is redirected back from Follow Up Boss with an authorization code.
//
// Request body: { code: string, state?: string }
// Response:     { success: true }  |  { error: string, details?: string }
//
// Flow:
//   1. Validate JWT → resolve user from public.users.
//   2. Exchange the authorization code with FUB's token endpoint.
//   3. UPSERT access/refresh tokens into user_crm_connections.
//   4. Return JSON success.
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: corsHeaders });
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  try {
    // -------------------------------------------------------------------------
    // Environment variables
    // -------------------------------------------------------------------------
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const FUB_CLIENT_ID = Deno.env.get('FUB_CLIENT_ID');
    const FUB_CLIENT_SECRET = Deno.env.get('FUB_CLIENT_SECRET');
    const FUB_REDIRECT_URI = Deno.env.get('FUB_REDIRECT_URI');

    if (!FUB_CLIENT_ID || !FUB_CLIENT_SECRET || !FUB_REDIRECT_URI) {
      console.error('❌ [exchange-token] Missing FUB environment variables');
      return json(
        { error: 'Server configuration error', details: 'Missing FUB environment variables' },
        500,
      );
    }

    // -------------------------------------------------------------------------
    // Authenticate the caller via Supabase JWT
    // -------------------------------------------------------------------------
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return json({ error: 'Unauthorized', details: 'Missing Bearer token' }, 401);
    }

    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user: authUser },
      error: authError,
    } = await supabaseClient.auth.getUser(authHeader.replace('Bearer ', ''));

    if (authError || !authUser) {
      console.error('❌ [exchange-token] Auth failed:', authError?.message);
      return json({ error: 'Unauthorized', details: authError?.message }, 401);
    }

    // Resolve user from public.users (single source of truth for user IDs)
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);
    const { data: publicUser, error: userError } = await supabaseAdmin
      .from('users')
      .select('id')
      .eq('id', authUser.id)
      .single();

    if (userError || !publicUser) {
      console.error('❌ [exchange-token] User not found in public.users:', userError?.message);
      return json({ error: 'User not found' }, 404);
    }

    const userId = publicUser.id as string;
    console.log('✅ [exchange-token] Authenticated user:', userId);

    // -------------------------------------------------------------------------
    // Parse request body
    // -------------------------------------------------------------------------
    let body: { code?: string; state?: string; redirect_uri?: string } = {};
    try {
      body = await req.json();
    } catch (_) {
      return json({ error: 'Invalid JSON body' }, 400);
    }

    const code = body.code?.trim();
    const state = body.state?.trim();      // echoed back to FUB as required by their spec

    // redirect_uri MUST exactly match what was sent in the original /authorize request.
    // Flutter Web passes its own URI; mobile / fub-callback falls back to the env var.
    const redirectUri = body.redirect_uri?.trim() ?? FUB_REDIRECT_URI;

    if (!code) {
      return json({ error: 'Missing required field: code' }, 400);
    }

    console.log('🔄 [exchange-token] Exchanging code for tokens, user:', userId);
    console.log('🔄 [exchange-token] redirect_uri:', redirectUri);

    // -------------------------------------------------------------------------
    // Exchange authorization code for tokens with Follow Up Boss.
    // FUB requires: grant_type, code, redirect_uri, state (echoed back).
    // Credentials go in Basic auth header: base64(client_id:client_secret).
    // -------------------------------------------------------------------------
    const tokenBody = new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: redirectUri,  // must match exactly what was used in the /authorize URL
      ...(state ? { state } : {}),
    });

    const tokenResponse = await fetch('https://app.followupboss.com/oauth/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        Authorization: `Basic ${btoa(`${FUB_CLIENT_ID}:${FUB_CLIENT_SECRET}`)}`,
      },
      body: tokenBody.toString(),
    });

    const tokenText = await tokenResponse.text();
    console.log('🔄 [exchange-token] FUB token status:', tokenResponse.status);

    if (!tokenResponse.ok) {
      let parsedErr: Record<string, unknown> = {};
      try {
        parsedErr = JSON.parse(tokenText);
      } catch (_) { /* use raw text */ }

      const details =
        (parsedErr.error_description as string | undefined) ||
        (parsedErr.message as string | undefined) ||
        tokenText;

      console.error('❌ [exchange-token] FUB token exchange failed:', details);
      return json({ error: 'Token exchange failed', details }, 400);
    }

    const tokenData = JSON.parse(tokenText) as {
      access_token: string;
      refresh_token?: string;
      expires_in?: number;
      token_type?: string;
      scope?: string;
    };

    const expiresIn = tokenData.expires_in ?? 3600;
    const expiresAt = new Date();
    expiresAt.setSeconds(expiresAt.getSeconds() + expiresIn);

    console.log('✅ [exchange-token] Tokens received, saving to DB for user:', userId);

    // -------------------------------------------------------------------------
    // UPSERT tokens into user_crm_connections
    // -------------------------------------------------------------------------
    const { error: dbError } = await supabaseAdmin
      .from('user_crm_connections')
      .upsert(
        {
          user_id: userId,
          provider: 'followupboss',
          access_token: tokenData.access_token,
          refresh_token: tokenData.refresh_token ?? null,
          expires_at: expiresAt.toISOString(),
          metadata: {
            token_type: tokenData.token_type ?? 'Bearer',
            scope: tokenData.scope ?? '',
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          },
        },
        { onConflict: 'user_id,provider' },
      );

    if (dbError) {
      console.error('❌ [exchange-token] DB upsert failed:', dbError.message);
      return json(
        { error: 'Failed to save connection', details: dbError.message },
        500,
      );
    }

    console.log('✅ [exchange-token] Follow Up Boss connected for user:', userId);
    return json({ success: true, message: 'Follow Up Boss connected successfully' });

  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.error('❌ [exchange-token] Fatal error:', message);
    return json({ error: 'Internal server error', details: message }, 500);
  }
});
