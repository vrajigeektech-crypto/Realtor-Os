-- Fix automation_tasks RLS policies and add RPC function
-- Add missing INSERT/UPDATE/DELETE policies and RPC function

-- Drop existing RPC function first
DROP FUNCTION IF EXISTS create_automation_task(uuid, text, text);

-- Allow users to insert their own automation tasks
CREATE POLICY "Users can insert their own automation tasks"
  ON automation_tasks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own automation tasks  
CREATE POLICY "Users can update their own automation tasks"
  ON automation_tasks FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own automation tasks
CREATE POLICY "Users can delete their own automation tasks"
  ON automation_tasks FOR DELETE
  USING (auth.uid() = user_id);

-- Create RPC function to safely insert automation tasks
CREATE OR REPLACE FUNCTION create_automation_task(
    p_user_id UUID,
    p_task_type TEXT,
    p_status TEXT DEFAULT 'queued'
)
RETURNS TABLE (
    task_id UUID,
    user_id UUID,
    task_type TEXT,
    status TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Insert automation task with proper security
    INSERT INTO automation_tasks (
        id,
        user_id,
        task_type,
        status,
        created_at
    ) VALUES (
        gen_random_uuid(),
        p_user_id,
        p_task_type,
        p_status,
        NOW()
    )
    RETURNING 
        id as task_id,
        automation_tasks.user_id,
        task_type,
        status,
        created_at;
END;
$$;
