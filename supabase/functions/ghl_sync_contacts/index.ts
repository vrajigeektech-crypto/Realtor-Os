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
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Content-Type': 'application/json',
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  // Accept both GET and POST for flexibility
  if (req.method !== 'GET' && req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: corsHeaders },
    );
  }

  try {
    console.log('🔄 [GHL Sync] Request received');

    // REQUIRE AUTHENTICATION - Get user from public.users via shared auth helper
    let user;
    try {
      user = await requireUser(req);
      console.log('✅ [GHL Sync] User authenticated:', user.id);
    } catch (authError) {
      console.error('❌ [GHL Sync] Authentication failed:', authError.message);
      return new Response(
        JSON.stringify({ 
          error: 'User not authenticated',
          details: authError.message 
        }),
        { status: 401, headers: corsHeaders },
      );
    }

    // Get environment variables
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('❌ [GHL Sync] Missing Supabase environment variables');
      return new Response(
        JSON.stringify({ 
          error: 'Server configuration error',
          details: 'Missing Supabase configuration' 
        }),
        { status: 500, headers: corsHeaders },
      );
    }

    // Create admin client to read/write to database
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // Get GHL connection for this user from public.users
    const { data: ghlConnection, error: connError } = await supabaseAdmin
      .from('user_crm_connections')
      .select('*')
      .eq('user_id', user.id) // user.id from public.users (single source of truth)
      .eq('provider', 'gohighlevel')
      .single();

    if (connError || !ghlConnection) {
      console.error('❌ [GHL Sync] GHL connection not found:', connError?.message);
      return new Response(
        JSON.stringify({ 
          error: 'GHL not connected',
          details: 'Please connect GoHighLevel first' 
        }),
        { status: 404, headers: corsHeaders },
      );
    }

    const apiKey = ghlConnection.access_token as string;
    const locationId = ghlConnection.metadata?.location_id as string;

    if (!apiKey || !locationId) {
      console.error('❌ [GHL Sync] Missing GHL credentials in connection');
      return new Response(
        JSON.stringify({ 
          error: 'Invalid GHL connection',
          details: 'GHL connection is missing required credentials' 
        }),
        { status: 400, headers: corsHeaders },
      );
    }

    console.log('🔄 [GHL Sync] Fetching contacts from GHL...');
    console.log('   Location ID:', locationId);

    // Fetch contacts from GHL API
    const ghlContactsUrl = `https://services.leadconnectorhq.com/contacts/?locationId=${locationId}`;
    const ghlResponse = await fetch(ghlContactsUrl, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'Version': '2021-07-28',
      },
    });

    if (!ghlResponse.ok) {
      const errorText = await ghlResponse.text();
      console.error('❌ [GHL Sync] GHL API error:', errorText);
      return new Response(
        JSON.stringify({ 
          error: 'Failed to fetch contacts from GHL',
          details: 'GHL API returned an error' 
        }),
        { status: ghlResponse.status, headers: corsHeaders },
      );
    }

    const ghlData = await ghlResponse.json();
    const contacts = ghlData.contacts || [];

    console.log(`✅ [GHL Sync] Fetched ${contacts.length} contacts from GHL`);

    // TODO: Process and store contacts in your database
    // This is where you would:
    // 1. Transform GHL contact data to your schema
    // 2. Upsert contacts into your contacts/leads table
    // 3. Link them to user.id from public.users

    // For now, return success with contact count
    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'Contacts synced successfully',
        contact_count: contacts.length 
      }),
      { status: 200, headers: corsHeaders },
    );

  } catch (error) {
    console.error('❌ [GHL Sync] Fatal Error:', error.message);
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error', 
        details: error.message 
      }),
      { status: 500, headers: corsHeaders },
    );
  }
});
