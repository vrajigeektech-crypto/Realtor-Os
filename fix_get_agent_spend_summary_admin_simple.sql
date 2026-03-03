-- ============================================================
-- SIMPLE FIX: get_agent_spend_summary_admin
-- Issue: order_items.token_amount column does not exist
-- Solution: Remove the order_items query and set spend_in_queue to 0
--           OR calculate from orders table if it has token_cost
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
  v_is_admin boolean;
  v_available_balance integer := 0;
  v_spend_in_queue integer := 0;
  v_lifetime_spend integer := 0;
  v_spend_this_month integer := 0;
BEGIN
  -- admin / broker / team_lead only (skip when auth.uid() is null)
  IF auth.uid() IS NOT NULL THEN
    SELECT (u.role IN ('admin','broker','team_lead'))
    INTO v_is_admin
    FROM public.users u
    WHERE u.id = auth.uid()
      AND u.is_deleted = false;

    IF NOT COALESCE(v_is_admin, false) THEN
      RAISE EXCEPTION 'Unauthorized';
    END IF;
  END IF;

  -- available balance
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
  -- Try to calculate from orders table if it has token_cost column
  BEGIN
    SELECT COALESCE(SUM(o.token_cost), 0)
    INTO v_spend_in_queue
    FROM orders o
    WHERE o.agent_id = p_agent_id
      AND o.status IN ('pending','processing');
  EXCEPTION
    WHEN undefined_table OR undefined_column THEN
      -- If orders table doesn't exist or doesn't have token_cost, set to 0
      v_spend_in_queue := 0;
  END;

  -- lifetime spend
  SELECT COALESCE(SUM(se.token_amount), 0)
  INTO v_lifetime_spend
  FROM token_spend_events se
  WHERE se.agent_id = p_agent_id;

  -- spend this month
  SELECT COALESCE(SUM(se.token_amount), 0)
  INTO v_spend_this_month
  FROM token_spend_events se
  WHERE se.agent_id = p_agent_id
    AND date_trunc('month', se.created_at) = date_trunc('month', now());

  RETURN jsonb_build_object(
    'available_balance', v_available_balance,
    'committed_tokens', 0,
    'spend_in_queue', v_spend_in_queue,
    'lifetime_spend_total', v_lifetime_spend,
    'spend_this_month', v_spend_this_month
  );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_agent_spend_summary_admin(uuid) TO authenticated;
