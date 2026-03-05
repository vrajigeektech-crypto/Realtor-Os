-- ============================================================================
-- get_users_list (Fixed Version - No tasks table dependency)
-- Returns all users for user management table
-- Input: None (uses auth.uid() for permissions - admins see all, brokers see their agents)
-- Output: jsonb array of users with comprehensive fields
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_users_list() CASCADE;

CREATE OR REPLACE FUNCTION public.get_users_list()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_user_role text;
  v_users jsonb;
BEGIN
  -- Get the current authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Get current user's role
  SELECT role INTO v_user_role
  FROM public.users
  WHERE id = v_user_id AND is_deleted = false;

  IF v_user_role IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  -- Build query based on user role
  -- Admins see all users, Brokers see their agents, others see only themselves
  IF v_user_role = 'admin' THEN
    -- Admin: Get all users with comprehensive data
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', u.id::text,
          'name', u.name,
          'email', u.email,
          'phone', u.phone,
          'secondary_phone', u.secondary_phone,
          'role', u.role,
          'status', u.status,
          'org_id', u.org_id::text,
          'broker_id', u.broker_id::text,
          'team_lead_id', u.team_lead_id::text,
          'onboarded', u.onboarded,
          'onboarding_completed', u.onboarding_completed,
          'onboarding_step', u.onboarding_step,
          'is_deleted', u.is_deleted,
          'created_at', u.created_at,
          'updated_at', u.updated_at,
          'joined_at', u.joined_at,
          'last_login', u.last_login,
          'last_activity_date', u.last_activity_date,
          'logo_url', u.logo_url,
          'headshot_url', u.headshot_url,
          'writing_sample', u.writing_sample,
          'voice_sample_url', u.voice_sample_url,
          'gallery_urls', u.gallery_urls,
          'gallery_count', u.gallery_count,
          'primary_logo_url', u.primary_logo_url,
          'primary_headshot_url', u.primary_headshot_url,
          'primary_writing_sample_url', u.primary_writing_sample_url,
          'primary_voice_sample_url', u.primary_voice_sample_url,
          'tokens_balance', COALESCE(u.tokens_balance, 0),
          'xp_total', u.xp_total,
          'level', u.level,
          'current_streak', u.current_streak,
          'longest_streak', u.longest_streak,
          'total_orders', 0, -- Default to 0 since tasks table doesn't exist
          'has_flags', false -- TODO: Implement flag logic if needed
        )
        ORDER BY u.name ASC
      ),
      '[]'::jsonb
    )
    INTO v_users
    FROM public.users u
    WHERE u.is_deleted = false;
  ELSIF v_user_role = 'broker' THEN
    -- Broker: Get their agents with comprehensive data
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', u.id::text,
          'name', u.name,
          'email', u.email,
          'phone', u.phone,
          'secondary_phone', u.secondary_phone,
          'role', u.role,
          'status', u.status,
          'org_id', u.org_id::text,
          'broker_id', u.broker_id::text,
          'team_lead_id', u.team_lead_id::text,
          'onboarded', u.onboarded,
          'onboarding_completed', u.onboarding_completed,
          'onboarding_step', u.onboarding_step,
          'is_deleted', u.is_deleted,
          'created_at', u.created_at,
          'updated_at', u.updated_at,
          'joined_at', u.joined_at,
          'last_login', u.last_login,
          'last_activity_date', u.last_activity_date,
          'logo_url', u.logo_url,
          'headshot_url', u.headshot_url,
          'writing_sample', u.writing_sample,
          'voice_sample_url', u.voice_sample_url,
          'gallery_urls', u.gallery_urls,
          'gallery_count', u.gallery_count,
          'primary_logo_url', u.primary_logo_url,
          'primary_headshot_url', u.primary_headshot_url,
          'primary_writing_sample_url', u.primary_writing_sample_url,
          'primary_voice_sample_url', u.primary_voice_sample_url,
          'tokens_balance', COALESCE(u.tokens_balance, 0),
          'xp_total', u.xp_total,
          'level', u.level,
          'current_streak', u.current_streak,
          'longest_streak', u.longest_streak,
          'total_orders', 0, -- Default to 0 since tasks table doesn't exist
          'has_flags', false
        )
        ORDER BY u.name ASC
      ),
      '[]'::jsonb
    )
    INTO v_users
    FROM public.users u
    WHERE (u.broker_id = v_user_id OR u.id = v_user_id)
      AND u.is_deleted = false;
  ELSE
    -- Agent/Team Lead: See only themselves with comprehensive data
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', u.id::text,
          'name', u.name,
          'email', u.email,
          'phone', u.phone,
          'secondary_phone', u.secondary_phone,
          'role', u.role,
          'status', u.status,
          'org_id', u.org_id::text,
          'broker_id', u.broker_id::text,
          'team_lead_id', u.team_lead_id::text,
          'onboarded', u.onboarded,
          'onboarding_completed', u.onboarding_completed,
          'onboarding_step', u.onboarding_step,
          'is_deleted', u.is_deleted,
          'created_at', u.created_at,
          'updated_at', u.updated_at,
          'joined_at', u.joined_at,
          'last_login', u.last_login,
          'last_activity_date', u.last_activity_date,
          'logo_url', u.logo_url,
          'headshot_url', u.headshot_url,
          'writing_sample', u.writing_sample,
          'voice_sample_url', u.voice_sample_url,
          'gallery_urls', u.gallery_urls,
          'gallery_count', u.gallery_count,
          'primary_logo_url', u.primary_logo_url,
          'primary_headshot_url', u.primary_headshot_url,
          'primary_writing_sample_url', u.primary_writing_sample_url,
          'primary_voice_sample_url', u.primary_voice_sample_url,
          'tokens_balance', COALESCE(u.tokens_balance, 0),
          'xp_total', u.xp_total,
          'level', u.level,
          'current_streak', u.current_streak,
          'longest_streak', u.longest_streak,
          'total_orders', 0, -- Default to 0 since tasks table doesn't exist
          'has_flags', false
        )
      ),
      '[]'::jsonb
    )
    INTO v_users
    FROM public.users u
    WHERE u.id = v_user_id
      AND u.is_deleted = false;
  END IF;

  RETURN COALESCE(v_users, '[]'::jsonb);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_users_list() TO authenticated;
