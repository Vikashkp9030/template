# Architecture

```text
Data (dummy YAML / import)
  → Models (InvoiceModel)
  → Business logic (InvoiceCalculator + TaxEngine)
  → Template renderer (registry)
  → Preview widgets
  → PDF / ESC/POS / printer adapters
```

UI widgets must not contain tax math, YAML parsing, or printer command generation.

## Layers

| Layer | Location | Responsibility |
| --- | --- | --- |
| App | `lib/app` | Theme, router, MaterialApp |
| Core | `lib/core` | Tokens, errors, calculator, tax strategies |
| Data | `lib/data` | Dummy documents, YAML loader/parser |
| Models | `lib/models` | Invoice, customer, company, printer config |
| Features | `lib/features` | Dashboard, templates, preview, printing, settings |
| Public API | `lib/invoice_template_preview.dart` | Stable exports for other apps |

## State

`flutter_riverpod` `PreviewController` holds the active invoice, template selection, paper sizes, and printer config.

## Tax

`TaxEngine` selects a strategy from `TaxRegime` (`gstIndia`, `vat`, `none`). Indian CGST/SGST/IGST is not hardcoded into `InvoiceModel`.
