-- =============================================================================
-- Email / auth URL setup (hosted Supabase)
-- =============================================================================
-- On hosted Supabase there is NO table `auth.email_templates` — templates are
-- edited in the Dashboard only:
--   Authentication → Email Templates
--
-- Site URL & redirect allowlist (not via SQL on hosted):
--   Authentication → URL Configuration
--   Set Site URL to your real app (e.g. https://yourapp.web.app)
--   Add Additional Redirect URLs for local/dev if needed.
--
-- Forgot password in this app uses Edge Functions + Resend (see repo), not
-- Auth “recovery” email SQL.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Optional: helpers in your public schema (safe to run in SQL Editor)
-- -----------------------------------------------------------------------------

-- Check whether a given user id has confirmed email (call with care from RLS-safe RPCs).
CREATE OR REPLACE FUNCTION public.check_email_verification(user_id UUID)
RETURNS TABLE(email_verified BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  RETURN QUERY
  SELECT (au.email_confirmed_at IS NOT NULL) AS email_verified
  FROM auth.users au
  WHERE au.id = user_id;
END;
$$;

REVOKE ALL ON FUNCTION public.check_email_verification(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.check_email_verification(UUID) TO authenticated;

-- Only the current user’s own row (do not expose all users to authenticated).
CREATE OR REPLACE VIEW public.verified_users AS
SELECT
  au.id,
  au.email,
  au.email_confirmed_at,
  au.created_at,
  au.updated_at
FROM auth.users au
WHERE au.email_confirmed_at IS NOT NULL
  AND au.id = auth.uid();

GRANT SELECT ON public.verified_users TO authenticated;

-- Optional audit table (public schema)
CREATE TABLE IF NOT EXISTS public.email_verification_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users (id),
  email TEXT NOT NULL,
  action TEXT NOT NULL, -- e.g. signup, recovery, resend
  status TEXT NOT NULL, -- e.g. sent, failed, verified
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.email_verification_logs ENABLE ROW LEVEL SECURITY;

-- Idempotent: safe to re-run the whole script in SQL Editor.
DROP POLICY IF EXISTS email_verification_logs_select_own ON public.email_verification_logs;
DROP POLICY IF EXISTS email_verification_logs_insert_own ON public.email_verification_logs;

-- Users can insert/read only their own log rows (adjust if you use service role only).
CREATE POLICY email_verification_logs_select_own
  ON public.email_verification_logs
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY email_verification_logs_insert_own
  ON public.email_verification_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.log_email_event(
  user_id UUID,
  email TEXT,
  action TEXT,
  status TEXT,
  error_message TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  INSERT INTO public.email_verification_logs (user_id, email, action, status, error_message)
  VALUES (user_id, email, action, status, error_message);
END;
$$;

REVOKE ALL ON FUNCTION public.log_email_event(UUID, TEXT, TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.log_email_event(UUID, TEXT, TEXT, TEXT, TEXT) TO authenticated;
