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

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    console.log('🔗 [GHL Connect] Request received');

    // REQUIRE AUTHENTICATION - Get user from public.users via shared auth helper
    let user;
    try {
      user = await requireUser(req);
      console.log('✅ [GHL Connect] User authenticated:', user.id);
    } catch (authError) {
      console.error('❌ [GHL Connect] Authentication failed:', authError.message);
      return new Response(
        JSON.stringify({ 
          error: 'User not authenticated',
          details: authError.message 
        }),
        { status: 401, headers: corsHeaders },
      );
    }

    // Parse request body
    const body = await req.json().catch(() => ({}));
    const apiKey = body.api_key as string;
    const locationId = body.location_id as string;

    if (!apiKey || !locationId) {
      return new Response(
        JSON.stringify({ 
          error: 'Missing required fields',
          details: 'api_key and location_id are required' 
        }),
        { status: 400, headers: corsHeaders },
      );
    }

    console.log('🔗 [GHL Connect] Validating GHL credentials...');
    console.log('   Location ID:', locationId);

    // Validate GHL API credentials by making a test API call
    // Using a simple endpoint to verify the API key and location ID
    const ghlTestUrl = `https://services.leadconnectorhq.com/locations/${locationId}`;
    const ghlTestResponse = await fetch(ghlTestUrl, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'Version': '2021-07-28',
      },
    });

    if (!ghlTestResponse.ok) {
      const errorText = await ghlTestResponse.text();
      console.error('❌ [GHL Connect] GHL API validation failed:', errorText);
      return new Response(
        JSON.stringify({ 
          error: 'Invalid GHL credentials',
          details: 'The provided API key or Location ID is invalid' 
        }),
        { status: 401, headers: corsHeaders },
      );
    }

    console.log('✅ [GHL Connect] GHL credentials validated');

    // Get environment variables
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('❌ [GHL Connect] Missing Supabase environment variables');
      return new Response(
        JSON.stringify({ 
          error: 'Server configuration error',
          details: 'Missing Supabase configuration' 
        }),
        { status: 500, headers: corsHeaders },
      );
    }

    // Create admin client to write to database
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // Store connection in user_crm_connections using user.id from public.users
    const { error: dbError } = await supabaseAdmin
      .from('user_crm_connections')
      .upsert(
        {
          user_id: user.id, // user.id from public.users (single source of truth)
          provider: 'gohighlevel',
          access_token: apiKey, // Store API key as access_token
          refresh_token: null,
          expires_at: null, // GHL API keys don't expire
          metadata: {
            location_id: locationId,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          },
        },
        {
          onConflict: 'user_id,provider',
        },
      );

    if (dbError) {
      console.error('❌ [GHL Connect] Database error:', dbError);
      return new Response(
        JSON.stringify({ 
          error: 'Failed to save connection',
          details: dbError.message 
        }),
        { status: 500, headers: corsHeaders },
      );
    }

    console.log('✅ [GHL Connect] Connection saved successfully for user:', user.id);

    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'GoHighLevel connected successfully' 
      }),
      { status: 200, headers: corsHeaders },
    );

  } catch (error) {
    console.error('❌ [GHL Connect] Fatal Error:', error.message);
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error', 
        details: error.message 
      }),
      { status: 500, headers: corsHeaders },
    );
  }
});
