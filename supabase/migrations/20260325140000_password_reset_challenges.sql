-- Stores short-lived codes for custom forgot-password (no Supabase Auth recovery email).
CREATE TABLE IF NOT EXISTS public.password_reset_challenges (
  email TEXT PRIMARY KEY,
  code TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL
);

ALTER TABLE public.password_reset_challenges ENABLE ROW LEVEL SECURITY;

-- Case-insensitive match for public.users.email (service role bypasses RLS on users).
CREATE OR REPLACE FUNCTION public.find_user_id_for_password_reset(p_email TEXT)
RETURNS UUID
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id
  FROM public.users
  WHERE lower(trim(email)) = lower(trim(p_email))
  LIMIT 1;
$$;

REVOKE ALL ON FUNCTION public.find_user_id_for_password_reset(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.find_user_id_for_password_reset(TEXT) TO service_role;
