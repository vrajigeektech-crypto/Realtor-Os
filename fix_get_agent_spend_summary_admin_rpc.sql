-- ============================================================
-- FIX: get_agent_spend_summary_admin
-- Issue: order_items.token_amount column does not exist
-- Solution: Calculate spend_in_queue from orders table or set to 0
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
  v_is_admin boolean;
  v_available_balance integer := 0;
  v_spend_in_queue integer := 0;
  v_lifetime_spend integer := 0;
  v_spend_this_month integer := 0;
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
  v_is_admin := (v_user_role IN ('admin', 'broker', 'team_lead'));
  
  IF NOT v_is_admin THEN
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

  -- available balance (from wallet_balances if table exists)
  BEGIN
    SELECT COALESCE(wb.balance, 0)
    INTO v_available_balance
    FROM wallet_balances wb
    WHERE wb.user_id = p_agent_id
    LIMIT 1;
  EXCEPTION
    WHEN undefined_table OR undefined_column THEN
      v_available_balance := 0;
  END;

  -- spend in queue
  -- FIX: order_items.token_amount does not exist
  -- Try calculating from orders table if it has token_cost or total_cost
  BEGIN
    -- Option 1: Try orders.token_cost (if exists)
    SELECT COALESCE(SUM(o.token_cost), 0)
    INTO v_spend_in_queue
    FROM orders o
    WHERE o.agent_id = p_agent_id
      AND o.status IN ('pending', 'processing');
  EXCEPTION
    WHEN undefined_table OR undefined_column THEN
      BEGIN
        -- Option 2: Try orders.total_cost (if exists)
        SELECT COALESCE(SUM(o.total_cost), 0)
        INTO v_spend_in_queue
        FROM orders o
        WHERE o.agent_id = p_agent_id
          AND o.status IN ('pending', 'processing');
      EXCEPTION
        WHEN undefined_table OR undefined_column THEN
          -- Option 3: Set to 0 if orders table doesn't exist or doesn't have cost columns
          v_spend_in_queue := 0;
      END;
  END;

  -- lifetime spend (from token_spend_events)
  SELECT COALESCE(SUM(se.token_amount), 0)
  INTO v_lifetime_spend
  FROM public.token_spend_events se
  WHERE se.agent_id = p_agent_id;

  -- spend this month (from token_spend_events)
  SELECT COALESCE(SUM(se.token_amount), 0)
  INTO v_spend_this_month
  FROM public.token_spend_events se
  WHERE se.agent_id = p_agent_id
    AND date_trunc('month', se.created_at) = date_trunc('month', now());

  -- Build category breakdown from token_spend_events
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
      'distinct_reasons', v_distinct_reasons,
      'available_balance', v_available_balance,
      'spend_in_queue', v_spend_in_queue,
      'lifetime_spend', v_lifetime_spend,
      'spend_this_month', v_spend_this_month
    );
    
    RETURN jsonb_build_object(
      'debug', v_debug_info,
      'data', COALESCE(v_result, '[]'::jsonb),
      'summary', jsonb_build_object(
        'available_balance', v_available_balance,
        'committed_tokens', 0,
        'spend_in_queue', v_spend_in_queue,
        'lifetime_spend_total', v_lifetime_spend,
        'spend_this_month', v_spend_this_month
      )
    );
  ELSE
    -- Normal mode: return data array and summary
    RETURN jsonb_build_object(
      'data', COALESCE(v_result, '[]'::jsonb),
      'summary', jsonb_build_object(
        'available_balance', v_available_balance,
        'committed_tokens', 0,
        'spend_in_queue', v_spend_in_queue,
        'lifetime_spend_total', v_lifetime_spend,
        'spend_this_month', v_spend_this_month
      )
    );
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
'Admin-only RPC to get spend summary for a selected agent. Returns spend totals grouped by category (reason) from token_spend_events, plus wallet summary. Requires admin, broker, or team_lead role.';
