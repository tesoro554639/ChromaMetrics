# ADR 0012: Database Connection Pooling and High Availability Failover

## Status
Accepted

## Context
High-concurrency tenant telemetry ingestion and real-time dashboard analytics demand resilient database connectivity without exhausting PostgreSQL connection limits during burst periods.

## Decision
We adopted Supavisor transaction-mode connection pooling paired with client-side exponential backoff and read-replica routing:
- **Transaction Pooling**: REST/PostgREST queries and Edge Functions connect via port 6543 (transaction pooling) to recycle database connections immediately upon statement completion.
- **Session Pooling**: Long-lived real-time websocket CDC subscriptions exclusively utilize port 5432 in session mode with TCP keepalive heartbeats.
- **Transient Failover**: Client SDKs implement exponential jitter backoff on HTTP 503/504 gateway timeouts up to 3 automatic retry attempts.
- **Statement Timeouts**: Strict 8-second statement timeouts protect the pool from runaway unindexed queries.

## Consequences
- Gracefully supports thousands of concurrent tenant queries without connection spikes.
- Direct schema DDL migrations must execute over direct session connections rather than transaction-pooled ports.
