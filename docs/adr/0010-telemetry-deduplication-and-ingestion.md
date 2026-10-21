# ADR 0010: Telemetry Event Deduplication and Idempotent Ingestion

## Status
Accepted

## Context
Metered usage ingestion from distributed client microservices and API gateways can experience network retries, causing duplicate billing events if idempotency is not enforced.

## Decision
We enforce idempotent ingestion through:
- Event-level idempotency keys composed of `sha256(tenant_id + meter_key + user_id + timestamp_bucket)`.
- PostgreSQL unique constraint indexes on the telemetry ingestion tables.
- Batch upserts using `ON CONFLICT (idempotency_key) DO NOTHING` in Supabase Edge Functions.

## Consequences
- Guaranteed zero double-billing for client-side automated retries.
- Predictable and auditable usage calculations for invoices.
