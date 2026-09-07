# Invoice templates

Three templates consume the same `InvoiceModel` and `InvoiceTotals`: `BasicInvoiceTemplate`,
`EnterpriseInvoiceTemplate`, and `PremiumInvoiceTemplate`.

| `InvoiceTemplateType` | User-facing name | Look |
| --- | --- | --- |
| `basic` | Basic | Minimal, restrained — no color blocks, divider-based table. |
| `standard` | **Enterprise** | Corporate header band, accent-bordered info cards, filled table header. |
| `premium` | Premium | Dark grand-total card, gold/violet accent, decorative corner, refined type scale. |

`standard` is the stable internal/data-contract identifier (used by `template: standard` in
YAML documents and this package's public exports) — it is presented to users as **Enterprise**.
`InvoiceTemplateTypeX.parse()` accepts both `'standard'` and `'enterprise'`.

Register new templates in `InvoiceTemplateRegistry`.

## Single source of truth

Every template's colors, spacing, and typography come from one place:
`lib/features/invoice_templates/theme/invoice_template_theme.dart` defines
`InvoiceTemplateThemes.basic/enterprise/premium`. Both renderers read the same theme instance:

- The Flutter widget templates (`lib/features/invoice_templates/templates/*.dart`), composed
  from shared section widgets in `lib/features/invoice_templates/widgets/` (header, party info,
  items table, totals, notes/terms, signature, footer).
- The PDF renderer (`lib/features/printing/pdf_service.dart`), via the `pw`-style mapping
  extensions in `invoice_template_theme_pdf_x.dart`.

`Widget` (Flutter) and `pw.Widget` (the `pdf` package) are different widget systems and can't
literally share render code, but sharing the token values means a color or spacing change only
needs to happen once, and the two can't silently drift the way hand-duplicated hex/px values
used to.

## Preview vs. PDF

`InvoicePreviewPage` shows two interchangeable views of the same data:

- **PDF Preview** (default) — the actual bytes `PdfService.generateInvoice()` produces, shown
  inline via `package:printing`'s `PdfPreview`. This is byte-identical to the downloaded PDF:
  correct multi-page flow, repeating table headers, and a running footer with page numbers.
- **Live Template** — the fast Flutter-widget render, panned/zoomed via `InteractiveViewer`
  instead of being cropped to a single page height, so long documents stay fully visible.
