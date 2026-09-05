import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/errors/app_exception.dart';
import '../../core/helpers/invoice_calculator.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/money_formatter.dart';
import '../../models/invoice/company_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/invoice_totals.dart';
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

      doc.addPage(
        pw.MultiPage(
          pageFormat: format,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => switch (template) {
            InvoiceTemplateType.basic => _buildBasic(invoice, totals),
            InvoiceTemplateType.standard => _buildStandard(invoice, totals),
            InvoiceTemplateType.premium => _buildPremium(invoice, totals),
          },
        ),
      );
      return await doc.save();
    } catch (error) {
      throw PdfGenerationException('Unable to generate PDF.', cause: error);
    }
  }

  List<pw.Widget> _buildBasic(InvoiceModel invoice, InvoiceTotals totals) {
    final textStyle = pw.TextStyle(color: PdfColor.fromInt(0xFF111827), fontSize: 12);
    final labelStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey);

    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                invoice.documentTitle.toUpperCase(),
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.normal, letterSpacing: 2.0),
              ),
              pw.SizedBox(height: 8),
              pw.Text('${invoice.numberLabel} ${invoice.number}', style: const pw.TextStyle(color: PdfColors.grey)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('DATE', style: labelStyle),
              pw.Text(DateFormatter.display(invoice.date), style: textStyle),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 48),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('FROM', style: labelStyle),
                pw.SizedBox(height: 4),
                pw.Text(invoice.company.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text(invoice.company.address.singleLine, style: textStyle),
                pw.Text('Phone: ${invoice.company.phone}', style: textStyle),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('BILL TO', style: labelStyle),
                pw.SizedBox(height: 4),
                pw.Text(invoice.customer.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                if (invoice.customer.billingAddress != null)
                  pw.Text(invoice.customer.billingAddress!.singleLine, style: textStyle),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 48),
      pw.TableHelper.fromTextArray(
        headers: ['Item', 'Qty', 'Price', 'Total'],
        data: [
          for (final item in totals.lines)
            [
              item.name,
              MoneyFormatter.plain(item.quantity),
              MoneyFormatter.format(item.unitPrice, currency: invoice.currency),
              MoneyFormatter.format(item.lineTotal, currency: invoice.currency),
            ],
        ],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey),
        headerDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE5E7EB), width: 1.5)),
        ),
        cellStyle: textStyle,
        cellAlignment: pw.Alignment.centerLeft,
        cellAlignments: {3: pw.Alignment.centerRight},
        border: null,
        headerAlignment: pw.Alignment.centerLeft,
        cellPadding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      ),
      pw.SizedBox(height: 16),
      pw.Divider(color: PdfColor.fromInt(0xFFE5E7EB)),
      pw.SizedBox(height: 16),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.SizedBox(
          width: 220,
          child: _pdfAmount('Grand Total', totals.grandTotal, invoice.currency, bold: true),
        ),
      ),
    ];
  }

  List<pw.Widget> _buildStandard(InvoiceModel invoice, InvoiceTotals totals) {
    final accentColor = PdfColor.fromInt(0xFF2563EB);
    final textStyle = pw.TextStyle(color: PdfColor.fromInt(0xFF374151), fontSize: 11);

    return [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _pdfLogoMark(invoice.company, size: 64, background: accentColor),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  invoice.company.name,
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF111827)),
                ),
                pw.Text(invoice.company.address.singleLine, style: textStyle),
                pw.Text('Tel: ${invoice.company.phone} | ${invoice.company.email}', style: textStyle),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0x0D2563EB), // 5% opacity
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  invoice.documentTitle,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: accentColor, letterSpacing: 1.0),
                ),
                pw.Text('${invoice.numberLabel} ${invoice.number}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 32),
      pw.Row(
        children: [
          pw.Expanded(
            child: _pdfStandardInfoBox('Bill To', [
              invoice.customer.name,
              if (invoice.customer.billingAddress != null)
                invoice.customer.billingAddress!.singleLine,
              if (invoice.customer.phone != null) 'Phone: ${invoice.customer.phone}',
            ], accentColor),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: _pdfStandardInfoBox('Details', [
              'Date: ${DateFormatter.display(invoice.date)}',
              'Method: ${invoice.payment.method}',
              'Status: ${invoice.payment.status}',
            ], accentColor),
          ),
        ],
      ),
      pw.SizedBox(height: 32),
      pw.TableHelper.fromTextArray(
        headers: ['Description', 'Qty', 'Unit Price', 'Amount'],
        data: [
          for (final item in totals.lines)
            [
              item.name,
              MoneyFormatter.plain(item.quantity),
              MoneyFormatter.format(item.unitPrice, currency: invoice.currency),
              MoneyFormatter.format(item.lineTotal, currency: invoice.currency),
            ],
        ],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
        headerDecoration: pw.BoxDecoration(color: accentColor),
        cellStyle: textStyle,
        cellAlignment: pw.Alignment.centerLeft,
        cellAlignments: {3: pw.Alignment.centerRight},
        cellPadding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        border: const pw.TableBorder(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      pw.SizedBox(height: 24),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (invoice.terms != null) ...[
                  pw.Text('TERMS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey)),
                  pw.SizedBox(height: 4),
                  pw.Text(invoice.terms!, style: const pw.TextStyle(fontSize: 10)),
                ],
              ],
            ),
          ),
          pw.SizedBox(
            width: 240,
            child: pw.Column(
              children: [
                _pdfAmount('Subtotal', totals.subtotal, invoice.currency),
                _pdfAmount('Tax', totals.tax, invoice.currency),
                pw.Divider(thickness: 1.5, height: 24),
                _pdfAmount('Grand Total', totals.grandTotal, invoice.currency, bold: true),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 40),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Column(
          children: [
            pw.SizedBox(width: 160, child: pw.Divider(color: accentColor)),
            pw.Text('Authorized Signatory', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    ];
  }

  List<pw.Widget> _buildPremium(InvoiceModel invoice, InvoiceTotals totals) {
    final primaryColor = PdfColor.fromInt(0xFF0F172A);
    final accentColor = PdfColor.fromInt(0xFF8B5CF6);
    final textStyle = pw.TextStyle(color: primaryColor, fontSize: 11, height: 1.5);

    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _pdfLogoMark(invoice.company, size: 80, background: primaryColor),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                invoice.documentTitle,
                style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: accentColor, letterSpacing: -1.0),
              ),
              pw.Text('INV-${invoice.number}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 60),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _pdfPremiumSection('DETAILS', [
              'ISSUED: ${DateFormatter.display(invoice.date)}',
              if (invoice.dueDate != null) 'DUE: ${DateFormatter.display(invoice.dueDate!)}',
            ], accentColor),
          ),
          pw.Expanded(
            child: _pdfPremiumSection('FROM', [
              invoice.company.name.toUpperCase(),
              invoice.company.address.singleLine,
              invoice.company.email,
            ], accentColor),
          ),
          pw.Expanded(
            child: _pdfPremiumSection('TO', [
              invoice.customer.name.toUpperCase(),
              if (invoice.customer.billingAddress != null)
                invoice.customer.billingAddress!.singleLine,
              if (invoice.customer.email != null) invoice.customer.email!,
            ], accentColor),
          ),
        ],
      ),
      pw.SizedBox(height: 60),
      pw.TableHelper.fromTextArray(
        headers: ['DESCRIPTION', 'QTY', 'PRICE', 'AMOUNT'],
        data: [
          for (final item in totals.lines)
            [
              item.name,
              MoneyFormatter.plain(item.quantity),
              MoneyFormatter.format(item.unitPrice, currency: invoice.currency),
              MoneyFormatter.format(item.lineTotal, currency: invoice.currency),
            ],
        ],
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor, fontSize: 9, letterSpacing: 1.0),
        headerDecoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0x338B5CF6), width: 1)),
        ),
        cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        cellAlignment: pw.Alignment.centerLeft,
        cellAlignments: {3: pw.Alignment.centerRight},
        cellPadding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        border: const pw.TableBorder(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFF1F5F9))),
      ),
      pw.SizedBox(height: 48),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PAYMENT INFORMATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: accentColor)),
                pw.SizedBox(height: 8),
                pw.Text('METHOD: ${invoice.payment.method}', style: textStyle),
                if (invoice.bank != null) ...[
                  pw.Text('BANK: ${invoice.bank!.bankName}', style: textStyle),
                  pw.Text('A/C: ${invoice.bank!.accountNumber}', style: textStyle),
                ],
              ],
            ),
          ),
          pw.SizedBox(
            width: 260,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Column(
                children: [
                  _pdfPremiumSummary('SUBTOTAL', totals.subtotal, invoice.currency, PdfColor.fromInt(0xB3FFFFFF)), // white70
                  _pdfPremiumSummary('TAX', totals.tax, invoice.currency, PdfColor.fromInt(0xB3FFFFFF)), // white70
                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColor.fromInt(0x3DFFFFFF)), // white24
                  pw.SizedBox(height: 12),
                  _pdfPremiumSummary('GRAND TOTAL', totals.grandTotal, invoice.currency, PdfColors.white, isTotal: true),
                ],
              ),
            ),
          ),
        ],
      ),
    ];
  }

  pw.Widget _pdfLogoMark(CompanyModel company, {double size = 48, required PdfColor background}) {
    return pw.Container(
      width: size,
      height: size,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: background,
        borderRadius: pw.BorderRadius.circular(size * 0.18),
      ),
      child: pw.Text(
        company.logoLabel ?? company.initials,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: size * 0.32,
        ),
      ),
    );
  }

  pw.Widget _pdfStandardInfoBox(String title, List<String> lines, PdfColor accent) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF9FAFB),
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border(left: pw.BorderSide(color: accent, width: 4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: accent),
          ),
          pw.SizedBox(height: 6),
          ...lines.map((l) => pw.Text(l, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
        ],
      ),
    );
  }

  pw.Widget _pdfPremiumSection(String title, List<String> lines, PdfColor accent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accent, letterSpacing: 1.5),
        ),
        pw.SizedBox(height: 12),
        ...lines.map((l) => pw.Text(l, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
      ],
    );
  }

  pw.Widget _pdfPremiumSummary(String label, double value, String currency, PdfColor color, {bool isTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: color,
            fontSize: isTotal ? 12 : 9,
          ),
        ),
        pw.Text(
          MoneyFormatter.format(value, currency: currency),
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: color,
            fontSize: isTotal ? 18 : 12,
          ),
        ),
      ],
    );
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
          MoneyFormatter.format(value, currency: currency),
          style: pw.TextStyle(
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
