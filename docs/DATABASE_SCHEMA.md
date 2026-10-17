# Database Architecture & PostgreSQL RLS Schema

ChromaMetrics utilizes PostgreSQL with Supabase, enforcing strict multi-tenant data isolation at the storage layer via Row-Level Security (RLS).

## Core Data Entities

### 1. `tenants`
Represents an isolated organization / workspace.
```sql
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    plan_tier TEXT DEFAULT 'starter',
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. `tenant_memberships`
Maps users to specific tenants along with their RBAC role (`owner`, `admin`, `billing_manager`, `member`, `viewer`).
```sql
CREATE TABLE tenant_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(tenant_id, user_id)
);
```

### 3. `invoices`
Stores billing records with status (`paid`, `open`, `past_due`, `canceled`).
```sql
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    invoice_number TEXT NOT NULL,
    amount_cents BIGINT NOT NULL,
    currency TEXT DEFAULT 'USD',
    status TEXT NOT NULL,
    paid_at TIMESTAMPTZ,
    due_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Row-Level Security (RLS) Policy

All tenant-scoped tables enforce multi-tenant isolation via membership validation:

```sql
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenant isolation for invoices"
ON invoices
FOR ALL
USING (
    tenant_id IN (
        SELECT tenant_id FROM tenant_memberships
        WHERE user_id = auth.uid()
    )
);
```
