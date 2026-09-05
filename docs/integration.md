# Integration

This project is both a runnable studio and a library.

## Option A — Git dependency

```yaml
dependencies:
  invoice_template_preview:
    git:
      url: <repository-url>
      ref: main
```

## Option B — Path dependency

```yaml
dependencies:
  invoice_template_preview:
    path: ../invoice_template_preview
```

If you copy the package into a monorepo, keep `lib/invoice_template_preview.dart` as the public barrel.

## Pass data from the host app

Build `InvoiceModel` in the host (from API, Hive, etc.) and render:

```dart
import 'package:invoice_template_preview/invoice_template_preview.dart';

class HostInvoicePage extends StatelessWidget {
  const HostInvoicePage({super.key, required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    return InvoiceTemplateRenderer(
      invoice: invoice,
      template: InvoiceTemplateType.basic,
      paperSize: InvoicePaperSize.a4,
    );
  }
}
```

Thermal:

```dart
ThermalPreview(
  invoice: invoice,
  template: ThermalTemplateType.thermal,
  paperSize: ThermalPaperSize.mm80,
);
```

Print:

```dart
await InvoicePrintService.printInvoice(
  invoice: invoice,
  template: InvoiceTemplateType.basic,
);

await ThermalPrintService.printReceipt(
  invoice: invoice,
  template: ThermalTemplateType.thermal,
  paperSize: ThermalPaperSize.mm80,
);
```

Host apps should depend on models + calculator + preview widgets, not on `DashboardPage`.
