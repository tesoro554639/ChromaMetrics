# ADR 0009: Responsive Scaffolding and Multi-Form-Factor Strategy

## Status
Accepted

## Context
SaaS dashboards must render effectively across wide 4K desktop displays, standard laptops, tablets, and mobile viewport widths without layout breakage or component truncation.

## Decision
We implemented a breakpoint-driven adaptive scaffold architecture:
- `ResponsiveScaffold` uses `LayoutBuilder` to monitor maxWidth constraints.
- Viewports `>= 900px` render a persistent expanded sidebar navigation (`SidebarNavigation`).
- Viewports `< 900px` render an adaptive `AppBar` with drawer toggle to preserve screen real estate for charts and telemetry grids.
- High-density components (e.g. `TopNavBar`, `CustomerUsageGridScreen`) constrain text widths and collapse secondary labels via `TextOverflow.ellipsis`.

## Consequences
- Single unified codebase across mobile web, desktop web, and native desktop runtimes.
- Zero horizontal overflow exceptions on compact viewports.
