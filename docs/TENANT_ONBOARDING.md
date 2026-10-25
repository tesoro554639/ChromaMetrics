# Tenant Provisioning & Onboarding Runbook

This guide describes the end-to-end lifecycle and automated provisioning workflows for newly onboarded SaaS tenants within ChromaMetrics.

## Provisioning Architecture

```
User Registration ──► Tenant Organization Created ──► Role & Membership Assigned
                              │
                              ▼
                     Default Quota Allocated
                              │
                              ▼
                 Stripe Customer & Setup Intent
                              │
                              ▼
                 Telemetry Ingestion Stream Activated
```

## Onboarding Sequence

### 1. Organization & Domain Verification
- Every tenant belongs to an isolated `organizations` record identified by a UUID v4 and a normalized URL-safe slug.
- Custom domain mappings (e.g. `analytics.tenant.com`) undergo automated DNS TXT token challenge verification prior to SSL issuance.

### 2. Role-Based Access Control (RBAC) Assignment
- The registering user is granted the `owner` role via `tenant_memberships`.
- Default security policies enforce multi-factor authentication (MFA) prompts for elevated administrative seats.

### 3. Usage Metering & Quotas
- Initial telemetry quotas are provisioned based on the default `Starter Tier`:
  - 10,000 monthly API calls
  - 2 active team seats
  - 5 GB monthly telemetry storage
- Exceeding 85% of allocated limits triggers outbound notification webhooks to tenant admins.

### 4. Billing & Stripe Customer Linking
- An idempotent Stripe customer object is minted via backend webhook/edge functions.
- Payment method setup intents are stored securely in PCI-compliant Stripe vaults; no raw credit card data touches ChromaMetrics infrastructure.
