-- ==============================================================================
-- MULTI-TENANT SAAS BILLING & ANALYTICS DASHBOARD - DATABASE SCHEMA
-- Engine: PostgreSQL 15+ (Supabase)
-- Strategy: Shared Database, Shared Schema with Strict Row-Level Security (RLS)
-- ==============================================================================

-- 1. EXTENSIONS & PREREQUISITES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. CUSTOM TYPES & ENUMS
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('owner', 'admin', 'billing_manager', 'member', 'viewer');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE subscription_status AS ENUM (
        'trialing',
        'active',
        'past_due',
        'canceled',
        'unpaid',
        'incomplete',
        'incomplete_expired',
        'paused'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE billing_interval AS ENUM ('month', 'year');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE invoice_status AS ENUM ('draft', 'open', 'paid', 'uncollectible', 'void');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ==============================================================================
-- 3. CORE MULTI-TENANCY & AUTH TABLES
-- ==============================================================================

-- 3.1 Organizations (Tenants)
CREATE TABLE IF NOT EXISTS public.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    stripe_customer_id VARCHAR(255) UNIQUE,
    billing_email VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Index for lookup by slug and stripe customer id
CREATE INDEX IF NOT EXISTS idx_organizations_slug ON public.organizations(slug);
CREATE INDEX IF NOT EXISTS idx_organizations_stripe_cust ON public.organizations(stripe_customer_id);

-- 3.2 User Profiles (Extends auth.users)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    default_organization_id UUID REFERENCES public.organizations(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_user_profiles_default_org ON public.user_profiles(default_organization_id);

-- 3.3 Organization Memberships (RBAC + Tenant Binding)
CREATE TABLE IF NOT EXISTS public.organization_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'member',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_org_user UNIQUE (organization_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_org_members_org ON public.organization_memberships(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_members_user ON public.organization_memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_org_members_user_org ON public.organization_memberships(user_id, organization_id);

-- ==============================================================================
-- 4. BILLING & SUBSCRIPTIONS TABLES (STRIPE SYNCHRONIZED)
-- ==============================================================================

-- 4.1 Subscription Plans (Catalog / Tiers)
CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stripe_product_id VARCHAR(255) UNIQUE NOT NULL,
    stripe_price_id VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT true,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    amount_in_cents INTEGER NOT NULL, -- e.g., 4900 = $49.00
    interval billing_interval NOT NULL DEFAULT 'month',
    features JSONB NOT NULL DEFAULT '[]'::jsonb, -- e.g., ["unlimited_users", "priority_support"]
    limits JSONB NOT NULL DEFAULT '{}'::jsonb,   -- e.g., {"api_calls_per_month": 100000, "storage_gb": 50}
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 4.2 Tenant Subscriptions
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.subscription_plans(id),
    stripe_subscription_id VARCHAR(255) UNIQUE NOT NULL,
    status subscription_status NOT NULL DEFAULT 'trialing',
    quantity INTEGER NOT NULL DEFAULT 1,
    current_period_start TIMESTAMPTZ NOT NULL,
    current_period_end TIMESTAMPTZ NOT NULL,
    cancel_at_period_end BOOLEAN NOT NULL DEFAULT false,
    canceled_at TIMESTAMPTZ,
    trial_start TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_org ON public.subscriptions(organization_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe_id ON public.subscriptions(stripe_subscription_id);

-- 4.3 Invoices
CREATE TABLE IF NOT EXISTS public.invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE SET NULL,
    stripe_invoice_id VARCHAR(255) UNIQUE,
    invoice_number VARCHAR(100) NOT NULL,
    amount_due_cents INTEGER NOT NULL,
    amount_paid_cents INTEGER NOT NULL DEFAULT 0,
    amount_remaining_cents INTEGER NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    status invoice_status NOT NULL DEFAULT 'paid',
    due_date TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    invoice_pdf_url TEXT,
    hosted_invoice_url TEXT,
    line_items JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_invoices_org ON public.invoices(organization_id);
CREATE INDEX IF NOT EXISTS idx_invoices_org_created ON public.invoices(organization_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON public.invoices(status);

-- ==============================================================================
-- 5. USAGE METERING & TELEMETRY (ANALYTICS & PLUTO_GRID CORE)
-- ==============================================================================

-- 5.1 Meter Metric Definitions
CREATE TABLE IF NOT EXISTS public.usage_meters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meter_key VARCHAR(100) UNIQUE NOT NULL, -- e.g. 'api_calls', 'storage_gb', 'active_seats', 'compute_hours'
    name VARCHAR(255) NOT NULL,
    unit VARCHAR(50) NOT NULL,              -- e.g. 'Requests', 'Gigabytes', 'Seats', 'Hours'
    aggregation_type VARCHAR(20) NOT NULL DEFAULT 'sum', -- 'sum', 'max', 'last'
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 5.2 Usage Records (High volume telemetry / usage records)
CREATE TABLE IF NOT EXISTS public.usage_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    meter_id UUID NOT NULL REFERENCES public.usage_meters(id) ON DELETE CASCADE,
    customer_user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    quantity NUMERIC(14, 4) NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    resource_id VARCHAR(255),               -- specific API endpoint, file path, or worker node
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_usage_records_org_time ON public.usage_records(organization_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_usage_records_org_meter_time ON public.usage_records(organization_id, meter_id, timestamp DESC);

-- ==============================================================================
-- 6. AUDIT LOGGING & STRIPE WEBHOOK IDEMPOTENCY
-- ==============================================================================

-- 6.1 Audit Logs
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL, -- e.g. 'plan.upgraded', 'member.invited', 'billing.payment_method_updated'
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(255) NOT NULL,
    changes JSONB DEFAULT '{}'::jsonb,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_org_time ON public.audit_logs(organization_id, created_at DESC);

-- 6.2 Stripe Webhook Event Log (Guarantees Idempotency)
CREATE TABLE IF NOT EXISTS public.stripe_webhook_events (
    id VARCHAR(255) PRIMARY KEY, -- Stripe Event ID (e.g., 'evt_1N2...')
    event_type VARCHAR(100) NOT NULL,
    api_version VARCHAR(50),
    data JSONB NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    error_message TEXT
);

CREATE INDEX IF NOT EXISTS idx_stripe_events_type ON public.stripe_webhook_events(event_type);

-- ==============================================================================
-- 7. HELPER FUNCTIONS FOR ROW LEVEL SECURITY (RLS)
-- ==============================================================================

-- Function: Returns the current user's active tenant IDs
CREATE OR REPLACE FUNCTION public.get_user_organization_ids()
RETURNS SETOF UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
    SELECT organization_id
    FROM public.organization_memberships
    WHERE user_id = auth.uid();
$$;

-- Function: Check if user belongs to specific organization
CREATE OR REPLACE FUNCTION public.has_organization_access(org_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.organization_memberships
        WHERE organization_id = org_id
          AND user_id = auth.uid()
    );
$$;

-- Function: Get current user role in organization
CREATE OR REPLACE FUNCTION public.get_organization_role(org_id UUID)
RETURNS user_role
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
    SELECT role
    FROM public.organization_memberships
    WHERE organization_id = org_id
      AND user_id = auth.uid()
    LIMIT 1;
$$;

-- ==============================================================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Enable RLS across all tables
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_meters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usage_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stripe_webhook_events ENABLE ROW LEVEL SECURITY;

-- 8.1 Organizations
CREATE POLICY "Users can view organizations they belong to"
    ON public.organizations
    FOR SELECT
    USING (public.has_organization_access(id));

CREATE POLICY "Owners and Admins can update organization"
    ON public.organizations
    FOR UPDATE
    USING (public.get_organization_role(id) IN ('owner', 'admin'));

-- 8.2 User Profiles
CREATE POLICY "Users can view their own profile and profiles of tenant members"
    ON public.user_profiles
    FOR SELECT
    USING (
        id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.organization_memberships m1
            JOIN public.organization_memberships m2 ON m1.organization_id = m2.organization_id
            WHERE m1.user_id = auth.uid() AND m2.user_id = public.user_profiles.id
        )
    );

CREATE POLICY "Users can update their own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (id = auth.uid());

-- 8.3 Organization Memberships
CREATE POLICY "Members can view membership list of their organization"
    ON public.organization_memberships
    FOR SELECT
    USING (public.has_organization_access(organization_id));

CREATE POLICY "Owners and Admins can manage organization members"
    ON public.organization_memberships
    FOR ALL
    USING (public.get_organization_role(organization_id) IN ('owner', 'admin'));

-- 8.4 Subscription Plans (Catalog is readable by all authenticated users)
CREATE POLICY "Authenticated users can view active subscription plans"
    ON public.subscription_plans
    FOR SELECT
    TO authenticated
    USING (active = true);

-- 8.5 Subscriptions
CREATE POLICY "Members can view their tenant subscription"
    ON public.subscriptions
    FOR SELECT
    USING (public.has_organization_access(organization_id));

-- 8.6 Invoices
CREATE POLICY "Members can view their tenant invoices"
    ON public.invoices
    FOR SELECT
    USING (public.has_organization_access(organization_id));

-- 8.7 Usage Meters
CREATE POLICY "Authenticated users can view usage meter types"
    ON public.usage_meters
    FOR SELECT
    TO authenticated
    USING (true);

-- 8.8 Usage Records
CREATE POLICY "Members can view their tenant usage records"
    ON public.usage_records
    FOR SELECT
    USING (public.has_organization_access(organization_id));

CREATE POLICY "Service roles or admins can insert usage records"
    ON public.usage_records
    FOR INSERT
    WITH CHECK (public.has_organization_access(organization_id));

-- 8.9 Audit Logs
CREATE POLICY "Members can view their tenant audit logs"
    ON public.audit_logs
    FOR SELECT
    USING (public.has_organization_access(organization_id));

-- 8.10 Stripe Webhook Events (Restricted to internal backend/service role)
CREATE POLICY "Service role only for stripe webhooks"
    ON public.stripe_webhook_events
    FOR ALL
    TO service_role
    USING (true);

-- ==============================================================================
-- 9. ANALYTICS & SAAS METRICS VIEWS & STORED PROCEDURES
-- ==============================================================================

-- 9.1 Monthly Recurring Revenue (MRR) & ARR Real-time Calculation View
CREATE OR REPLACE VIEW public.view_saas_revenue_metrics AS
SELECT 
    s.organization_id,
    COUNT(s.id) FILTER (WHERE s.status = 'active') as active_subscriptions_count,
    COALESCE(SUM(
        CASE 
            WHEN s.status = 'active' AND p.interval = 'month' THEN p.amount_in_cents * s.quantity
            WHEN s.status = 'active' AND p.interval = 'year' THEN (p.amount_in_cents * s.quantity) / 12
            ELSE 0 
        END
    ), 0) / 100.0 AS current_mrr_usd,
    (COALESCE(SUM(
        CASE 
            WHEN s.status = 'active' AND p.interval = 'month' THEN p.amount_in_cents * s.quantity
            WHEN s.status = 'active' AND p.interval = 'year' THEN (p.amount_in_cents * s.quantity) / 12
            ELSE 0 
        END
    ), 0) / 100.0) * 12 AS current_arr_usd
FROM public.subscriptions s
JOIN public.subscription_plans p ON s.plan_id = p.id
GROUP BY s.organization_id;

-- 9.2 Realtime Usage Summary for PlutoGrid (Paginated & Aggregated by Customer User)
CREATE OR REPLACE FUNCTION public.get_tenant_usage_summary(
    p_organization_id UUID,
    p_from TIMESTAMPTZ,
    p_to TIMESTAMPTZ
)
RETURNS TABLE (
    user_id UUID,
    user_email VARCHAR(255),
    user_name VARCHAR(255),
    meter_key VARCHAR(100),
    meter_name VARCHAR(255),
    total_quantity NUMERIC,
    unit VARCHAR(50),
    last_activity TIMESTAMPTZ
)
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
    SELECT 
        u.id AS user_id,
        u.email AS user_email,
        u.full_name AS user_name,
        m.meter_key,
        m.name AS meter_name,
        COALESCE(SUM(r.quantity), 0) AS total_quantity,
        m.unit,
        MAX(r.timestamp) AS last_activity
    FROM public.organization_memberships om
    JOIN public.user_profiles u ON om.user_id = u.id
    CROSS JOIN public.usage_meters m
    LEFT JOIN public.usage_records r 
        ON r.customer_user_id = u.id 
        AND r.organization_id = p_organization_id 
        AND r.meter_id = m.id
        AND r.timestamp BETWEEN p_from AND p_to
    WHERE om.organization_id = p_organization_id
      AND public.has_organization_access(p_organization_id)
    GROUP BY u.id, u.email, u.full_name, m.meter_key, m.name, m.unit;
$$;

-- 9.3 SaaS 6-Month Historical Revenue & Churn Trends (For FL Chart)
CREATE OR REPLACE FUNCTION public.get_saas_financial_history(p_organization_id UUID)
RETURNS TABLE (
    month_period TEXT,
    revenue_usd NUMERIC,
    invoices_paid_count BIGINT,
    churn_count BIGINT
)
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
    WITH months AS (
        SELECT to_char(date_trunc('month', d), 'YYYY-MM') AS m_str,
               date_trunc('month', d) AS m_date
        FROM generate_series(
            date_trunc('month', now()) - interval '5 months',
            date_trunc('month', now()),
            interval '1 month'
        ) d
    ),
    rev AS (
        SELECT 
            to_char(date_trunc('month', paid_at), 'YYYY-MM') AS m_str,
            COALESCE(SUM(amount_paid_cents) / 100.0, 0) AS rev_total,
            COUNT(id) AS inv_count
        FROM public.invoices
        WHERE organization_id = p_organization_id
          AND status = 'paid'
          AND paid_at >= (date_trunc('month', now()) - interval '5 months')
        GROUP BY 1
    ),
    churn AS (
        SELECT 
            to_char(date_trunc('month', canceled_at), 'YYYY-MM') AS m_str,
            COUNT(id) AS churned
        FROM public.subscriptions
        WHERE organization_id = p_organization_id
          AND status = 'canceled'
          AND canceled_at >= (date_trunc('month', now()) - interval '5 months')
        GROUP BY 1
    )
    SELECT 
        m.m_str AS month_period,
        COALESCE(r.rev_total, 0.00) AS revenue_usd,
        COALESCE(r.inv_count, 0) AS invoices_paid_count,
        COALESCE(c.churned, 0) AS churn_count
    FROM months m
    LEFT JOIN rev r ON m.m_str = r.m_str
    LEFT JOIN churn c ON m.m_str = c.m_str
    ORDER BY m.m_date ASC;
$$;
