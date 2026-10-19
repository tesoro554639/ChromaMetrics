# ADR 0007: In-Memory Mock Repository Architecture for Instant Demo Mode

## Status
Accepted

## Context
Prospective clients, internal evaluators, and automated integration suites require running the ChromaMetrics dashboard immediately without requiring live Supabase database credentials, Docker containers, or internet connectivity.

## Decision
We engineered an In-Memory Mock Repository abstraction layer:
- Repositories (`AnalyticsRepository`, `BillingRepository`, `TenantRepository`, `UsageRepository`) check `EnvConfig.isDemoMode`.
- When `isDemoMode` is active, the providers resolve deterministic in-memory fixtures simulating real-world SaaS operations (MRR trends, customer usage records, multiple organizations, invoices).
- When `isDemoMode` is false, repositories automatically delegate to real Supabase PostgreSQL endpoints using the initialized client.

## Consequences
- 100% zero-configuration onboarding: anyone can clone and immediately launch the web dashboard via `flutter run -d chrome`.
- Deterministic, resilient test suite execution without external network flakiness.
