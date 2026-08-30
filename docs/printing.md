# Printing

## Invoice PDF

`PdfService` builds a multi-page PDF (A4 / A5 / Letter) with header, footer, page numbers, product table, tax summary, bank details, and terms. Accent color follows `InvoiceTemplateType`.

```dart
await InvoicePrintService.printInvoice(
  invoice: invoice,
  template: InvoiceTemplateType.professional,
  paperSize: InvoicePaperSize.a4,
);
```

## Thermal / ESC/POS

UI never talks to a Bluetooth plugin. It uses:

1. `EscPosReceiptBuilder` — receipt model → command list (text, bold, align, columns, divider, image, QR, barcode, feed, cut)
2. `EscPosEncoder` — commands → bytes
3. `ThermalPrinter` — hardware adapter

```dart
abstract class ThermalPrinter {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> printReceipt(InvoiceModel invoice);
}
```

`MockThermalPrinter` is the default. For a real device, implement the interface (Bluetooth / network :9100 / USB) and pass it into `ThermalPrintService`.

```dart
await ThermalPrintService.printReceipt(
  invoice: invoice,
  template: ThermalTemplateType.classic,
  paperSize: ThermalPaperSize.mm80,
);
```

Mock print UI shows render → ESC/POS → command generation, then success.
