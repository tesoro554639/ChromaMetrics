# Changelog

All notable changes to the ChromaMetrics project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.5] - 2026-10-25

### Added
- `formatRate` telemetry helper in `NumberFormatter` for calculating and formatting events per second/minute.
- `capitalize` and `maskApiKey` privacy helpers in `StringFormatter`.
- `isPastDue`, `isCanceled`, and `gracePeriodDaysRemaining` evaluation helpers in `TenantSubscription`.
- `hasStripeCustomer` and `copyWith` method in `Tenant` domain entity.
- Tenant provisioning and onboarding runbook (`docs/TENANT_ONBOARDING.md`).
- ADR 0012 documenting database connection pooling and failover architecture (`docs/adr/0012-db-connection-pooling-and-failover.md`).
- Multi-tiered API rate limiting and token bucket throttling documentation (`docs/RATE_LIMITING.md`).
- Comprehensive unit tests for `NumberFormatter.formatRate`, `StringFormatter.capitalize`, `StringFormatter.maskApiKey`, and `TenantSubscription.gracePeriodDaysRemaining`.

## [1.0.4] - 2026-10-22

### Added
- `cardTransparent` and `primaryGlow` design tokens to `AppColors` for dark theme depth.
- `formattedQuantity` helper in `CustomerUsage` domain model with unit symbol appending.
- `formatDuration` helper in `DateFormatter` for human-readable time spans.
- `annualSavingsPercent` calculation method in `SubscriptionPlan`.
- ADR 0011 documenting RBAC and permissions hierarchy (`docs/adr/0011-rbac-and-permissions-hierarchy.md`).
- Offline simulation troubleshooting guide (`docs/TROUBLESHOOTING.md`).
- Performance benchmarks and load testing documentation (`docs/BENCHMARKS.md`).
- Webhook integration specifications and event payload definitions (`docs/WEBHOOKS.md`).
- Unit test coverage for `CustomerUsage.formattedQuantity`, `DateFormatter.formatDuration`, and `SubscriptionPlan.annualSavingsPercent`.

## [1.0.3] - 2026-10-19

### Added
- `hasPositiveGrowth` and immutable `copyWith` methods to `SaasMetrics`.
- `netSubscribers` calculation and `copyWith` method to `RevenueTrendPoint`.
- `displayName` and `initials` extraction helpers to `AppUser`.
- `hasError` state evaluation property to `AppAuthState`.
- `formatDataVolume` storage telemetry converter (B, KB, MB, GB, TB) in `NumberFormatter`.
- ADR 0007 documenting the In-Memory Mock Repository pattern for offline Demo Mode.
- JWT multi-tenant token validation and security architecture specification (`docs/SECURITY_JWT.md`).

## [1.0.2] - 2026-10-18

### Added
- `NumberFormatter` utility for percentage delta formatting and compact metric notation.
- `showDot` indicator option in `StatusBadge` widget.
- `daysRemaining`, `isActive`, and `isTrialing` domain helpers in `TenantSubscription`.
- `isPaid`, `isOpen`, and `isVoid` domain helpers in `Invoice`.
- `isOwner`, `isAdminOrAbove`, and `isReadOnly` permission helpers in `TenantRole` & `TenantMembership`.
- `copyWith` method and `isActive` getter in `CustomerUsage` telemetry entity.
- Architecture Decision Records for PlutoGrid (ADR 0004), Row-Level Security (ADR 0005), and FL Chart (ADR 0006).
- Production web deployment guide (`docs/DEPLOYMENT_GUIDE.md`) and API metering ingestion spec (`docs/API_INTEGRATION.md`).

## [1.0.1] - 2026-10-17

### Added
- UTF-8 Byte Order Mark (BOM) in `CsvExporter` for seamless display in Microsoft Excel and spreadsheet tools.
- Asynchronous object URL revocation to prevent premature cancellation of web downloads.
- Relative elapsed time formatter (`DateFormatter.formatRelative`) with deterministic testing support.
- Configurable decimal precision in `CurrencyFormatter`.
- `hasSupabaseCredentials` and `isProduction` environment helpers in `EnvConfig`.
- Contributing guidelines, Code of Conduct, Security policy, and GitHub issue/PR templates.
- Architecture Decision Records (ADRs) for routing, state management, and PDF compilation.

### Fixed
- Customer usage CSV export now honors active grid filters and search queries.
- Top navigation bar profile avatar safely extracts initials without runtime range errors on empty strings.
- Added viewport constraints to top nav bar user info to prevent layout overflow on compact screens.
- Guarded `MetricCard` against rendering empty subtitle boxes.

## [1.0.0] - 2026-10-14

### Added
- Initial enterprise multi-tenant dashboard release.
- Riverpod 2.x state management with instant offline Demo Mode.
- Supabase PostgreSQL backend with Row-Level Security isolation.
- PlutoGrid telemetry grid with search, sorting, and CSV export.
- FL Chart MRR / ARR line charts and churn donut visualizer.
- Client-side vector PDF invoicing with in-browser print preview.
