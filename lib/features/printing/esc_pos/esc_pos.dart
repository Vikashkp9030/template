import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/thermal_paper_size.dart';

enum EscPosAlign { left, center, right }

class EscPosCommand {
  const EscPosCommand._(
    this.kind, {
    this.text,
    this.enabled,
    this.align,
    this.columns,
    this.lines,
    this.payload,
  });

  final String kind;
  final String? text;
  final bool? enabled;
  final EscPosAlign? align;
  final List<String>? columns;
  final int? lines;
  final String? payload;

  factory EscPosCommand.text(String text) =>
      EscPosCommand._('text', text: text);
  factory EscPosCommand.bold(bool enabled) =>
      EscPosCommand._('bold', enabled: enabled);
  factory EscPosCommand.alignment(EscPosAlign align) =>
      EscPosCommand._('align', align: align);
  factory EscPosCommand.columns(List<String> columns) =>
      EscPosCommand._('columns', columns: columns);
  factory EscPosCommand.divider() => const EscPosCommand._('divider');
  factory EscPosCommand.image({String payload = 'logo'}) =>
      EscPosCommand._('image', payload: payload);
  factory EscPosCommand.qr(String data) => EscPosCommand._('qr', payload: data);
  factory EscPosCommand.barcode(String data) =>
      EscPosCommand._('barcode', payload: data);
  factory EscPosCommand.feed([int lines = 1]) =>
      EscPosCommand._('feed', lines: lines);
  factory EscPosCommand.cut() => const EscPosCommand._('cut');
}

class EscPosReceiptBuilder {
  const EscPosReceiptBuilder();

  List<EscPosCommand> build({
    required InvoiceModel invoice,
    required InvoiceTotals totals,
    required ThermalPaperSize paperSize,
  }) {
    final width = paperSize.charactersPerLine;
    return [
      EscPosCommand.alignment(EscPosAlign.center),
      EscPosCommand.bold(true),
      EscPosCommand.text(invoice.company.name),
      EscPosCommand.bold(false),
      EscPosCommand.text(invoice.company.address.line1),
      EscPosCommand.text(invoice.company.phone),
      if (invoice.company.gstin != null)
        EscPosCommand.text('GSTIN: ${invoice.company.gstin}'),
      EscPosCommand.divider(),
      EscPosCommand.alignment(EscPosAlign.left),
      EscPosCommand.text('Invoice: ${invoice.number}'),
      EscPosCommand.text('Date: ${invoice.date.toIso8601String()}'),
      if (invoice.cashier != null)
        EscPosCommand.text('Cashier: ${invoice.cashier}'),
      EscPosCommand.divider(),
      EscPosCommand.columns(const ['Item', 'Qty', 'Price']),
      EscPosCommand.divider(),
      for (final line in totals.lines)
        EscPosCommand.columns([
          line.name,
          line.quantity.toStringAsFixed(0),
          line.lineTotal.toStringAsFixed(2),
        ]),
      EscPosCommand.divider(),
      EscPosCommand.columns([
        'Subtotal',
        '',
        totals.subtotal.toStringAsFixed(2),
      ]),
      EscPosCommand.columns([
        'Discount',
        '',
        totals.discount.toStringAsFixed(2),
      ]),
      EscPosCommand.columns(['Tax', '', totals.tax.toStringAsFixed(2)]),
      EscPosCommand.bold(true),
      EscPosCommand.columns([
        'TOTAL',
        '',
        totals.grandTotal.toStringAsFixed(2),
      ]),
      EscPosCommand.bold(false),
      EscPosCommand.divider(),
      EscPosCommand.text('Payment: ${invoice.payment.method}'),
      EscPosCommand.qr(invoice.number),
      EscPosCommand.barcode(invoice.number),
      EscPosCommand.alignment(EscPosAlign.center),
      EscPosCommand.text('Thank You'),
      EscPosCommand.feed(2),
      EscPosCommand.cut(),
      EscPosCommand.text('width=$width'),
    ];
  }
}

class EscPosEncoder {
  const EscPosEncoder();

  static const esc = 0x1B;
  static const gs = 0x1D;

  List<int> encode(List<EscPosCommand> commands) {
    final bytes = <int>[esc, 0x40]; // initialize
    for (final command in commands) {
      switch (command.kind) {
        case 'align':
          final n = switch (command.align) {
            EscPosAlign.left => 0,
            EscPosAlign.center => 1,
            EscPosAlign.right => 2,
            null => 0,
          };
          bytes.addAll([esc, 0x61, n]);
        case 'bold':
          bytes.addAll([esc, 0x45, command.enabled == true ? 1 : 0]);
        case 'text':
          bytes.addAll(command.text!.codeUnits);
          bytes.add(0x0A);
        case 'columns':
          bytes.addAll((command.columns ?? const []).join('  ').codeUnits);
          bytes.add(0x0A);
        case 'divider':
          bytes.addAll(List.filled(32, 0x2D));
          bytes.add(0x0A);
        case 'image':
          bytes.addAll('IMG:${command.payload}'.codeUnits);
          bytes.add(0x0A);
        case 'qr':
          bytes.addAll([gs, 0x28, 0x6B]);
          bytes.addAll('QR:${command.payload}'.codeUnits);
          bytes.add(0x0A);
        case 'barcode':
          bytes.addAll([gs, 0x6B, 0x49]);
          bytes.addAll(command.payload!.codeUnits);
          bytes.add(0x0A);
        case 'feed':
          bytes.addAll([esc, 0x64, command.lines ?? 1]);
        case 'cut':
          bytes.addAll([gs, 0x56, 0x41, 0x00]);
      }
    }
    return bytes;
  }
}
