# ADR 0003: Client-Side Vector PDF Invoice Generation

## Status
Accepted

## Context
Enterprise SaaS customers require immediate PDF invoices for accounting and financial compliance. Traditional architectures rely on headless browsers (Puppeteer) or backend workers to render PDFs, introducing latency, server operating costs, and failure points.

## Decision
We implement 100% client-side vector PDF generation using `pdf` (v3.x) and `printing` (v5.x):
- The browser compiles the PDF binary in-memory directly from invoice data models.
- Uses native vector rendering primitives for crisp typography, barcodes, and table grids at any resolution.
- Integrates with the browser's native print preview dialog via `Printing.layoutPdf(...)`.

## Consequences
- Zero backend server cost and zero rendering queue delays.
- Offline and instant invoice printing support.
- Fully functional in Demo Mode.
