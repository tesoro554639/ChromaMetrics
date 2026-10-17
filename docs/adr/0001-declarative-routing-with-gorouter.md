# ADR 0001: Declarative Routing with GoRouter

## Status
Accepted

## Context
ChromaMetrics is a multi-tenant SaaS application primarily deployed to Flutter Web. Web applications require direct URL bookmarking, deep-linking into specific tenant views, browser back/forward history navigation, and nested page layouts (such as persistent sidebar navigation).

## Decision
We adopted `go_router` (v14.x) as the centralized declarative routing solution with:
- Nested `ShellRoute` layouts wrapping standard application pages with the persistent responsive shell (`ResponsiveScaffold`).
- Authentication redirect guards listening to `authControllerProvider` to redirect unauthenticated sessions to `/login`.
- URL-synchronized tenant routes (e.g., `/dashboard`, `/usage`, `/billing`, `/invoices`).

## Consequences
- Clean URL synchronization with the browser address bar.
- Unified route constants defined centrally in `AppRoutes`.
- Full compatibility with Flutter Web compilation targets.
