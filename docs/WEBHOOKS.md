# Webhook Integration & Event Specifications

This document outlines the standard webhook events emitted and consumed across the multi-tenant SaaS billing and telemetry subsystems.

## Security & Signature Verification

All webhook payloads include cryptographic signature headers to ensure authenticity:
- Header: `X-ChromaMetrics-Signature`
- Payload Digest: HMAC-SHA256 computed over `${timestamp}.${raw_json_body}` using the tenant's webhook signing secret.
- Verification Tolerance: Payloads with timestamps deviating by more than 300 seconds are rejected to mitigate replay attacks.

## Event Catalog

| Event Name | Source | Description |
|:---|:---|:---|
| `invoice.created` | Billing Engine | Emitted when an invoice is generated and awaiting payment. |
| `invoice.paid` | Stripe / Supabase | Dispatched upon successful invoice settlement. |
| `invoice.payment_failed` | Stripe / Supabase | Dispatched on charge failure; initiates tenant grace period. |
| `subscription.created` | Billing Service | Emitted on initial checkout completion and plan activation. |
| `subscription.updated` | Billing Service | Fired on plan upgrades, seat adjustments, or term renewals. |
| `subscription.canceled` | Billing Service | Fired when churn or immediate cancellation is confirmed. |
| `usage.quota_exceeded` | Telemetry Stream | Fired when metered consumption reaches configured quota limits. |

## Delivery & Retry Policy

Webhook deliveries that return non-2xx HTTP responses or encounter network timeouts are re-queued with exponential backoff:
1. Immediate retry (attempt 1)
2. 5 minutes later (attempt 2)
3. 30 minutes later (attempt 3)
4. 2 hours later (attempt 4)
5. 24 hours later (attempt 5 - final DLQ transition)
