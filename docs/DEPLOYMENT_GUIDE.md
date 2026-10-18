# ChromaMetrics Deployment Guide

This guide details how to build and deploy ChromaMetrics to production web environments (e.g., GitHub Pages, Cloudflare Pages, Vercel, Firebase Hosting).

## 1. Prerequisites

- Flutter SDK `3.47+` installed and on system PATH.
- Chrome or Edge for local web testing.
- Target Supabase and Stripe accounts.

## 2. Production Web Build

Run the optimized production release command:

```bash
flutter build web --release --wasm
```

> **Note**: If your hosting platform does not support required cross-origin isolation headers for WebAssembly (`Cross-Origin-Embedder-Policy: credentialless` and `Cross-Origin-Opener-Policy: same-origin`), build with the HTML/CanvasKit renderer:
> ```bash
> flutter build web --release --web-renderer canvaskit
> ```

## 3. Injecting Environment Variables

Supply your production credentials at build time:

```bash
flutter build web --release \
  --dart-define=DEMO_MODE=false \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-production-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_your_key
```

## 4. Deploying to GitHub Pages

1. Build the web output:
   ```bash
   flutter build web --release --base-href "/ChromaMetrics/"
   ```
2. Publish `build/web` to your repository's `gh-pages` branch.
