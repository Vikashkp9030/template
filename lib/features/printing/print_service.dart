import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../../core/errors/app_exception.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/printer/paper_size.dart';
import '../invoice_templates/invoice_template_type.dart';
import 'pdf_service.dart';

class InvoicePrintService {
  InvoicePrintService({PdfService? pdfService})
    : _pdf = pdfService ?? PdfService();

  final PdfService _pdf;

  Future<List<int>> generatePdf({
    required InvoiceModel invoice,
    required InvoiceTemplateType template,
    InvoicePaperSize paperSize = InvoicePaperSize.a4,
  }) {
    return _pdf.generateInvoice(
      invoice: invoice,
      template: template,
      paperSize: paperSize,
    );
  }

  static Future<void> printInvoice({
    required InvoiceModel invoice,
    required InvoiceTemplateType template,
    InvoicePaperSize paperSize = InvoicePaperSize.a4,
    PdfService? pdfService,
  }) async {
    try {
      final bytes = await (pdfService ?? PdfService()).generateInvoice(
        invoice: invoice,
        template: template,
        paperSize: paperSize,
      );
      await Printing.layoutPdf(
        onLayout: (_) async => Uint8List.fromList(bytes),
      );
    } catch (error) {
      throw PdfGenerationException('Print failed.', cause: error);
    }
  }

  static Future<void> sharePdf({
    required InvoiceModel invoice,
    required InvoiceTemplateType template,
    InvoicePaperSize paperSize = InvoicePaperSize.a4,
    PdfService? pdfService,
  }) async {
    final bytes = await (pdfService ?? PdfService()).generateInvoice(
      invoice: invoice,
      template: template,
      paperSize: paperSize,
    );
    await Printing.sharePdf(
      bytes: Uint8List.fromList(bytes),
      filename: '${invoice.number}.pdf',
    );
  }
}
