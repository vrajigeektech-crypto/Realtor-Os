import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const FUB_CLIENT_ID = Deno.env.get('FUB_CLIENT_ID');
    const FUB_CLIENT_SECRET = Deno.env.get('FUB_CLIENT_SECRET');

    if (!FUB_CLIENT_ID || !FUB_CLIENT_SECRET) {
      return new Response(
        JSON.stringify({ error: 'Server configuration error: missing FUB credentials' }),
        { status: 500, headers: corsHeaders },
      );
    }

    // Authenticate the calling user
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ error: 'Missing or invalid Authorization header' }),
        { status: 401, headers: corsHeaders },
      );
    }

    const token = authHeader.replace('Bearer ', '');
    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user: authUser }, error: authError } = await supabaseClient.auth.getUser(token);
    if (authError || !authUser) {
      return new Response(
        JSON.stringify({ error: 'User not authenticated' }),
        { status: 401, headers: corsHeaders },
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // Fetch the stored refresh token for this user
    const { data: conn, error: connError } = await supabaseAdmin
      .from('user_crm_connections')
      .select('refresh_token, expires_at, metadata')
      .eq('user_id', authUser.id)
      .eq('provider', 'followupboss')
      .single();

    if (connError || !conn) {
      return new Response(
        JSON.stringify({ error: 'No Follow Up Boss OAuth connection found for this user' }),
        { status: 404, headers: corsHeaders },
      );
    }

    if (!conn.refresh_token) {
      return new Response(
        JSON.stringify({ error: 'Connection does not use OAuth (no refresh token)' }),
        { status: 400, headers: corsHeaders },
      );
    }

    console.log('🔄 [FUB Refresh] Refreshing token for user:', authUser.id);

    // Exchange refresh token for a new access token
    const tokenBody = new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: conn.refresh_token,
    });

    const tokenResponse = await fetch('https://app.followupboss.com/oauth/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': `Basic ${btoa(`${FUB_CLIENT_ID}:${FUB_CLIENT_SECRET}`)}`,
      },
      body: tokenBody.toString(),
    });

    const tokenText = await tokenResponse.text();
    console.log('🔄 [FUB Refresh] Token response status:', tokenResponse.status);

    if (!tokenResponse.ok) {
      console.error('❌ [FUB Refresh] Token refresh failed:', tokenText);
      return new Response(
        JSON.stringify({ error: 'Token refresh failed', details: tokenText }),
        { status: 400, headers: corsHeaders },
      );
    }

    const tokenData = JSON.parse(tokenText);
    const newAccessToken = tokenData.access_token;
    const newRefreshToken = tokenData.refresh_token ?? conn.refresh_token;
    const expiresIn = tokenData.expires_in ?? 3600;

    const expiresAt = new Date();
    expiresAt.setSeconds(expiresAt.getSeconds() + expiresIn);

    // Save the new tokens to the database
    const { error: updateError } = await supabaseAdmin
      .from('user_crm_connections')
      .update({
        access_token: newAccessToken,
        refresh_token: newRefreshToken,
        expires_at: expiresAt.toISOString(),
        metadata: {
          ...(conn.metadata ?? {}),
          token_type: tokenData.token_type ?? 'Bearer',
          updated_at: new Date().toISOString(),
        },
      })
      .eq('user_id', authUser.id)
      .eq('provider', 'followupboss');

    if (updateError) {
      console.error('❌ [FUB Refresh] Failed to save refreshed tokens:', updateError);
      return new Response(
        JSON.stringify({ error: 'Failed to save refreshed tokens', details: updateError.message }),
        { status: 500, headers: corsHeaders },
      );
    }

    console.log('✅ [FUB Refresh] Token refreshed and saved for user:', authUser.id);

    return new Response(
      JSON.stringify({
        access_token: newAccessToken,
        expires_at: expiresAt.toISOString(),
      }),
      { status: 200, headers: corsHeaders },
    );

  } catch (error) {
    console.error('❌ [FUB Refresh] Fatal error:', error.message);
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { status: 500, headers: corsHeaders },
    );
  }
});
