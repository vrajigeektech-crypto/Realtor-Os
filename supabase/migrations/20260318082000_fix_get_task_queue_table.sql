-- Fix get_task_queue_table: compute ROW_NUMBER in a CTE/subquery
-- before passing to jsonb_agg to avoid window-in-aggregate error.

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

  SELECT COALESCE(jsonb_agg(row_to_json(q)::jsonb ORDER BY q.queue_position ASC), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT
      t.id::text                                                        AS id,
      t.task_type                                                       AS task_type,
      CASE t.status
        WHEN 'queued'    THEN 'open'
        WHEN 'running'   THEN 'open'
        WHEN 'pending'   THEN 'waiting_admin'
        WHEN 'completed' THEN 'complete'
        WHEN 'failed'    THEN 'complete'
        WHEN 'rejected'  THEN 'complete'
        ELSE t.status
      END                                                               AS status,
      NULL::text                                                        AS priority,
      CASE
        WHEN t.status IN ('completed', 'failed', 'rejected') THEN '—'
        WHEN t.created_at < NOW() - INTERVAL '24 hours'      THEN 'Overdue'
        ELSE CONCAT(
               GREATEST(0,
                 EXTRACT(HOUR FROM (t.created_at + INTERVAL '24 hours' - NOW()))::int
               ),
               'h left'
             )
      END                                                               AS sla_countdown,
      ROW_NUMBER() OVER (ORDER BY t.created_at ASC)::int               AS queue_position,
      t.user_id::text                                                   AS assigned_admin_id,
      COALESCE(
        u.raw_user_meta_data->>'full_name',
        u.raw_user_meta_data->>'name',
        split_part(u.email, '@', 1)
      )                                                                 AS assigned_admin_name
    FROM automation_tasks t
    JOIN auth.users u ON u.id = t.user_id
    WHERE t.user_id = v_user_id
      AND t.status NOT IN ('completed', 'failed', 'rejected')
    ORDER BY t.created_at ASC
  ) q;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_task_queue_table() TO authenticated;
