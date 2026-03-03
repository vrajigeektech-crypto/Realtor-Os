-- ============================================================================
-- Seed Test Tasks for User: jasen.lomnick@gmail.com
-- User ID: 0db45541-2b25-4f78-aa5d-56336a6f1dd2
-- ============================================================================

-- First, verify the user exists
DO $$
DECLARE
  v_user_id uuid := '0db45541-2b25-4f78-aa5d-56336a6f1dd2';
  v_user_exists boolean;
BEGIN
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE id = v_user_id) INTO v_user_exists;
  
  IF NOT v_user_exists THEN
    RAISE EXCEPTION 'User with ID % does not exist in auth.users', v_user_id;
  END IF;
  
  RAISE NOTICE 'User verified: %', v_user_id;
END $$;

-- Insert test tasks with various statuses and categories
INSERT INTO public.tasks (
  id,
  user_id,
  title,
  description,
  category,
  status,
  token_cost,
  xp_reward,
  created_at,
  updated_at,
  sla_breached_at,
  pause_reason,
  paused_at,
  root_cause
) VALUES
-- Open tasks (should appear in queue)
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Create Marketing Video for New Listing',
  'Produce a professional marketing video showcasing the property features, neighborhood, and amenities.',
  'Marketing Video',
  'open',
  50,
  100,
  NOW() - INTERVAL '2 hours',
  NOW() - INTERVAL '2 hours',
  NULL,
  NULL,
  NULL,
  NULL
),
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Launch Social Media Ads Campaign',
  'Create and launch targeted social media advertising campaign for luxury property listings.',
  'Ads Campaign',
  'open',
  75,
  150,
  NOW() - INTERVAL '1 hour',
  NOW() - INTERVAL '1 hour',
  NULL,
  NULL,
  NULL,
  NULL
),
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Prospect Calling Campaign - Q1 Leads',
  'Follow up with Q1 leads and schedule property viewings. Focus on high-value prospects.',
  'Calling Campaign',
  'waiting_admin',
  30,
  75,
  NOW() - INTERVAL '3 hours',
  NOW() - INTERVAL '30 minutes',
  NULL,
  NULL,
  NULL,
  NULL
),
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Review and Approve BPA Documents',
  'Review Buyer Purchase Agreement documents for accuracy and compliance before closing.',
  'BPA Review',
  'waiting_admin',
  25,
  50,
  NOW() - INTERVAL '4 hours',
  NOW() - INTERVAL '1 hour',
  NULL,
  NULL,
  NULL,
  NULL
),
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Property Photography Session',
  'Schedule and conduct professional photography session for new listing. Include drone shots.',
  'Marketing Video',
  'open',
  40,
  80,
  NOW() - INTERVAL '30 minutes',
  NOW() - INTERVAL '30 minutes',
  NULL,
  NULL,
  NULL,
  NULL
),
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Email Marketing Campaign - Spring Listings',
  'Design and send email campaign highlighting spring property listings to subscriber list.',
  'Ads Campaign',
  'open',
  35,
  70,
  NOW() - INTERVAL '15 minutes',
  NOW() - INTERVAL '15 minutes',
  NULL,
  NULL,
  NULL,
  NULL
),
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Client Follow-up Calls',
  'Make follow-up calls to recent property viewers to gauge interest and answer questions.',
  'Calling Campaign',
  'open',
  20,
  40,
  NOW() - INTERVAL '5 minutes',
  NOW() - INTERVAL '5 minutes',
  NULL,
  NULL,
  NULL,
  NULL
),
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Contract Review - Downtown Condo',
  'Review purchase contract for downtown condo listing. Verify all terms and conditions.',
  'BPA Review',
  'open',
  30,
  60,
  NOW(),
  NOW(),
  NULL,
  NULL,
  NULL,
  NULL
),
-- Task with SLA breach (for testing sla_breaches_today)
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Urgent: Property Inspection Report',
  'Review and process urgent property inspection report. SLA was breached.',
  'BPA Review',
  'open',
  45,
  90,
  NOW() - INTERVAL '2 days',
  NOW() - INTERVAL '1 day',
  NOW() - INTERVAL '1 hour', -- SLA breached 1 hour ago (today)
  NULL,
  NULL,
  NULL
),
-- Completed task (should NOT appear in queue)
(
  gen_random_uuid(),
  '0db45541-2b25-4f78-aa5d-56336a6f1dd2',
  'Completed: Virtual Tour Creation',
  'Create virtual tour for luxury property. Task completed successfully.',
  'Marketing Video',
  'complete',
  60,
  120,
  NOW() - INTERVAL '1 day',
  NOW() - INTERVAL '12 hours',
  NULL,
  NULL,
  NULL,
  NULL
)
ON CONFLICT (id) DO NOTHING;

-- Verify inserted tasks
SELECT 
  COUNT(*) as total_tasks,
  COUNT(*) FILTER (WHERE status = 'open') as open_tasks,
  COUNT(*) FILTER (WHERE status = 'waiting_admin') as waiting_admin_tasks,
  COUNT(*) FILTER (WHERE status = 'complete') as completed_tasks,
  COUNT(*) FILTER (WHERE sla_breached_at IS NOT NULL AND DATE(sla_breached_at) = CURRENT_DATE) as sla_breaches_today
FROM public.tasks
WHERE user_id = '0db45541-2b25-4f78-aa5d-56336a6f1dd2';

-- Show all tasks for this user
SELECT 
  id,
  title,
  category,
  status,
  token_cost,
  xp_reward,
  created_at,
  sla_breached_at
FROM public.tasks
WHERE user_id = '0db45541-2b25-4f78-aa5d-56336a6f1dd2'
ORDER BY created_at DESC;
