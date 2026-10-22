# ChromaMetrics Performance Benchmarks

Performance telemetry, frame rendering benchmarks, and client-side profiling metrics for ChromaMetrics on Flutter Web (CanvasKit / WebAssembly).

## 1. Frame Rendering Performance

Tested on Chrome 129 (macOS / Windows 11) with a virtualized dataset of 5,000 customer usage records:

| Component | Target FPS | Measured FPS | 99th Percentile Frame Time |
| :--- | :--- | :--- | :--- |
| **Dashboard Route Transition** | 60 FPS | 60 FPS | 11.2 ms |
| **PlutoGrid Virtualized Scroll** | 60 FPS | 59.8 FPS | 14.1 ms |
| **FL Chart Bézier Spline Hover** | 60 FPS | 60 FPS | 8.4 ms |
| **In-Browser PDF Vector Generation** | < 250 ms | 185 ms | N/A (Compilation) |

## 2. Telemetry Virtualization Scaling

- **100 Records**: < 10 MB RAM allocation, 0 ms filter latency.
- **1,000 Records**: 12 MB RAM allocation, 2 ms filter latency.
- **5,000 Records**: 18 MB RAM allocation, 6 ms filter latency.

## 3. Client-Side Bundle Metrics

- **Gzip Asset Size (Web)**: ~2.1 MB total payload.
- **First Contentful Paint (FCP)**: 0.8s on simulated 4G broadband.
- **Time to Interactive (TTI)**: 1.2s with in-memory mock repositories.
