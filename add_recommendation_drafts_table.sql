-- Persist uploaded images for dashboard recommendations (drafts)
-- Run once in Supabase SQL editor.

CREATE TABLE IF NOT EXISTS public.recommendation_drafts (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recommendation_id text NOT NULL,
  image_urls text[] NOT NULL DEFAULT '{}',
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, recommendation_id)
);

ALTER TABLE public.recommendation_drafts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own recommendation drafts" ON public.recommendation_drafts;
CREATE POLICY "Users can view their own recommendation drafts"
  ON public.recommendation_drafts FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can upsert their own recommendation drafts" ON public.recommendation_drafts;
CREATE POLICY "Users can upsert their own recommendation drafts"
  ON public.recommendation_drafts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own recommendation drafts" ON public.recommendation_drafts;
CREATE POLICY "Users can update their own recommendation drafts"
  ON public.recommendation_drafts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own recommendation drafts" ON public.recommendation_drafts;
CREATE POLICY "Users can delete their own recommendation drafts"
  ON public.recommendation_drafts FOR DELETE
  USING (auth.uid() = user_id);

GRANT ALL ON public.recommendation_drafts TO authenticated;

