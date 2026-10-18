# ChromaMetrics Telemetry & Metered Billing Ingestion Specification

This document outlines the ingestion format and schema contract for reporting metered customer usage events into ChromaMetrics.

## Ingestion Endpoint

```http
POST /functions/v1/ingest-usage
Authorization: Bearer <tenant_ingest_key>
Content-Type: application/json
```

## Payload Schema

```json
{
  "tenant_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "events": [
    {
      "user_id": "usr_99881",
      "user_email": "engineer@clientcompany.io",
      "user_name": "Jordan Smith",
      "meter_key": "meter_api_calls",
      "quantity": 250,
      "unit": "requests",
      "timestamp": "2026-10-18T12:30:00Z"
    }
  ]
}
```

## Meter Keys & Pricing Rules

| Meter Key | Display Name | Unit | Aggregation Window | Default Tier Included |
| :--- | :--- | :--- | :--- | :--- |
| `meter_api_calls` | API Requests | requests | Monthly Sum | 10,000 / mo |
| `meter_storage_gb` | Cloud Storage | GB | Daily Gauge Max | 50 GB |
| `meter_active_seats`| Member Seats | seats | Active Count | 5 seats |

## Error Responses

- `401 Unauthorized`: Invalid or expired tenant ingestion key.
- `422 Unprocessable Entity`: Missing required schema field (`meter_key`, `quantity`).
- `429 Too Many Requests`: Rate limit threshold exceeded.
