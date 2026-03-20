-- ============================================================================
-- Add missing RPC functions:
--   get_agent_profile_header
--   get_task_overview_counts
--   get_task_queue_table
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. get_agent_profile_header
-- Returns the current user's profile info from auth.users metadata
-- Output: { id, full_name, first_name, last_name, role, status, avatar_url,
--           brokerage_id, brokerage_name }
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_agent_profile_header()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id  uuid;
  v_user     record;
  v_meta     jsonb;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  SELECT id, email, raw_user_meta_data
    INTO v_user
    FROM auth.users
   WHERE id = v_user_id;

  v_meta := COALESCE(v_user.raw_user_meta_data, '{}'::jsonb);

  RETURN jsonb_build_object(
    'id',             v_user.id::text,
    'full_name',      COALESCE(
                        v_meta->>'full_name',
                        v_meta->>'name',
                        split_part(v_user.email, '@', 1)
                      ),
    'first_name',     COALESCE(v_meta->>'first_name', split_part(COALESCE(v_meta->>'full_name', v_meta->>'name', ''), ' ', 1)),
    'last_name',      COALESCE(v_meta->>'last_name',  split_part(COALESCE(v_meta->>'full_name', v_meta->>'name', ''), ' ', 2)),
    'role',           COALESCE(v_meta->>'role', 'agent'),
    'status',         COALESCE(v_meta->>'status', 'active'),
    'avatar_url',     v_meta->>'avatar_url',
    'brokerage_id',   v_meta->>'brokerage_id',
    'brokerage_name', COALESCE(v_meta->>'brokerage_name', '')
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_agent_profile_header() TO authenticated;


-- ----------------------------------------------------------------------------
-- 2. get_task_overview_counts
-- Returns task counts for the current user
-- Output: { total_open_tasks, awaiting_approval, sla_breaches_today }
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_task_overview_counts()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id          uuid;
  v_total_open       int;
  v_awaiting         int;
  v_sla_breaches     int;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Open tasks: queued or running
  SELECT COUNT(*) INTO v_total_open
    FROM automation_tasks
   WHERE user_id = v_user_id
     AND status IN ('queued', 'running', 'open');

  -- Awaiting approval: pending
  SELECT COUNT(*) INTO v_awaiting
    FROM automation_tasks
   WHERE user_id = v_user_id
     AND status = 'pending';

  -- SLA breaches today: tasks older than 24h still not complete
  SELECT COUNT(*) INTO v_sla_breaches
    FROM automation_tasks
   WHERE user_id = v_user_id
     AND status NOT IN ('completed', 'failed', 'rejected')
     AND created_at < NOW() - INTERVAL '24 hours';

  RETURN jsonb_build_object(
    'total_open_tasks',   v_total_open,
    'awaiting_approval',  v_awaiting,
    'sla_breaches_today', v_sla_breaches
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_task_overview_counts() TO authenticated;


-- ----------------------------------------------------------------------------
-- 3. get_task_queue_table
-- Returns the task queue for the current user with computed fields
-- Output array of: { id, task_type, status, priority, sla_countdown,
--                    queue_position, assigned_admin_id, assigned_admin_name }
-- Status values mapped to what the app expects:
--   queued/running → open
--   pending        → waiting_admin
--   completed      → complete
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_task_queue_table()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_result  jsonb;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id',                  t.id::text,
        'task_type',           t.task_type,
        'status',              CASE t.status
                                 WHEN 'queued'    THEN 'open'
                                 WHEN 'running'   THEN 'open'
                                 WHEN 'pending'   THEN 'waiting_admin'
                                 WHEN 'completed' THEN 'complete'
                                 WHEN 'failed'    THEN 'complete'
                                 WHEN 'rejected'  THEN 'complete'
                                 ELSE t.status
                               END,
        'priority',            NULL,
        'sla_countdown',       CASE
                                 WHEN t.status IN ('completed', 'failed', 'rejected') THEN '—'
                                 WHEN t.created_at < NOW() - INTERVAL '24 hours' THEN 'Overdue'
                                 ELSE
                                   CONCAT(
                                     GREATEST(
                                       0,
                                       EXTRACT(HOUR FROM (t.created_at + INTERVAL '24 hours' - NOW()))::int
                                     ),
                                     'h left'
                                   )
                               END,
        'queue_position',      (ROW_NUMBER() OVER (ORDER BY t.created_at ASC))::int,
        'assigned_admin_id',   t.user_id::text,
        'assigned_admin_name', COALESCE(
                                 u.raw_user_meta_data->>'full_name',
                                 u.raw_user_meta_data->>'name',
                                 split_part(u.email, '@', 1)
                               )
      )
      ORDER BY t.created_at ASC
    ),
    '[]'::jsonb
  )
  INTO v_result
  FROM automation_tasks t
  JOIN auth.users u ON u.id = t.user_id
  WHERE t.user_id = v_user_id
    AND t.status NOT IN ('completed', 'failed', 'rejected');

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_task_queue_table() TO authenticated;
