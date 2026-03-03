-- =====================================================
-- ADD MISSING COLUMNS TO USERS TABLE
-- Run this in Supabase SQL Editor to fix onboarding errors
-- =====================================================

-- Add missing company_description column
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS company_description TEXT;

-- Add other potentially missing onboarding columns
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS company_name TEXT;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS company_website TEXT;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS company_industry TEXT;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS company_size TEXT;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS brand_voice_description TEXT;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS target_audience TEXT;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS brand_personality TEXT;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS brand_tone TEXT;

-- Verify the columns were added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
    AND table_schema = 'public'
    AND column_name IN (
        'company_description', 'company_name', 'company_website', 
        'company_industry', 'company_size', 'brand_voice_description',
        'target_audience', 'brand_personality', 'brand_tone'
    )
ORDER BY column_name;

-- Check current user data to see what's missing
SELECT id, email, 
       CASE WHEN company_description IS NULL THEN 'MISSING' ELSE 'EXISTS' END as company_description_status,
       CASE WHEN company_name IS NULL THEN 'MISSING' ELSE 'EXISTS' END as company_name_status,
       CASE WHEN brand_voice_description IS NULL THEN 'MISSING' ELSE 'EXISTS' END as brand_voice_status
FROM public.users 
WHERE id = auth.uid();

-- =====================================================
-- TEST ONBOARDING DATA UPDATE
-- =====================================================

-- Test updating the new column
UPDATE public.users 
SET company_description = 'Test company description', updated_at = NOW()
WHERE id = auth.uid() AND company_description IS NULL;

-- Verify the update worked
SELECT company_description, updated_at 
FROM public.users 
WHERE id = auth.uid();
