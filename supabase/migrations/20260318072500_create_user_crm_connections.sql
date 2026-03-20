-- Create CRM connections table used by Follow Up Boss and GHL edge functions
CREATE TABLE IF NOT EXISTS public.user_crm_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  access_token TEXT,
  refresh_token TEXT,
  expires_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, provider)
);

CREATE INDEX IF NOT EXISTS idx_user_crm_connections_user_id
  ON public.user_crm_connections (user_id);

CREATE INDEX IF NOT EXISTS idx_user_crm_connections_provider
  ON public.user_crm_connections (provider);

ALTER TABLE public.user_crm_connections ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'user_crm_connections'
      AND policyname = 'Users can read own CRM connections'
  ) THEN
    CREATE POLICY "Users can read own CRM connections"
      ON public.user_crm_connections
      FOR SELECT
      USING (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'user_crm_connections'
      AND policyname = 'Users can insert own CRM connections'
  ) THEN
    CREATE POLICY "Users can insert own CRM connections"
      ON public.user_crm_connections
      FOR INSERT
      WITH CHECK (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'user_crm_connections'
      AND policyname = 'Users can update own CRM connections'
  ) THEN
    CREATE POLICY "Users can update own CRM connections"
      ON public.user_crm_connections
      FOR UPDATE
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'user_crm_connections'
      AND policyname = 'Users can delete own CRM connections'
  ) THEN
    CREATE POLICY "Users can delete own CRM connections"
      ON public.user_crm_connections
      FOR DELETE
      USING (auth.uid() = user_id);
  END IF;
END $$;
