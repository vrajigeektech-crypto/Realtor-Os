-- ============================================================================
-- Setup Test User for Unit Testing
-- Creates auth user and links to public.users table
-- ============================================================================

-- First, create the auth user (if not exists)
-- Note: You'll need to create this user through Supabase Auth UI or API
-- This SQL assumes the auth user already exists or will be created via Supabase Auth

-- Insert/Update the public.users record
INSERT INTO public.users (
  id, 
  email, 
  name, 
  phone, 
  secondary_phone, 
  role, 
  org_id, 
  broker_id, 
  team_lead_id, 
  status, 
  onboarded, 
  onboarding_completed, 
  onboarding_step, 
  is_deleted, 
  created_at, 
  joined_at, 
  last_login, 
  last_activity_date, 
  logo_url, 
  headshot_url, 
  writing_sample, 
  voice_sample_url, 
  gallery_urls, 
  gallery_count, 
  primary_logo_url, 
  primary_headshot_url, 
  primary_writing_sample_url, 
  primary_voice_sample_url, 
  tokens_balance, 
  xp_total, 
  level, 
  current_streak, 
  longest_streak
) VALUES (
  'e4ee6ff1-acf3-499c-8d72-dda825082368',
  'approver@test.com',
  NULL,
  NULL,
  NULL,
  'admin',
  NULL,
  NULL,
  NULL,
  'active',
  false,
  false,
  0,
  false,
  '2025-12-19 01:46:37.963705+00',
  '2026-01-22 17:50:13.980949+00',
  NULL,
  '2026-01-12 07:37:19.512276',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  0,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) 
DO UPDATE SET
  email = EXCLUDED.email,
  role = EXCLUDED.role,
  status = EXCLUDED.status,
  last_activity_date = EXCLUDED.last_activity_date;

-- Note: You still need to create the auth.users entry
-- This can be done through Supabase Dashboard > Authentication > Users
-- Or via the Supabase Auth API
