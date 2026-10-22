# ChromaMetrics Troubleshooting Guide

Common issues encountered when running or building ChromaMetrics locally and how to resolve them.

## 1. Web Port Binding & Cross-Origin Isolation
If web fonts, chart shaders, or local print dialogs fail to open:
- Ensure Flutter Web runs with `--web-port=3000` or higher:
  ```bash
  flutter run -d chrome --web-port=3000
  ```
- In Chrome / Edge, verify that popups and print previews are allowed for `localhost`.

## 2. In-Memory Demo Mode vs. Live Supabase Backend
If dashboard metrics display mock figures instead of live data:
- Check `EnvConfig.isDemoMode` in `lib/core/config/env_config.dart`.
- By default `DEMO_MODE=true` is enabled to allow zero-config evaluation without backend requirements.
- To connect a live Supabase project, supply credentials at launch:
  ```bash
  flutter run -d chrome \
    --dart-define=DEMO_MODE=false \
    --dart-define=SUPABASE_URL=https://your-id.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=your-anon-key
  ```

## 3. CSV File Download In Browsers
If CSV downloads do not trigger in web browsers:
- Ensure browser popup blockers do not block automatic download triggers.
- The built-in `CsvExporter` utility waits 2 seconds before revoking the temporary Object URL, ensuring modern browser download managers have ample time to stream the Blob.
