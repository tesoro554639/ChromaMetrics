# Multi-Tenant JWT Claims & Authentication Security

This document outlines the authentication lifecycle and cryptographic token requirements for multi-tenant tenancy verification in ChromaMetrics.

## Token Lifecycle

1. **Client Authentication**:
   - The user signs in via email/password or OAuth (Google / GitHub) against the Supabase Auth endpoint.
   - Supabase issues an ephemeral JWT access token (1-hour expiration) and an HTTP-only secure refresh token.

2. **Tenant Membership Validation**:
   - Client requests carry the JWT in the standard authorization header:
     ```http
     Authorization: Bearer <supabase_jwt>
     ```
   - PostgreSQL RLS verifies `auth.uid()` against the `tenant_memberships` table for every query.

3. **Client-Side Session Storage**:
   - Token persistence is handled natively by `Supabase.instance.client.auth` utilizing web local storage with AES encryption guards where available.
   - When running in Demo Mode, all token validation is short-circuited through in-memory session mocks to prevent unintended network requests.
