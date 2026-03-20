-- ============================================================================  
-- CRM Database Fix Script
-- This script creates the missing CRM connections table and RPC function
-- Run this in your Supabase SQL editor to fix the CRM errors
-- ============================================================================

-- 1. Create CRM connections table
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

-- 2. Add RLS policies for CRM connections
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

-- 3. Create get_crm_connections RPC function
DROP FUNCTION IF EXISTS public.get_crm_connections() CASCADE;

CREATE OR REPLACE FUNCTION public.get_crm_connections()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_connections jsonb;
BEGIN
  -- Get the current authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Get CRM connections for the current user
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', id::text,
        'provider', provider,
        'access_token', access_token,
        'refresh_token', refresh_token,
        'expires_at', expires_at,
        'metadata', metadata,
        'created_at', created_at,
        'updated_at', updated_at
      )
      ORDER BY created_at DESC
    ),
    '[]'::jsonb
  )
  INTO v_connections
  FROM public.user_crm_connections
  WHERE user_id = v_user_id;

  RETURN COALESCE(v_connections, '[]'::jsonb);
END;
$$;

-- 4. Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_crm_connections() TO authenticated;

-- 5. Verify the setup
SELECT 'CRM connections table created successfully' as status;
SELECT 'get_crm_connections function created successfully' as status;
