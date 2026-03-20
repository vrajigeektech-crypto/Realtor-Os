  import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
  import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

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

    return publicUser as AuthenticatedUser;
  }

  const SYSTEM_NAME = 'Realtor_OS';
  const SYSTEM_KEY = 'faf48c01b12e37eed790202040ff847f';

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
      let user: AuthenticatedUser;
      try {
        user = await requireUser(req);
      } catch (authError) {
        return new Response(
          JSON.stringify({
            error: 'User not authenticated',
            details: authError.message,
          }),
          { status: 401, headers: corsHeaders },
        );
      }

      const body = await req.json().catch(() => ({}));
      const apiKey = body.api_key as string | undefined;

      if (!apiKey || apiKey.trim().length === 0) {
        return new Response(
          JSON.stringify({
            error: 'Missing required field',
            details: 'api_key is required',
          }),
          { status: 400, headers: corsHeaders },
        );
      }

      const basicAuth = `Basic ${btoa(`${apiKey.trim()}:`)}`;
      const validationResponse = await fetch('https://api.followupboss.com/v1/people?limit=1', {
        method: 'GET',
        headers: {
          Authorization: basicAuth,
          'Content-Type': 'application/json',
          'X-System': SYSTEM_NAME,
          'X-System-Key': SYSTEM_KEY,
        },
      });

      if (!validationResponse.ok) {
        const errorText = await validationResponse.text();
        console.error('❌ [FUB Connect] Credential validation failed:', errorText);
        return new Response(
          JSON.stringify({
            error: 'Invalid Follow Up Boss API key',
            details: 'The provided API key could not be validated',
          }),
          { status: 401, headers: corsHeaders },
        );
      }

      const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
      const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

      if (!supabaseUrl || !supabaseServiceKey) {
        return new Response(
          JSON.stringify({
            error: 'Server configuration error',
            details: 'Missing Supabase configuration',
          }),
          { status: 500, headers: corsHeaders },
        );
      }

      const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);
      const { error: dbError } = await supabaseAdmin
        .from('user_crm_connections')
        .upsert(
          {
            user_id: user.id,
            provider: 'followupboss',
            access_token: apiKey.trim(),
            refresh_token: null,
            expires_at: null,
            metadata: {
              auth_method: 'api_key',
              created_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            },
          },
          {
            onConflict: 'user_id,provider',
          },
        );

      if (dbError) {
        console.error('❌ [FUB Connect] Database error:', dbError);
        return new Response(
          JSON.stringify({
            error: 'Failed to save connection',
            details: dbError.message,
          }),
          { status: 500, headers: corsHeaders },
        );
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: 'Follow Up Boss connected successfully',
        }),
        { status: 200, headers: corsHeaders },
      );
    } catch (error) {
      console.error('❌ [FUB Connect] Fatal Error:', error.message);
      return new Response(
        JSON.stringify({
          error: 'Internal server error',
          details: error.message,
        }),
        { status: 500, headers: corsHeaders },
      );
    }
  });
