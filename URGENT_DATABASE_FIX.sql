-- =====================================================
-- URGENT FIX: Create missing database tables and storage
-- Run this in Supabase SQL Editor immediately
-- =====================================================

-- 1. Create the missing public.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  phone TEXT,
  secondary_phone TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'agent', 'broker', 'user')),
  org_id UUID,
  broker_id UUID REFERENCES public.users(id),
  team_lead_id UUID REFERENCES public.users(id),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'pending')),
  onboarded BOOLEAN DEFAULT false,
  onboarding_completed BOOLEAN DEFAULT false,
  onboarding_step INTEGER DEFAULT 0,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  joined_at TIMESTAMP WITH TIME ZONE,
  last_login TIMESTAMP WITH TIME ZONE,
  last_activity_date TIMESTAMP WITH TIME ZONE,
  logo_url TEXT,
  headshot_url TEXT,
  writing_sample TEXT,
  voice_sample_url TEXT,
  gallery_urls TEXT[],
  gallery_count INTEGER DEFAULT 0,
  primary_logo_url TEXT,
  primary_headshot_url TEXT,
  primary_writing_sample_url TEXT,
  primary_voice_sample_url TEXT,
  tokens_balance DECIMAL(10,2) DEFAULT 0.00,
  xp_total INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0
);

-- 2. Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS policies
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- 4. Create auto-create user function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.users (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- 5. Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6. Updated_at trigger
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON public.users 
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 7. Create user_assets storage bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('user_assets', 'user_assets', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- 8. Create storage policies for user_assets
CREATE POLICY "Users can upload their own assets" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view their own assets" ON storage.objects
FOR SELECT USING (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own assets" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'user_assets' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- 9. Create existing user record for demo user if exists
INSERT INTO public.users (id, email, created_at)
SELECT id, email, created_at FROM auth.users WHERE email = 'demo@gmail.com'
ON CONFLICT (id) DO NOTHING;

-- 10. Grant necessary permissions
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.users TO service_role;
