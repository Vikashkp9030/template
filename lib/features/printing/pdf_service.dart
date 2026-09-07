import 'dart:ui' show Size;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/errors/app_exception.dart';
import '../../core/helpers/invoice_calculator.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/printer/paper_size.dart';
import '../invoice_templates/invoice_template_registry.dart';
import '../invoice_templates/invoice_template_type.dart';
import 'widget_rasterizer.dart';

/// Renders invoices to PDF from the very same template widgets the on-screen
/// preview shows — one rasterized image per page. There is no second layout
/// implementation, so the PDF cannot drift from what the preview displays.
class PdfService {
  PdfService({InvoiceCalculator? calculator, WidgetRasterizer? rasterizer})
    : _calculator = calculator ?? InvoiceCalculator(),
      _rasterizer = rasterizer ?? const WidgetRasterizer();

  final InvoiceCalculator _calculator;
  final WidgetRasterizer _rasterizer;

  /// 3x the ~96dpi logical page, i.e. roughly 288dpi in the output.
  static const double _pixelRatio = 3.0;

  Future<List<int>> generateInvoice({
    required InvoiceModel invoice,
    required InvoiceTemplateType template,
    InvoicePaperSize paperSize = InvoicePaperSize.a4,
  }) async {
    try {
      final totals = _calculator.calculate(invoice);
      final pages = InvoiceTemplateRegistry.get(template).buildPages(
        invoice: invoice,
        totals: totals,
        paperSize: paperSize,
      );

      final format = switch (paperSize) {
        InvoicePaperSize.a4 => PdfPageFormat.a4,
        InvoicePaperSize.a5 => PdfPageFormat.a5,
        InvoicePaperSize.letter => PdfPageFormat.letter,
      };

      final doc = pw.Document();

      for (final page in pages) {
        final png = await _rasterizer.rasterize(
          widget: page,
          logicalSize: Size(paperSize.width, paperSize.height),
          pixelRatio: _pixelRatio,
        );

        final image = pw.MemoryImage(png);
        doc.addPage(
          pw.Page(
            pageFormat: format,
            margin: pw.EdgeInsets.zero,
            build: (_) => pw.Image(image, fit: pw.BoxFit.fill),
          ),
        );
      }

      return await doc.save();
    } catch (error) {
      throw PdfGenerationException('Unable to generate PDF.', cause: error);
    }
  }
}
