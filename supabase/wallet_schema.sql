-- ==========================================
-- REALTOR OS: WALLET & EXECUTION ARCHITECTURE
-- ==========================================

-- -------------------------------------------------------------------------------------
-- 0. WALLETS TABLE & RLS
-- -------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.wallets (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    org_id uuid,
    agent_id uuid,
    wallet_type text DEFAULT 'personal'
);

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own wallets"
    ON public.wallets FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own wallets"
    ON public.wallets FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own wallets"
    ON public.wallets FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- -------------------------------------------------------------------------------------
-- 1. TABLES
-- -------------------------------------------------------------------------------------

-- WALLET COMMITMENTS TABLE (Box 3)
CREATE TABLE IF NOT EXISTS public.wallet_commitments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    wallet_id uuid NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
    commitment_type text NOT NULL,
    reserved_amount integer NOT NULL CHECK (reserved_amount > 0),
    status text NOT NULL CHECK (status IN ('active', 'executed', 'cancelled')),
    related_object_id text,
    created_at timestamp with time zone DEFAULT now()
);

-- AUTOMATION TASKS TABLE (Box 4)
CREATE TABLE IF NOT EXISTS public.automation_tasks (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_type text NOT NULL,
    status text NOT NULL CHECK (status IN ('queued', 'running', 'completed', 'failed')),
    related_commitment_id uuid REFERENCES public.wallet_commitments(id) ON DELETE SET NULL,
    created_at timestamp with time zone DEFAULT now()
);

-- TOKEN LEDGER TABLE (Box 6)
CREATE TABLE IF NOT EXISTS public.token_ledger (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    wallet_id uuid NOT NULL REFERENCES public.wallets(id) ON DELETE CASCADE,
    entry_type text NOT NULL CHECK (entry_type IN ('earn', 'spend', 'purchase', 'transfer')),
    amount integer NOT NULL, 
    source text,
    created_at timestamp with time zone DEFAULT now()
);

-- -------------------------------------------------------------------------------------
-- 2. RPC FUNCTIONS (No math in Flutter - all handled here)
-- -------------------------------------------------------------------------------------

