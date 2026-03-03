-- =====================================================
-- Create missing RPC function for onboarding steps
-- Run this in Supabase SQL Editor
-- =====================================================

-- Create RPC function to complete onboarding steps
CREATE OR REPLACE FUNCTION complete_onboarding_step(
    p_step TEXT,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update the user's onboarding step
    UPDATE public.users 
    SET 
        onboarding_step = LEAST(onboarding_step + 1, 6),
        updated_at = NOW()
    WHERE id = p_user_id;
    
    -- If this is the final step (photos upload), mark onboarding as complete
    IF p_step = 'upload_selfies' THEN
        UPDATE public.users 
        SET 
            onboarding_completed = true,
            onboarded = true,
            updated_at = NOW()
        WHERE id = p_user_id;
    END IF;
    
    RAISE LOG 'Onboarding step completed: % for user %', p_step, p_user_id;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION complete_onboarding_step TO authenticated;
GRANT EXECUTE ON FUNCTION complete_onboarding_step TO service_role;
