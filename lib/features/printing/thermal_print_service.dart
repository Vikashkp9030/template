import '../../core/errors/app_exception.dart';
import '../../core/helpers/invoice_calculator.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/printer/printer_config.dart';
import '../../models/printer/thermal_paper_size.dart';
import '../thermal_templates/thermal_template_type.dart';
import 'esc_pos/esc_pos.dart';
import 'esc_pos/thermal_printer.dart';

class ThermalPrintResult {
  const ThermalPrintResult({
    required this.commands,
    required this.bytes,
    required this.steps,
  });

  final List<EscPosCommand> commands;
  final List<int> bytes;
  final List<String> steps;
}

class ThermalPrintService {
  ThermalPrintService({
    InvoiceCalculator? calculator,
    EscPosReceiptBuilder? builder,
    EscPosEncoder? encoder,
    ThermalPrinter? printer,
  }) : _calculator = calculator ?? InvoiceCalculator(),
       _builder = builder ?? const EscPosReceiptBuilder(),
       _encoder = encoder ?? const EscPosEncoder(),
       printer = printer ?? MockThermalPrinter();

  final InvoiceCalculator _calculator;
  final EscPosReceiptBuilder _builder;
  final EscPosEncoder _encoder;
  final ThermalPrinter printer;

  ThermalPrintResult generate({
    required InvoiceModel invoice,
    required ThermalTemplateType template,
    required ThermalPaperSize paperSize,
    PrinterConfig? config,
  }) {
    final totals = _calculator.calculate(invoice);
    final commands = _builder.build(
      invoice: invoice,
      totals: totals,
      paperSize: paperSize,
    );
    final bytes = _encoder.encode(commands);
    final mock = printer;
    if (mock is MockThermalPrinter) {
      mock.storeBytes(bytes);
    }
    return ThermalPrintResult(
      commands: commands,
      bytes: bytes,
      steps: [
        'Template rendered ($template)',
        'Receipt converted to ESC/POS (${commands.length} commands)',
        'Printer command generated (${bytes.length} bytes)',
        if (config?.autoCut ?? true) 'Auto-cut queued',
        if (config?.openCashDrawer ?? false) 'Cash drawer pulse queued',
      ],
    );
  }

  static Future<ThermalPrintResult> printReceipt({
    required InvoiceModel invoice,
    required ThermalTemplateType template,
    ThermalPaperSize paperSize = ThermalPaperSize.mm80,
    PrinterConfig? config,
    ThermalPrintService? service,
  }) async {
    final printerService = service ?? ThermalPrintService();
    try {
      await printerService.printer.connect();
      final result = printerService.generate(
        invoice: invoice,
        template: template,
        paperSize: paperSize,
        config: config,
      );
      await printerService.printer.printReceipt(invoice);
      return result;
    } catch (error) {
      throw PrinterException(
        'Printer connection or print failed.',
        cause: error,
      );
    }
  }
}