-- 1. Available Execution Balance
-- Available Balance = Total wallet balance (or sum of all earnings minus all spends in ledger, for now assuming the wallets table has an absolute total or we calculate it) minus all active commitments.
CREATE OR REPLACE FUNCTION get_wallet_balance(p_wallet_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    total_ledger_balance integer;
    total_commitments integer;
BEGIN
    -- Calculate total balance from ledger (earnings/purchases minus spends/transfers)
    -- Or, read from some base balance if wallets table tracks total deposits.
    -- Assuming a simple ledger calculation here:
    SELECT COALESCE(SUM(
        CASE 
            WHEN entry_type IN ('earn', 'purchase') THEN amount 
            WHEN entry_type IN ('spend', 'transfer') THEN -amount 
            ELSE 0 
        END
    ), 0) INTO total_ledger_balance
    FROM public.token_ledger
    WHERE wallet_id = p_wallet_id;

    -- Calculate total locked in active commitments
    SELECT COALESCE(SUM(reserved_amount), 0) INTO total_commitments
    FROM public.wallet_commitments
    WHERE wallet_id = p_wallet_id AND status = 'active';

    -- Note: If the `wallets` table itself has a `balance_tokens` base column that gets 
    -- updated independently of the ledger, you would use that instead of total_ledger_balance.
    -- For now, returning Ledger Balance - Commitments.
    
    RETURN total_ledger_balance - total_commitments;
END;
$$;

-- 2. Wallet History
CREATE OR REPLACE FUNCTION get_wallet_history(p_wallet_id uuid)
RETURNS TABLE (
    day timestamp with time zone,
    net_change integer,
    running_balance integer
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH daily_changes AS (
        SELECT 
            date_trunc('day', created_at) AS day_bucket,
            SUM(
                CASE 
                    WHEN entry_type IN ('earn', 'purchase') THEN amount 
                    WHEN entry_type IN ('spend', 'transfer') THEN -amount 
                    ELSE 0 
                END
            )::integer AS change
        FROM public.token_ledger
        WHERE wallet_id = p_wallet_id
        GROUP BY 1
    )
    SELECT 
        day_bucket, 
        change, 
        SUM(change) OVER (ORDER BY day_bucket ASC)::integer AS running_balance
    FROM daily_changes
    ORDER BY day_bucket DESC
    LIMIT 30;
END;
$$;

-- 3. Execution Ledger
CREATE OR REPLACE FUNCTION get_wallet_transactions(p_wallet_id uuid)
RETURNS TABLE (
    created_at timestamp with time zone,
    entry_type text,
    amount integer,
    source text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT t.created_at, t.entry_type, t.amount, t.source
    FROM public.token_ledger t
    WHERE t.wallet_id = p_wallet_id
    ORDER BY t.created_at DESC
    LIMIT 100;
END;
$$;

-- 4. Active Commitments Card
CREATE OR REPLACE FUNCTION get_wallet_commitments_summary(p_wallet_id uuid)
RETURNS TABLE (
    commitment_type text,
    total_reserved_amount integer
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT w.commitment_type, COALESCE(SUM(w.reserved_amount), 0)::integer
    FROM public.wallet_commitments w
    WHERE w.wallet_id = p_wallet_id AND w.status = 'active'
    GROUP BY w.commitment_type;
END;
$$;

-- Wallet Health Metrics (New Section)
CREATE OR REPLACE FUNCTION get_wallet_health(p_user_id uuid, p_wallet_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_available_tokens integer;
    v_reserved_tokens integer;
    v_spent_30d integer;
    v_expiring_7d integer;
BEGIN
    -- Available
    v_available_tokens := get_wallet_balance(p_wallet_id);
    
    -- Reserved
    SELECT COALESCE(SUM(reserved_amount), 0) INTO v_reserved_tokens
    FROM public.wallet_commitments
    WHERE wallet_id = p_wallet_id AND status = 'active';

    -- Spent Last 30 Days
    SELECT COALESCE(SUM(amount), 0) INTO v_spent_30d
    FROM public.token_ledger
    WHERE wallet_id = p_wallet_id 
      AND entry_type = 'spend' 
      AND created_at >= NOW() - INTERVAL '30 days';

    -- Expiring Soon (mock value context, adjust if expiring logic exists)
    v_expiring_7d := 0;

    RETURN json_build_object(
        'availableTokens', v_available_tokens,
        'reservedTokens', v_reserved_tokens,
        'tokensSpentLast30Days', v_spent_30d,
        'expiringNext7Days', v_expiring_7d
    );
END;
$$;

-- 5. Recommended Interventions (Mock Example)
CREATE OR REPLACE FUNCTION get_recommended_interventions(p_user_id uuid)
RETURNS TABLE (
    intervention_type text,
    description text,
    token_cost integer,
    action_key text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'system_alert'::text, 
        'Your CRM has 50 stale leads. Run an AI cleanup campaign to re-engage them.'::text, 
        15::integer, 
        'activate_ai_cleanup'::text
    UNION ALL
    SELECT 
        'opportunity'::text, 
        'New high-intent lead detected. Escalate to a live concierge call now.'::text, 
        10::integer, 
        'escalate_live_call'::text;
END;
$$;

-- 6. Operational Trust Level
CREATE OR REPLACE FUNCTION get_operational_trust(p_user_id uuid)
RETURNS TABLE (
    current_level integer,
    next_level integer,
    progress_percent integer
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Mock values for now
    RETURN QUERY
    SELECT 
        4::integer,
        5::integer,
        65::integer;
END;
$$;

-- 7. VA Status + Assignment Count
CREATE OR REPLACE FUNCTION get_automation_summary(p_user_id uuid)
RETURNS TABLE (
    va_status text,
    active_assignments_count integer,
    running_tasks_count integer
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'online'::text,
        (SELECT count(*)::int FROM public.automation_tasks WHERE user_id = p_user_id AND status = 'queued'),
        (SELECT count(*)::int FROM public.automation_tasks WHERE user_id = p_user_id AND status = 'running');
END;
$$;
