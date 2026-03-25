// POST body:
//   { email, otp, verify_only: true }  — checks code only (OTP screen).
//   { email, otp, new_password }         — checks code, updates password, clears challenge.
// Deploy: supabase functions deploy forgot-password-complete --no-verify-jwt
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type, prefer, accept-profile, content-profile, x-supabase-api-version',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Max-Age': '86400',
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let out = 0;
  for (let i = 0; i < a.length; i++) {
    out |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return out === 0;
}

async function resolveUserIdForPasswordReset(
  admin: SupabaseClient,
  email: string,
): Promise<string | null> {
  const { data: uid, error: rpcError } = await admin.rpc(
    'find_user_id_for_password_reset',
    { p_email: email },
  );
  if (!rpcError && uid != null) return uid as string;

  const { data: listData, error: listError } = await admin.auth.admin.listUsers({
    page: 1,
    perPage: 1000,
  });
  if (listError) {
    console.warn('[forgot-password-complete] listUsers:', listError.message);
    return null;
  }
  const u = listData.users.find((x) => (x.email ?? '').toLowerCase() === email);
  return u?.id ?? null;
}

type ChallengeResult =
  | { ok: true }
  | { ok: false; response: Response };

async function validateOtpChallenge(
  admin: SupabaseClient,
  email: string,
  otp: string,
): Promise<ChallengeResult> {
  if (!/^\d{6}$/.test(otp)) {
    return { ok: false, response: json({ error: 'Invalid or expired code' }, 400) };
  }

  const { data: row, error: fetchErr } = await admin
    .from('password_reset_challenges')
    .select('code, expires_at')
    .eq('email', email)
    .maybeSingle();

  if (fetchErr || !row) {
    return { ok: false, response: json({ error: 'Invalid or expired code' }, 400) };
  }

  if (new Date(row.expires_at as string) < new Date()) {
    await admin.from('password_reset_challenges').delete().eq('email', email);
    return { ok: false, response: json({ error: 'Invalid or expired code' }, 400) };
  }

  if (!timingSafeEqual(String(row.code), otp)) {
    return { ok: false, response: json({ error: 'Invalid or expired code' }, 400) };
  }

  return { ok: true };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  try {
    const body = await req.json().catch(() => ({}));
    const rawEmail = typeof body.email === 'string' ? body.email.trim() : '';
    const email = rawEmail.toLowerCase();
    const otp = typeof body.otp === 'string' ? body.otp.trim() : '';
    const verifyOnly = body.verify_only === true || body.verify_only === 'true';
    const newPassword = typeof body.new_password === 'string' ? body.new_password : '';

    if (!email || !email.includes('@')) {
      return json({ error: 'Invalid email' }, 400);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    if (!supabaseUrl || !serviceKey) {
      return json({ error: 'Server misconfigured' }, 500);
    }

    const admin = createClient(supabaseUrl, serviceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const challenge = await validateOtpChallenge(admin, email, otp);
    if (!challenge.ok) return challenge.response;

    if (verifyOnly) {
      return json({ ok: true }, 200);
    }

    if (newPassword.length < 6) {
      return json({ error: 'Password must be at least 6 characters' }, 400);
    }

    const userId = await resolveUserIdForPasswordReset(admin, email);
    if (userId == null) {
      return json({ error: 'Invalid or expired code' }, 400);
    }

    const { error: updateErr } = await admin.auth.admin.updateUserById(userId, {
      password: newPassword,
    });

    if (updateErr) {
      console.error('[forgot-password-complete] updateUserById:', updateErr);
      return json({ error: 'Could not update password' }, 500);
    }

    await admin.from('password_reset_challenges').delete().eq('email', email);

    return json({ ok: true }, 200);
  } catch (e) {
    console.error('[forgot-password-complete]', e);
    return json({ error: 'Internal error' }, 500);
  }
});
