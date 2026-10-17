# ADR 0002: State Management with Flutter Riverpod

## Status
Accepted

## Context
Multi-tenant architectures require reliable global state for:
- Current authenticated user and tenant session.
- Live switching of active tenant organizations.
- Cached billing and analytics queries with automatic disposal or invalidation.

## Decision
We chose `flutter_riverpod` (v2.x) for:
- Compile-time safety without `BuildContext` dependency for dependency injection.
- Unidirectional state flow with `StateNotifier` / `AsyncNotifier`.
- Automatic memoization and cache invalidation via `ref.invalidate(...)`.

## Consequences
- No runtime `ProviderNotFoundException`.
- Straightforward unit testing with mockable providers using `ProviderContainer`.
- Clean separation between presentation (`ConsumerWidget`) and business logic controllers.
