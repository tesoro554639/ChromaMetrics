-- ==============================================================================
-- MULTI-TENANT SAAS BILLING & ANALYTICS - SEED DATA
-- Populate realistic test organizations, subscription plans, usage, and invoices
-- ==============================================================================

-- 1. Insert Subscription Plans
INSERT INTO public.subscription_plans (id, stripe_product_id, stripe_price_id, name, description, active, currency, amount_in_cents, interval, features, limits)
VALUES 
    (
        '11111111-1111-1111-1111-111111111111',
        'prod_starter_tier',
        'price_starter_monthly',
        'Starter Plan',
        'Essential billing and monitoring for early-stage startups.',
        true,
        'USD',
        4900,
        'month',
        '["Up to 5 Team Members", "100k Monthly API Calls", "Standard Support", "Basic Analytics"]'::jsonb,
        '{"team_members": 5, "api_calls_monthly": 100000, "storage_gb": 10}'::jsonb
    ),
    (
        '22222222-2222-2222-2222-222222222222',
        'prod_pro_tier',
        'price_pro_monthly',
        'Growth & Pro',
        'Advanced telemetry, custom webhook endpoints, and higher concurrency.',
        true,
        'USD',
        19900,
        'month',
        '["Up to 25 Team Members", "1M Monthly API Calls", "Priority Support", "Real-Time Telemetry", "Custom Invoicing"]'::jsonb,
        '{"team_members": 25, "api_calls_monthly": 1000000, "storage_gb": 100}'::jsonb
    ),
    (
        '33333333-3333-3333-3333-333333333333',
        'prod_enterprise_tier',
        'price_enterprise_yearly',
        'Enterprise Suite',
        'Unlimited scale, dedicated infrastructure, SLA guarantees and audit compliance.',
        true,
        'USD',
        99900,
        'month',
        '["Unlimited Members", "10M Monthly API Calls", "24/7 Dedicated Slack Channel", "Custom RLS Policies", "SOC2 Compliance Export"]'::jsonb,
        '{"team_members": 999, "api_calls_monthly": 10000000, "storage_gb": 1000}'::jsonb
    )
ON CONFLICT (id) DO NOTHING;

-- 2. Insert Usage Meters
INSERT INTO public.usage_meters (id, meter_key, name, unit, aggregation_type)
VALUES
    ('44444444-4444-4444-4444-444444444441', 'api_calls', 'API Requests Metered', 'Requests', 'sum'),
    ('44444444-4444-4444-4444-444444444442', 'storage_gb', 'Storage Retained', 'GB', 'max'),
    ('44444444-4444-4444-4444-444444444443', 'active_seats', 'Active Member Seats', 'Seats', 'last'),
    ('44444444-4444-4444-4444-444444444444', 'compute_hours', 'Serverless Compute Units', 'Compute Hours', 'sum')
ON CONFLICT (id) DO NOTHING;

-- 3. Insert Demo Organizations (Tenants)
INSERT INTO public.organizations (id, name, slug, stripe_customer_id, billing_email, currency)
VALUES
    (
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'Acme Global Corp',
        'acme-global',
        'cus_acme_live_98124',
        'billing@acmeglobal.io',
        'USD'
    ),
    (
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'Starlight AI Robotics',
        'starlight-ai',
        'cus_starlight_live_45311',
        'finance@starlight.ai',
        'USD'
    )
ON CONFLICT (id) DO NOTHING;

-- 4. Insert Subscriptions
INSERT INTO public.subscriptions (
    id, organization_id, plan_id, stripe_subscription_id, status, quantity, 
    current_period_start, current_period_end
)
VALUES
    (
        'sub11111-1111-1111-1111-111111111111',
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        '22222222-2222-2222-2222-222222222222',
        'sub_stripe_acme_pro_01',
        'active',
        1,
        now() - interval '15 days',
        now() + interval '15 days'
    ),
    (
        'sub22222-2222-2222-2222-222222222222',
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        '33333333-3333-3333-3333-333333333333',
        'sub_stripe_starlight_ent_01',
        'active',
        1,
        now() - interval '5 days',
        now() + interval '25 days'
    )
ON CONFLICT (id) DO NOTHING;

-- 5. Insert Sample Historical Invoices
INSERT INTO public.invoices (
    id, organization_id, stripe_invoice_id, invoice_number, amount_due_cents, 
    amount_paid_cents, status, paid_at, invoice_pdf_url, line_items
)
VALUES
    (
        'inv11111-1111-1111-1111-111111111111',
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'in_stripe_acme_oct2026',
        'INV-2026-0091',
        19900,
        19900,
        'paid',
        now() - interval '14 days',
        'https://invoices.saas-platform.io/pdf/INV-2026-0091.pdf',
        '[{"description": "Pro Tier Monthly Base", "amount": 19900, "quantity": 1}]'::jsonb
    ),
    (
        'inv11111-1111-1111-1111-111111111112',
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'in_stripe_acme_sep2026',
        'INV-2026-0078',
        19900,
        19900,
        'paid',
        now() - interval '45 days',
        'https://invoices.saas-platform.io/pdf/INV-2026-0078.pdf',
        '[{"description": "Pro Tier Monthly Base", "amount": 19900, "quantity": 1}]'::jsonb
    ),
    (
        'inv22222-2222-2222-2222-222222222221',
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'in_stripe_starlight_oct2026',
        'INV-2026-0104',
        99900,
        99900,
        'paid',
        now() - interval '4 days',
        'https://invoices.saas-platform.io/pdf/INV-2026-0104.pdf',
        '[{"description": "Enterprise Suite Monthly Base", "amount": 99900, "quantity": 1}]'::jsonb
    )
ON CONFLICT (id) DO NOTHING;
