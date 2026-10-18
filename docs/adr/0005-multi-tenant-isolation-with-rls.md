# ADR 0005: Multi-Tenant Data Isolation with PostgreSQL Row-Level Security

## Status
Accepted

## Context
In a B2B SaaS architecture, multi-tenant data leaks constitute a critical vulnerability. Application-level filtering (e.g. `WHERE tenant_id = ?` in every ORM call) is prone to developer oversight and regression risks.

## Decision
We enforce multi-tenancy at the PostgreSQL storage engine layer using Supabase Row-Level Security (RLS):
- Every tenant resource (`invoices`, `subscriptions`, `customer_usage`, `audit_logs`) has RLS enabled.
- The PostgreSQL policies inspect JWT claims and query the `tenant_memberships` table for authorization against `auth.uid()`.
- API keys used by the frontend web client are restricted `anon` public keys which cannot bypass RLS.

## Consequences
- Guaranteed zero cross-tenant data contamination even if application query filters are omitted.
- Auditable security boundary directly declared in database migrations.
