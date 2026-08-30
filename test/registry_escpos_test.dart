import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/core/helpers/invoice_calculator.dart';
import 'package:invoice_template_preview/data/dummy/dummy_pos_data.dart';
import 'package:invoice_template_preview/features/invoice_templates/invoice_template_registry.dart';
import 'package:invoice_template_preview/features/invoice_templates/invoice_template_type.dart';
import 'package:invoice_template_preview/features/printing/esc_pos/esc_pos.dart';
import 'package:invoice_template_preview/features/printing/thermal_print_service.dart';
import 'package:invoice_template_preview/features/thermal_templates/thermal_template_registry.dart';
import 'package:invoice_template_preview/features/thermal_templates/thermal_template_type.dart';
import 'package:invoice_template_preview/models/printer/thermal_paper_size.dart';

void main() {
  test('invoice registry exposes six templates', () {
    expect(InvoiceTemplateRegistry.templates.keys, InvoiceTemplateType.values);
    for (final type in InvoiceTemplateType.values) {
      expect(InvoiceTemplateRegistry.get(type).type, type);
    }
  });

  test('thermal registry exposes two templates', () {
    expect(ThermalTemplateRegistry.templates.keys, ThermalTemplateType.values);
  });

  test('ESC/POS encoder emits initialize, commands, and cut', () {
    final invoice = DummyPosData.order();
    final result = ThermalPrintService().generate(
      invoice: invoice,
      template: ThermalTemplateType.classic,
      paperSize: ThermalPaperSize.mm80,
    );
    expect(result.commands.any((c) => c.kind == 'cut'), isTrue);
    expect(result.commands.any((c) => c.kind == 'qr'), isTrue);
    expect(result.commands.any((c) => c.kind == 'barcode'), isTrue);
    expect(result.bytes.first, 0x1B);
    expect(result.bytes[1], 0x40);
    expect(result.bytes.length, greaterThan(20));
  });

  test('receipt builder includes text and divider', () {
    final invoice = DummyPosData.order();
    final totals = InvoiceCalculator().calculate(invoice);
    final commands = const EscPosReceiptBuilder().build(
      invoice: invoice,
      totals: totals,
      paperSize: ThermalPaperSize.mm58,
    );
    expect(commands.any((c) => c.kind == 'text'), isTrue);
    expect(commands.any((c) => c.kind == 'divider'), isTrue);
  });
}
