// POST { email } — sends a 6-digit code by email (Resend). Does not use Supabase Auth /recover.
//
// Deploy (required or the app shows “Failed to fetch” on web):
//   supabase db push   # or run migration 20260325140000_password_reset_challenges.sql
//   supabase functions deploy forgot-password-send-otp --no-verify-jwt
//   supabase functions deploy forgot-password-complete --no-verify-jwt
//
// Secrets (Supabase → Project Settings → Edge Functions → Secrets):
//   RESEND_API_KEY — API key from resend.com
//   MAIL_FROM      — e.g. "MyApp <noreply@yourdomain.com>" (see below)
// Without RESEND_API_KEY the code is only logged — no email is sent.
//
// --- Email to ANY user (production) ---
// Resend’s default onboarding@resend.dev only delivers to the email you used to
// sign up at Resend. To send reset codes to all app users:
//   1. resend.com/domains → Add domain → add DNS records (SPF/DKIM) until verified.
//   2. Set MAIL_FROM to an address on THAT domain (not @gmail.com, not resend.dev).
//   3. Save secrets; new invocations pick them up (no redeploy required).
//
// Firebase Hosting only serves the web app; it does not send these emails.
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type, prefer, accept-profile, content-profile, x-supabase-api-version',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Max-Age': '86400',
};

const CODE_TTL_MS = 10 * 60 * 1000;

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function randomSixDigit(): string {
  return String(Math.floor(100000 + Math.random() * 900000));
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
    console.warn('[forgot-password-send-otp] listUsers:', listError.message);
    return null;
  }
  const u = listData.users.find((x) => (x.email ?? '').toLowerCase() === email);
  return u?.id ?? null;
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
    const raw = typeof body.email === 'string' ? body.email.trim() : '';
    const email = raw.toLowerCase();
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

    const userId = await resolveUserIdForPasswordReset(admin, email);

    const okBody: Record<string, unknown> = {
      ok: true,
      message: 'If an account exists for this email, a code was sent.',
    };

    if (userId == null) {
      console.log(`[forgot-password-send-otp] No user for email: ${email}`);
      return json(okBody, 200);
    }

    const code = randomSixDigit();
    const expiresAt = new Date(Date.now() + CODE_TTL_MS).toISOString();

    const { error: upsertError } = await admin.from('password_reset_challenges').upsert(
      { email, code, expires_at: expiresAt },
      { onConflict: 'email' },
    );

    if (upsertError) {
      console.error('[forgot-password-send-otp] upsert failed:', upsertError);
      return json({ error: 'Could not create reset code' }, 500);
    }

    const resendKey = Deno.env.get('RESEND_API_KEY');
    const mailFrom = Deno.env.get('MAIL_FROM') ?? 'onboarding@resend.dev';

    if (resendKey && /resend\.dev$/i.test(mailFrom.trim().split(/[\s<>]+/).pop() ?? '')) {
      console.warn(
        '[forgot-password-send-otp] MAIL_FROM is on resend.dev — Resend only delivers to your Resend signup email. Set MAIL_FROM to a verified custom domain to email all users.',
      );
    }

    if (resendKey) {
      const r = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${resendKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: mailFrom,
          to: [email],
          subject: 'Your password reset code',
          html:
            `<p>Your verification code is:</p><p style="font-size:24px;font-weight:bold;letter-spacing:4px">${code}</p>` +
            `<p>It expires in 10 minutes. If you did not request this, ignore this email.</p>`,
        }),
      });
      if (!r.ok) {
        const t = await r.text();
        console.error('[forgot-password-send-otp] Resend HTTP', r.status, t);
        let resendMessage = '';
        try {
          const j = JSON.parse(t) as { message?: string; name?: string };
          resendMessage = [j.name, j.message].filter(Boolean).join(': ') || t;
        } catch {
          resendMessage = t.slice(0, 400);
        }
        const testingRestriction =
          /only send testing emails|verify a domain at resend/i.test(resendMessage);
        const hint = testingRestriction
          ? 'For all users: verify a domain at https://resend.com/domains, then set secret MAIL_FROM to an address on that domain (e.g. "MyApp <noreply@yourdomain.com>").'
          : 'Check Supabase Edge Function secrets RESEND_API_KEY and MAIL_FROM; the from-address domain must be verified in Resend.';
        const errorSummary =
          resendMessage && resendMessage !== t
            ? `Could not send email: ${resendMessage}`
            : `Could not send email (Resend HTTP ${r.status})`;
        // Use HTTP 200 + ok:false so the full body reaches clients. Supabase often
        // replaces non-2xx responses with a generic { error } and drops details.
        return json({
          ok: false,
          error: errorSummary,
          details: resendMessage || 'Unknown Resend error',
          hint,
        }, 200);
      }
      okBody.email_sent = true;
    } else {
      console.warn(
        `[forgot-password-send-otp] RESEND_API_KEY not set — no email; code for ${email}: ${code}`,
      );
      okBody.email_sent = false;
      okBody.message =
        'Code generated but email is not configured (set RESEND_API_KEY). Check Edge Function logs for the code.';
    }

    return json(okBody, 200);
  } catch (e) {
    console.error('[forgot-password-send-otp]', e);
    return json({ error: 'Internal error' }, 500);
  }
});
