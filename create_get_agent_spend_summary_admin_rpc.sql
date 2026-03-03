-- ============================================================
-- RPC: get_agent_spend_summary_admin
-- Purpose: Admin-only RPC to return spend totals for a selected agent
-- Input: p_agent_id (uuid)
-- Output: Array of { category: text, total_tokens: integer }
-- ============================================================

DROP FUNCTION IF EXISTS public.get_agent_spend_summary_admin(uuid) CASCADE;

CREATE OR REPLACE FUNCTION public.get_agent_spend_summary_admin(
  p_agent_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_user_role text;
  v_debug boolean := true; -- Enable debug mode
  v_spend_row_count integer;
  v_distinct_reasons integer;
  v_result jsonb;
  v_debug_info jsonb;
BEGIN
  -- Get the current authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Check requester role from public.users
  SELECT role INTO v_user_role
  FROM public.users
  WHERE id = v_user_id AND is_deleted = false;

  IF v_user_role IS NULL THEN
    RAISE EXCEPTION 'User not found in public.users';
  END IF;

  -- Enforce admin access: allow admin, broker, team_lead
  IF v_user_role NOT IN ('admin', 'broker', 'team_lead') THEN
    RAISE EXCEPTION 'Access denied. Admin, broker, or team_lead role required. Current role: %', v_user_role;
  END IF;

  -- Validate p_agent_id is provided
  IF p_agent_id IS NULL THEN
    RAISE EXCEPTION 'p_agent_id is required';
  END IF;

  -- Get spend row count and distinct reasons for debug
  SELECT 
    COUNT(*),
    COUNT(DISTINCT reason)
  INTO 
    v_spend_row_count,
    v_distinct_reasons
  FROM public.token_spend_events
  WHERE agent_id = p_agent_id;

  -- Query token_spend_events where agent_id = p_agent_id
  -- Group by reason and sum token_amount
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'category', reason,
        'total_tokens', SUM(token_amount)::integer
      )
      ORDER BY reason ASC
    ),
    '[]'::jsonb
  )
  INTO v_result
  FROM public.token_spend_events
  WHERE agent_id = p_agent_id
  GROUP BY reason;

  -- If debug mode is enabled, wrap result with debug info
  IF v_debug THEN
    v_debug_info := jsonb_build_object(
      'requested_agent_id', p_agent_id::text,
      'requester_user_id', v_user_id::text,
      'requester_role', v_user_role,
      'is_authorized', true,
      'spend_row_count', v_spend_row_count,
      'distinct_reasons', v_distinct_reasons
    );
    
    RETURN jsonb_build_object(
      'debug', v_debug_info,
      'data', COALESCE(v_result, '[]'::jsonb)
    );
  ELSE
    -- Normal mode: return data array only
    RETURN COALESCE(v_result, '[]'::jsonb);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Re-raise with context
    RAISE EXCEPTION 'get_agent_spend_summary_admin failed: %', SQLERRM;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_agent_spend_summary_admin(uuid) TO authenticated;

-- Add comment
COMMENT ON FUNCTION public.get_agent_spend_summary_admin(uuid) IS 
'Admin-only RPC to get spend summary for a selected agent. Returns spend totals grouped by category (reason) from token_spend_events. Requires admin, broker, or team_lead role.';
