# Rate Limiting & Throttling Architecture

This specification outlines the multi-tiered rate limiting strategies deployed to safeguard ChromaMetrics API endpoints and protect backend database clusters from abusive consumption spikes.

## Architecture Overview

```
Client Ingestion Request
         │
         ▼
[API Gateway Edge Worker] ──► Inspect Tenant JWT / API Key
         │
         ▼
[Redis Token Bucket Check]
    ├── Within Limit  ──► Forward to Telemetry Pipeline
    └── Quota Exceeded ──► Return HTTP 429 Too Many Requests
```

## Rate Limiting Tiers

| Tier Name | Requests / Minute | Burst Capacity | Concurrent Streams |
|:---|:---:|:---:|:---:|
| **Starter** | 600 req/min | 50 req | 5 |
| **Pro** | 6,000 req/min | 500 req | 25 |
| **Enterprise** | 60,000 req/min | 2,500 req | Unlimited |

## Response Headers on Throttled Requests

When a tenant exceeds their allotted tier bucket, the Edge gateway immediately responds with HTTP status `429 Too Many Requests` containing standard IETF rate limiting headers:

```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json
Retry-After: 30
X-RateLimit-Limit: 6000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1761400000

{
  "error": "rate_limit_exceeded",
  "message": "Tier request rate exceeded. Please retry after 30 seconds or upgrade your subscription plan.",
  "tier": "pro",
  "retry_after_seconds": 30
}
```
