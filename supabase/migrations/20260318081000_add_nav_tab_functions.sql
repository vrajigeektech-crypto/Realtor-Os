-- ============================================================================
-- Add navigation RPC functions:
--   get_agent_nav_tabs    → static tab list
--   get_active_tab_state  → default active tab
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_agent_nav_tabs()
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT jsonb_build_array(
    jsonb_build_object('id', 'overview',  'label', 'Overview'),
    jsonb_build_object('id', 'tasks',     'label', 'Tasks'),
    jsonb_build_object('id', 'wallet',    'label', 'Wallet'),
    jsonb_build_object('id', 'settings',  'label', 'Settings')
  );
$$;

GRANT EXECUTE ON FUNCTION public.get_agent_nav_tabs() TO authenticated;


CREATE OR REPLACE FUNCTION public.get_active_tab_state()
RETURNS text
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT 'overview'::text;
$$;

GRANT EXECUTE ON FUNCTION public.get_active_tab_state() TO authenticated;
