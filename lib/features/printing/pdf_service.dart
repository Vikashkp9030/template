import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/errors/app_exception.dart';
import '../../core/helpers/invoice_calculator.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/money_formatter.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/printer/paper_size.dart';
import '../invoice_templates/invoice_template_type.dart';

class PdfService {
  PdfService({InvoiceCalculator? calculator})
    : _calculator = calculator ?? InvoiceCalculator();

  final InvoiceCalculator _calculator;

  Future<List<int>> generateInvoice({
    required InvoiceModel invoice,
    required InvoiceTemplateType template,
    InvoicePaperSize paperSize = InvoicePaperSize.a4,
  }) async {
    try {
      final totals = _calculator.calculate(invoice);
      final doc = pw.Document();
      final format = switch (paperSize) {
        InvoicePaperSize.a4 => PdfPageFormat.a4,
        InvoicePaperSize.a5 => PdfPageFormat.a5,
        InvoicePaperSize.letter => PdfPageFormat.letter,
      };
      final accent = _accent(template);

      doc.addPage(
        pw.MultiPage(
          pageFormat: format,
          header: (context) => pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 1)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  invoice.company.name,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: accent,
                  ),
                ),
                pw.Text('${template.title} · ${invoice.number}'),
              ],
            ),
          ),
          footer: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(invoice.terms ?? invoice.notes ?? ''),
              pw.Text('Page ${context.pageNumber} / ${context.pagesCount}'),
            ],
          ),
          build: (context) => [
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill to',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(invoice.customer.name),
                      if (invoice.customer.gstin != null)
                        pw.Text('GSTIN: ${invoice.customer.gstin}'),
                      if (invoice.customer.billingAddress != null)
                        pw.Text(invoice.customer.billingAddress!.singleLine),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Date: ${DateFormatter.display(invoice.date)}'),
                    if (invoice.dueDate != null)
                      pw.Text(
                        'Due: ${DateFormatter.display(invoice.dueDate!)}',
                      ),
                    if (invoice.placeOfSupply != null)
                      pw.Text('Place of supply: ${invoice.placeOfSupply}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: const [
                'SKU',
                'Item',
                'Qty',
                'Price',
                'Disc',
                'Tax',
                'Total',
              ],
              data: [
                for (final line in totals.lines)
                  [
                    line.sku,
                    line.name,
                    MoneyFormatter.plain(line.quantity),
                    MoneyFormatter.plain(line.unitPrice),
                    MoneyFormatter.plain(line.discount),
                    '${line.taxRate.toStringAsFixed(0)}%',
                    MoneyFormatter.plain(line.lineTotal),
                  ],
              ],
              headerDecoration: pw.BoxDecoration(color: accent),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Tax summary',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      for (final tax in totals.taxLines)
                        pw.Text(
                          '${tax.label}: ${MoneyFormatter.plain(tax.amount)}',
                        ),
                      if (invoice.bank != null) ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Bank ${invoice.bank!.bankName}  ${invoice.bank!.accountNumber}',
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(
                  width: 180,
                  child: pw.Column(
                    children: [
                      _pdfAmount('Subtotal', totals.subtotal, invoice.currency),
                      _pdfAmount('Discount', totals.discount, invoice.currency),
                      _pdfAmount('Tax', totals.tax, invoice.currency),
                      _pdfAmount(
                        'Grand total',
                        totals.grandTotal,
                        invoice.currency,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      return await doc.save();
    } catch (error) {
      throw PdfGenerationException('Unable to generate PDF.', cause: error);
    }
  }

  PdfColor _accent(InvoiceTemplateType type) {
    return switch (type) {
      InvoiceTemplateType.professional => PdfColor.fromInt(0xFF1E3A5F),
      InvoiceTemplateType.modern => PdfColor.fromInt(0xFF0D9488),
      InvoiceTemplateType.gst => PdfColor.fromInt(0xFF1D4ED8),
      InvoiceTemplateType.retail => PdfColor.fromInt(0xFFEA580C),
      InvoiceTemplateType.premium => PdfColor.fromInt(0xFF111827),
      InvoiceTemplateType.compact => PdfColor.fromInt(0xFF1F2937),
    };
  }

  pw.Widget _pdfAmount(
    String label,
    num value,
    String currency, {
    bool bold = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          MoneyFormatter.plain(value),
          style: pw.TextStyle(
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
