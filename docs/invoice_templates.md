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

There is exactly one layout implementation per template. Each template implements
`InvoiceTemplate.buildPages()`, returning one widget per printed page, each sized to fill the
selected `InvoicePaperSize`. Both outputs consume that same list:

- **On screen** — `InvoiceTemplate.build()` (the default in the base class) stacks the pages
  with a gap between them.
- **In the PDF** — `PdfService.generateInvoice()` rasterizes each page widget through
  `WidgetRasterizer` (`lib/features/printing/widget_rasterizer.dart`) and places the resulting
  image on a PDF page.

Colors, spacing, and typography still come from
`lib/features/invoice_templates/theme/invoice_template_theme.dart`
(`InvoiceTemplateThemes.basic/enterprise/premium`).

Because the PDF is a render of the same widgets, the two cannot drift: a template change shows
up in both, and there is no second `pw.Widget` tree to keep in sync. The tradeoff is that PDF
text is rasterized rather than selectable.

`WidgetRasterizer` builds the page in its own `PipelineOwner`/`BuildOwner`, so it does not need
the widget to be mounted in the running app.

## Preview vs. PDF

`InvoicePreviewPage` shows two interchangeable views of the same data:

- **PDF Preview** (default) — the actual bytes `PdfService.generateInvoice()` produces, shown
  inline via `package:printing`'s `PdfPreview`. Byte-identical to what "Download PDF" saves.
- **Live Template** — the same page widgets rendered directly by Flutter, panned/zoomed via
  `InteractiveViewer` so long documents stay fully visible.
