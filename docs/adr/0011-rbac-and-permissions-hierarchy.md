# ADR 0011: Role-Based Access Control (RBAC) and Permissions Hierarchy

## Status
Accepted

## Context
Enterprise organizations require granular authorization boundaries between organization owners, billing admins, team members, and external audit viewers to prevent unauthorized plan modifications or credential leakage.

## Decision
We defined an immutable 5-tier role hierarchy (`TenantRole`):
- **`Owner`**: Full tenant sovereignty, organization deletion, billing payment method mutations, and member invitation/removal.
- **`Admin`**: Workspace management, plan tier switching, team invitations, and telemetry view.
- **`BillingManager`**: Dedicated finance permissions: invoice downloads, payment method updates, and subscription renewals.
- **`Member`**: Operational workspace usage and API key provisioning within allocated plan quotas.
- **`Viewer`**: Strict read-only access for external accountants and auditors.

## Consequences
- Guarded UI routing and action controls driven by `TenantRole` extension getters (`canManageBilling`, `canManageMembers`, `isOwner`, `isAdminOrAbove`, `isReadOnly`).
- Replicated on PostgreSQL via RLS policy checks on `tenant_memberships.role`.
