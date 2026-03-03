-- Fix RLS policies for automation_tasks table
-- Add missing INSERT policy for automation_tasks

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
