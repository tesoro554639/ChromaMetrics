# ADR 0008: Client-Side CSV Exporting & UTF-8 BOM Encoding

## Status
Accepted

## Context
Finance teams and system administrators need to export customer telemetry and usage records into spreadsheets. Often, opening CSV files in desktop tools like Microsoft Excel corrupts non-ASCII customer names, special punctuation, or international currency symbols if the character encoding is not explicitly signaled. Furthermore, client-side object URL generation on Web can experience download race conditions if the Blob URL is revoked prematurely.

## Decision
We implemented a robust client-side `CsvExporter` utility:
- **UTF-8 BOM Prepending**: Prepends `\uFEFF` (Byte Order Mark) to the CSV payload so spreadsheet applications reliably detect UTF-8 without user prompts.
- **Asynchronous Blob Revocation**: Uses a 2-second timeout before revoking the temporary object URL, ensuring browser download engines complete initialization.
- **Filter-Aware Grid Exporting**: When filters or search criteria are applied in `PlutoGrid`, `_exportGridToCsv` exports the currently visible/filtered rows rather than raw unfiltered cache.

## Consequences
- Error-free character rendering in Excel, Google Sheets, and LibreOffice.
- Reliable downloads across modern browser engines.
