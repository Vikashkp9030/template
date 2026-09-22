# Business documents

Eight documents are rendered to PDF to match the reference files in
`context/` as closely as the renderer allows. Every measurement in the
templates was read off those PDFs — page size, cell widths, cell padding and
each text baseline — rather than estimated.

```text
DocumentModel (+ InvoiceModel)
  → InvoiceCalculator / TaxEngine        (shared with the on-screen templates)
  → DocumentPdfService
      → DocumentTemplateRegistry
          → one DocumentPdfTemplate per reference layout
              → shared sections + item table + page chrome
  → PDF bytes
```

## The eight templates

| Type | Reference | Page | Typeface |
| --- | --- | --- | --- |
| `creditNoteTemplate1` | `Credit_Note_Template1.pdf` | A4 bordered | Ubuntu |
| `creditNoteTemplate2` | `Credit_Note_Template2.pdf` | A4 | Ubuntu |
| `deliveryChallan` | `DC_Template1.pdf` | Letter | Ubuntu |
| `packagingSlip` | `Packging_Slip.pdf` | A4 | Times |
| `salesInvoiceTemplate1` | `Sales Invoice1.pdf` | A4 bordered | Ubuntu |
| `salesInvoiceTemplate2` | `Sales Invoice2.pdf` | Letter | Ubuntu |
| `salesReturn` | `Sales_Return_Template1.pdf` | A4 | Times |
| `salesOrder` | `SO_Template.pdf` | Letter | Ubuntu |

The references fall into two families. The **bordered** pair frames the whole
page, rules the header into boxes and grids the item table. The other six are
**spreadsheet** style: no frame, a dark bar over the item table and hairlines
between rows. `widgets/classic_sections.dart` and
`widgets/modern_sections.dart` hold what each family shares; the per-document
arrangement and its measurements stay in `templates/`.

## Page sizes

The references are not on the nominal paper sizes, so `DocumentGeometry`
carries the exact numbers:

| Geometry | Page | Content box |
| --- | --- | --- |
| `a4` | 595.42 × 841.69 | x 45.60 → 560.63 |
| `a4Bordered` | 595.42 × 841.69 | x 39.60 → 566.63 |
| `letter` | 612 × 792 | x 45.72 → 561.60 |

## Positioning by baseline

The renderer puts the first baseline of a text box `ascent × fontSize` below
the box's top edge and advances `(ascent − descent) × fontSize + lineSpacing`
per line. `DocumentSkin` exposes both, so a measurement taken off a reference
(always a baseline) turns directly into a layout constant:

- `PlacedBlock.text(baseline: …)` for the header area, which the references
  lay out at fixed coordinates.
- `BaselineBlock.text(baseline: …)` for everything under the item table, which
  has to flow when the table grows.
- `TextMeasure` wraps text with the real font so a block that can wrap still
  declares its true height, and the sections below it stay put.

A block that has nothing to print declares `visible: false` rather than being
left out of the list. `BaselineStack` still measures it, so the sections after
it keep the spacing the reference gives them and move up by exactly the room
it would have taken — an invoice with no notes closes up instead of leaving a
gap where they would have been.

## Adding or adjusting a template

1. Measure the reference. `DocumentSkin.baselineOffset` converts a baseline to
   a box top; cell padding is the gap between a column edge and the text.
2. Build the page from the shared sections, keeping the measurements in the
   template file.
3. Register it in `DocumentTemplateRegistry`.
4. Regenerate and compare:

   ```bash
   flutter test test/tools/generate_documents_test.dart   # build/documents/
   flutter test test/tools/generate_overflow_test.dart    # long item lists
   ```

## Known deviations from the references

These are renderer limits, not layout choices:

- **Amount in words.** The references oblique Ubuntu Bold and keep its widths;
  the bundled Ubuntu Bold Italic is a true italic and runs about 2% narrower,
  so that one line ends a couple of points short.
- **Line breaks inside a word.** The references were produced by an HTML
  engine, which will break after `/` and before `(`. The PDF renderer breaks
  at spaces only, so a long unspaced item name can wrap at a different
  character. Line counts, and therefore row heights, are unaffected.
- **Payment provider badge.** Sales invoices 1 and 2 print a payment
  provider's mark beside "Payment Options". It is a third-party asset, so the
  host supplies it via `DocumentModel.paymentOptionsLogo` and it is omitted
  when absent.
- **Hairlines.** A row rule lands within about 0.4pt of the reference, because
  the renderer strokes a row border centred on the row edge while the
  reference fills a rectangle below it.

## Quirks reproduced on purpose

The references are the source of truth, including where their arithmetic is
surprising:

- GST halves are labelled with the combined rate — `CGST (12.00%)` against a
  6% half. `TaxLabels` uses `TaxLineTotal.groupRate` for this.
- Payment retention is listed on an invoice but not deducted from the balance
  due; only the payment made is.
- A sales return shows the returned quantity but prices the line at the amount
  it was billed at, so `InvoiceItemModel.returnedQuantity` is display-only.
