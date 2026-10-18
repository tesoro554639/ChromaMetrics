# ADR 0006: Interactive SaaS Metrics Visualizations with FL Chart

## Status
Accepted

## Context
Executive metrics like Monthly Recurring Revenue (MRR), Annual Recurring Revenue (ARR), and Churn require interactive visual inspection. Dashboards need smooth Bézier curves, dynamic touch/pointer inspection tooltips, and radial churn distribution gauges without heavy third-party JavaScript canvas interop.

## Decision
We implemented native Flutter visualizations using `fl_chart` (v0.68.x):
- **MRR Revenue Trend**: Multi-point `LineChart` using cubic Bézier splines (`isCurved: true`), below-bar gradient shaders, and custom touch tooltips displaying formatted USD metrics.
- **User Churn Breakdown**: `PieChart` radial donut gauge visualizing subscriber retention vs. voluntary/involuntary churn with badge labels.

## Consequences
- Hardware-accelerated canvas rendering in both CanvasKit and WebAssembly compilation modes.
- Reactive chart redraws driven by Riverpod `AsyncValue` updates.
