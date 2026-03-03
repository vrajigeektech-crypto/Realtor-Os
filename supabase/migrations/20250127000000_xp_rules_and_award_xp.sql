-- ============================================================================
-- XP Rules & award_xp_for_event (schema-safe, idempotent)
-- Run: SELECT * FROM public.xp_rules LIMIT 1; to see existing columns first.
-- This migration adds event_key if missing, or uses existing column.
-- ============================================================================

-- 0) Create xp_rules if it does not exist (minimal schema)
CREATE TABLE IF NOT EXISTS public.xp_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_key text,
  xp_amount int NOT NULL DEFAULT 0,
  enabled boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- 1) Ensure xp_rules has event_key (and xp_amount, enabled) for lookup
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_rules' AND column_name = 'event_key') THEN
    ALTER TABLE public.xp_rules ADD COLUMN event_key text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_rules' AND column_name = 'xp_amount') THEN
    ALTER TABLE public.xp_rules ADD COLUMN xp_amount int NOT NULL DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_rules' AND column_name = 'enabled') THEN
    ALTER TABLE public.xp_rules ADD COLUMN enabled boolean DEFAULT true;
  END IF;
  -- Backfill event_key from common column names if they exist
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_rules' AND column_name = 'action') THEN
    UPDATE public.xp_rules SET event_key = COALESCE(event_key, action);
  ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_rules' AND column_name = 'key') THEN
    UPDATE public.xp_rules SET event_key = COALESCE(event_key, key);
  ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_rules' AND column_name = 'event') THEN
    UPDATE public.xp_rules SET event_key = COALESCE(event_key, event);
  END IF;
END $$;

-- 2) Ensure users has xp/total_xp if you track XP on the user row (adjust to your schema)
DO $$
BEGIN
  -- Only try to add XP column if users table exists
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'xp') THEN
      ALTER TABLE public.users ADD COLUMN IF NOT EXISTS xp int NOT NULL DEFAULT 0;
    END IF;
  END IF;
END $$;

-- 3) xp_ledger: one row per (user_id, event_ref) for idempotent awards
CREATE TABLE IF NOT EXISTS public.xp_ledger (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_ref text NOT NULL,
  event_key text NOT NULL,
  xp_awarded int NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, event_ref)
);

-- Ensure event_key column exists if table already existed
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_ledger' AND column_name = 'event_key') THEN
    ALTER TABLE public.xp_ledger ADD COLUMN event_key text;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_xp_ledger_user_id ON public.xp_ledger(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_ledger_event_key ON public.xp_ledger(event_key);

-- 4) RPC: award_xp_for_event — uses event_key, idempotent via xp_ledger
CREATE OR REPLACE FUNCTION public.award_xp_for_event(
  p_user_id uuid,
  p_event_key text,
  p_event_ref text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_xp int;
  v_rule_id uuid;
  v_already_awarded boolean;
  v_inserted integer;
BEGIN
  -- Idempotency: already awarded for this (user, event_ref)?
  SELECT EXISTS (
    SELECT 1 FROM public.xp_ledger
    WHERE user_id = p_user_id AND event_ref = p_event_ref
  ) INTO v_already_awarded;

  IF v_already_awarded THEN
    RETURN jsonb_build_object(
      'awarded', false,
      'reason', 'already_awarded',
      'xp', 0
    );
  END IF;

  -- Look up rule by event_key (canonical column)
  SELECT id, xp_amount INTO v_rule_id, v_xp
  FROM public.xp_rules
  WHERE event_key = p_event_key
    AND (enabled IS NULL OR enabled = true)
  LIMIT 1;

  -- If xp_rules uses a different column name, try action/key/event as fallback
  IF v_rule_id IS NULL AND v_xp IS NULL THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_rules' AND column_name = 'action') THEN
      SELECT id, xp_amount INTO v_rule_id, v_xp FROM public.xp_rules WHERE action = p_event_key AND (enabled IS NULL OR enabled = true) LIMIT 1;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_rules' AND column_name = 'key') THEN
      SELECT id, xp_amount INTO v_rule_id, v_xp FROM public.xp_rules WHERE key = p_event_key AND (enabled IS NULL OR enabled = true) LIMIT 1;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'xp_rules' AND column_name = 'event') THEN
      SELECT id, xp_amount INTO v_rule_id, v_xp FROM public.xp_rules WHERE event = p_event_key AND (enabled IS NULL OR enabled = true) LIMIT 1;
    END IF;
  END IF;

  IF v_rule_id IS NULL OR v_xp IS NULL OR v_xp <= 0 THEN
    RETURN jsonb_build_object('awarded', false, 'reason', 'no_rule_or_zero_xp', 'xp', 0);
  END IF;

  -- Record in ledger (idempotent); only credit if insert succeeded
  INSERT INTO public.xp_ledger (user_id, event_ref, event_key, xp_awarded)
  VALUES (p_user_id, p_event_ref, p_event_key, v_xp)
  ON CONFLICT (user_id, event_ref) DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  IF v_inserted IS NULL OR v_inserted = 0 THEN
    RETURN jsonb_build_object('awarded', false, 'reason', 'conflict', 'xp', 0);
  END IF;

  -- Credit user (assumes users.xp exists)
  UPDATE auth.users
  SET xp = COALESCE(xp, 0) + v_xp
  WHERE id = p_user_id;

  RETURN jsonb_build_object('awarded', true, 'xp', v_xp);
END;
$$;

-- 5) Grant
GRANT EXECUTE ON FUNCTION public.award_xp_for_event(uuid, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.award_xp_for_event(uuid, text, text) TO service_role;

-- ============================================================================
-- Seed XP rules for onboarding events - commented out due to schema conflicts
-- ============================================================================
-- Note: Manual seed may be required after migration due to existing table schema
