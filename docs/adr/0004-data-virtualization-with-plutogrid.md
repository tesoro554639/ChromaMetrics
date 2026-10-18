# ADR 0004: Telemetry Data Virtualization with PlutoGrid

## Status
Accepted

## Context
High-volume SaaS telemetry and customer usage events generate thousands of rows. Standard Flutter `DataTable` or `ListView` widgets instantiate too many element nodes simultaneously, degrading frame rates and creating perceptible UI jank during scrolling and filtering.

## Decision
We adopted `pluto_grid` (v8.x) as the virtualized data grid engine:
- Employs viewport row and column virtualization to maintain fixed 60fps rendering regardless of dataset scale.
- Native keyboard navigation, cell selection, column reordering, and multi-column sorting.
- Custom cell renderers for `StatusBadge` and formatted date/time columns.
- State-managed programmatic filtering (`setFilter`) mapped to search and status chip inputs.

## Consequences
- Fluid rendering for high-density telemetry records.
- Built-in CSV export and selected row retrieval via `PlutoGridStateManager`.
