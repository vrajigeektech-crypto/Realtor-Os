-- ============================================================================  
-- get_crm_connections
-- Returns CRM connections for the current user
-- Input: None (uses auth.uid())
-- Output: jsonb array of CRM connections with provider, metadata, etc.
-- ============================================================================
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
        'updated_at', updated_at,
        'is_connected', (
          (access_token IS NOT NULL AND access_token <> '') OR
          (refresh_token IS NOT NULL AND refresh_token <> '')
        )
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

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_crm_connections() TO authenticated;
