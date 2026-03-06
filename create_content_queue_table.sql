-- Create content_queue table for admin approval workflow
-- This table will store content items that need admin approval

CREATE TABLE IF NOT EXISTS content_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT,
    content_type TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'approved', 'rejected', 'flagged')),
    file_url TEXT,
    thumbnail_url TEXT,
    preview_icon TEXT,
    task_type TEXT,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    approved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_content_queue_user_id ON content_queue(user_id);
CREATE INDEX IF NOT EXISTS idx_content_queue_status ON content_queue(status);
CREATE INDEX IF NOT EXISTS idx_content_queue_created_at ON content_queue(created_at);

-- Row Level Security (RLS) Policies
ALTER TABLE content_queue ENABLE ROW LEVEL SECURITY;

-- Users can see their own content
CREATE POLICY "Users can view their own content"
    ON content_queue FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own content
CREATE POLICY "Users can insert their own content"
    ON content_queue FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Admins can view all content
CREATE POLICY "Admins can view all content"
    ON content_queue FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Admins can update all content
CREATE POLICY "Admins can update all content"
    ON content_queue FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Grant permissions
GRANT ALL ON content_queue TO authenticated;

-- Create function to get pending content for admin
CREATE OR REPLACE FUNCTION get_pending_content_for_admin()
RETURNS TABLE (
    id UUID,
    user_id UUID,
    title TEXT,
    subtitle TEXT,
    content_type TEXT,
    status TEXT,
    file_url TEXT,
    thumbnail_url TEXT,
    preview_icon TEXT,
    task_type TEXT,
    created_at TIMESTAMPTZ,
    user_email TEXT,
    user_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cq.id,
        cq.user_id,
        cq.title,
        cq.subtitle,
        cq.content_type,
        cq.status,
        cq.file_url,
        cq.thumbnail_url,
        cq.preview_icon,
        cq.task_type,
        cq.created_at,
        u.email::text as user_email,
        COALESCE(u.raw_user_meta_data->>'name', u.email::text) as user_name
    FROM 
        content_queue cq
    JOIN 
        auth.users u ON cq.user_id = u.id
    WHERE 
        cq.status = 'pending'
    ORDER BY 
        cq.created_at ASC;
END;
$$;

-- Create function to approve content
CREATE OR REPLACE FUNCTION approve_content(
    p_content_id UUID,
    p_admin_user_id UUID
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    title TEXT,
    status TEXT,
    approved_at TIMESTAMPTZ,
    approved_by UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE content_queue cq
    SET 
        status = 'approved',
        approved_at = NOW(),
        approved_by = p_admin_user_id
    WHERE 
        cq.id = p_content_id AND 
        cq.status = 'pending'
    RETURNING 
        cq.id,
        cq.user_id,
        cq.title,
        cq.status,
        cq.approved_at,
        cq.approved_by;
END;
$$;

-- Create function to reject content
CREATE OR REPLACE FUNCTION reject_content(
    p_content_id UUID,
    p_admin_user_id UUID,
    p_rejection_reason TEXT DEFAULT 'Rejected by admin'
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    title TEXT,
    status TEXT,
    rejection_reason TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE content_queue cq
    SET 
        status = 'rejected',
        updated_at = NOW()
    WHERE 
        cq.id = p_content_id AND 
        cq.status = 'pending'
    RETURNING 
        cq.id,
        cq.user_id,
        cq.title,
        cq.status,
        p_rejection_reason as rejection_reason;
END;
$$;

-- Grant permissions for new functions
GRANT EXECUTE ON FUNCTION get_pending_content_for_admin TO authenticated;
GRANT EXECUTE ON FUNCTION approve_content TO authenticated;
GRANT EXECUTE ON FUNCTION reject_content TO authenticated;

-- Create trigger to update automation_tasks when content is approved
CREATE OR REPLACE FUNCTION update_automation_task_on_approval()
RETURNS TRIGGER AS $$
BEGIN
    -- When content is approved, update corresponding automation task
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        UPDATE automation_tasks 
        SET status = 'queued'
        WHERE task_type = NEW.task_type 
        AND user_id = NEW.user_id
        AND status = 'pending';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trigger_update_automation_task_on_approval
    AFTER UPDATE ON content_queue
    FOR EACH ROW
    EXECUTE FUNCTION update_automation_task_on_approval();
