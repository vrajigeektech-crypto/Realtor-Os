-- Create or extend public.users when an auth user is registered.
-- Runs as SECURITY DEFINER so it is not blocked by RLS (client upserts fail when
-- signUp returns no session, e.g. email confirmation enabled).

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (
    id,
    email,
    role,
    status,
    onboarded,
    onboarding_completed,
    onboarding_step,
    is_deleted,
    joined_at,
    last_activity_date,
    gallery_count
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    'agent',
    'active',
    false,
    false,
    0,
    false,
    NOW(),
    NOW(),
    0
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
