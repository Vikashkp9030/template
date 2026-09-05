# Invoice Template Preview

Flutter studio for visually testing **invoice** and **thermal POS** templates before you integrate them into an ERP or POS app.

Package name: `invoice_template_preview`

## 1. How to run

```bash
flutter pub get
flutter run
```

Web:

```bash
flutter run -d chrome
```

macOS / Windows / Android / iOS are supported. Use light or dark system theme (Material 3).

## 2. How to add a new invoice template

1. Add a value to `InvoiceTemplateType`.
2. Implement `InvoiceTemplate` in `lib/features/invoice_templates/templates/`.
3. Register it in `InvoiceTemplateRegistry.templates`.
4. Reuse `InvoiceModel` and `InvoiceCalculator` — do not duplicate business logic in the widget.

## 3. How to add a new thermal template

1. Add a value to `ThermalTemplateType`.
2. Implement `ThermalTemplate`.
3. Register it in `ThermalTemplateRegistry.templates`.
4. Honor `ThermalPaperSize.mm58` and `mm80` (preview width and column density).

## 4. How to load YAML

- Dashboard → **Dummy Data / YAML Import**
- Load bundled assets (`assets/sample_invoice.yaml`, `sample_pos.yaml`, `sample_erp.yaml`)
- Paste YAML and tap **Parse YAML**
- Or import a `.yaml` / `.yml` file

The pipeline is:

`YAML → Map → InvoiceModel → selected template → preview → PDF / ESC/POS`

See [docs/yaml_data_contract.md](docs/yaml_data_contract.md).

## 5. Consume this repository from another Flutter app

**Git:**

```yaml
dependencies:
  invoice_template_preview:
    git:
      url: <repository-url>
      ref: main
```

**Path:**

```yaml
dependencies:
  invoice_template_preview:
    path: ../invoice_template_preview
```

Then:

```dart
import 'package:invoice_template_preview/invoice_template_preview.dart';

InvoicePreview(
  invoice: invoice,
  template: InvoiceTemplateType.basic,
);

ThermalPreview(
  invoice: invoice,
  template: ThermalTemplateType.thermal,
  paperSize: ThermalPaperSize.mm80,
);
```

Full details: [docs/integration.md](docs/integration.md).

## 6. How to generate PDF

From the invoice preview screen: **Download PDF**, **Preview PDF**, **Print PDF**, **Share**.

Programmatically:

```dart
await InvoicePrintService.printInvoice(
  invoice: invoice,
  template: InvoiceTemplateType.basic,
);
```

A4, A5, and Letter are supported with header, footer, page numbers, product table, tax summary, and terms.

## 7. How to integrate a real thermal printer

Implement `ThermalPrinter` (`connect`, `disconnect`, `printReceipt`) and inject it into `ThermalPrintService`. The ESC/POS layer already emits bytes for text, bold, alignment, columns, divider, image, QR, barcode, feed, and cut. See [docs/printing.md](docs/printing.md).

Until hardware is available, use **Mock Printer** in settings.

## 8. How to change paper size

- Invoice preview: A4 / A5 / Letter radio group (preview scales immediately).
- Thermal preview: 58mm / 80mm radio group.
- Settings: printer paper size for the mock/hardware adapter.

## 9. How the template registry works

Templates are looked up by enum in a map — no large `if/else` trees:

```dart
InvoiceTemplateRegistry.get(InvoiceTemplateType.basic);
ThermalTemplateRegistry.get(ThermalTemplateType.thermal);
```

## Architecture

See [docs/architecture.md](docs/architecture.md). Data, models, calculations, renderers, preview, and PDF/printer stay in separate layers.
