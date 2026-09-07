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
import '../invoice_templates/theme/invoice_template_theme.dart';
import '../invoice_templates/theme/invoice_template_theme_pdf_x.dart';

/// Renders the same three templates as the Flutter widget layer
/// (`lib/features/invoice_templates/templates/`), reading colors, spacing,
/// and typography from the same [InvoiceTemplateThemes] instances via the
/// `pw`-mapping extensions in `invoice_template_theme_pdf_x.dart`. The two
/// renderers are necessarily separate widget trees (`Widget` vs `pw.Widget`
/// are different packages), but sharing the token values means they can't
/// silently drift the way hand-duplicated hex/px values used to.
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
      final theme = switch (template) {
        InvoiceTemplateType.basic => InvoiceTemplateThemes.basic,
        InvoiceTemplateType.standard => InvoiceTemplateThemes.enterprise,
        InvoiceTemplateType.premium => InvoiceTemplateThemes.premium,
      };

      doc.addPage(
        pw.MultiPage(
          pageFormat: format,
          margin: theme.pdfPageMargin,
          build: (context) => switch (template) {
            InvoiceTemplateType.basic => _buildBasic(theme, invoice, totals),
            InvoiceTemplateType.standard => _buildEnterprise(theme, invoice, totals),
            InvoiceTemplateType.premium => _buildPremium(theme, invoice, totals),
          },
          footer: (context) => _footer(theme, invoice, context),
        ),
      );
      return await doc.save();
    } catch (error) {
      throw PdfGenerationException('Unable to generate PDF.', cause: error);
    }
  }

  // ---------------------------------------------------------------------
  // Basic
  // ---------------------------------------------------------------------

  List<pw.Widget> _buildBasic(InvoiceTemplateTheme theme, InvoiceModel invoice, InvoiceTotals totals) {
    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(invoice.documentTitle.toUpperCase(), style: theme.type.documentTitle.pdf),
              pw.SizedBox(height: 8),
              pw.Text('${invoice.numberLabel} ${invoice.number}', style: theme.type.body.pdf),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('DATE', style: theme.type.sectionLabel.pdf),
              pw.Text(DateFormatter.display(invoice.date), style: theme.type.body.pdf),
              if (invoice.dueDate != null) ...[
                pw.SizedBox(height: 4),
                pw.Text('DUE', style: theme.type.sectionLabel.pdf),
                pw.Text(DateFormatter.display(invoice.dueDate!), style: theme.type.body.pdf),
              ],
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 40),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _partyColumn(theme, 'From', [
              invoice.company.name,
              invoice.company.address.singleLine,
              'Phone: ${invoice.company.phone}',
            ]),
          ),
          pw.Expanded(
            child: _partyColumn(theme, 'Bill To', [
              invoice.customer.name,
              if (invoice.customer.billingAddress != null)
                invoice.customer.billingAddress!.singleLine,
            ]),
          ),
        ],
      ),
      pw.SizedBox(height: 40),
      _itemsTable(theme, invoice, totals),
      pw.SizedBox(height: 24),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.SizedBox(width: 220, child: _totals(theme, invoice, totals)),
      ),
      ..._notesTermsAndSignature(theme, invoice),
    ];
  }

  // ---------------------------------------------------------------------
  // Enterprise
  // ---------------------------------------------------------------------

  List<pw.Widget> _buildEnterprise(InvoiceTemplateTheme theme, InvoiceModel invoice, InvoiceTotals totals) {
    return [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _logoMark(invoice.company, size: 60, background: theme.pdfAccent),
          pw.SizedBox(width: 18),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(invoice.company.name, style: theme.type.bodyStrong.pdf.copyWith(fontSize: 20)),
                pw.Text(invoice.company.address.singleLine, style: theme.type.body.pdf),
                pw.Text('Tel: ${invoice.company.phone} | ${invoice.company.email}', style: theme.type.body.pdf),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0x0F2563EB),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(invoice.documentTitle, style: theme.type.documentTitle.pdf),
                pw.Text('${invoice.numberLabel} ${invoice.number}', style: theme.type.bodyStrong.pdf),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 28),
      pw.Row(
        children: [
          pw.Expanded(
            child: _cardColumn(theme, 'Bill To', [
              invoice.customer.name,
              if (invoice.customer.billingAddress != null)
                invoice.customer.billingAddress!.singleLine,
              if (invoice.customer.phone != null) 'Phone: ${invoice.customer.phone}',
            ]),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: _cardColumn(theme, 'Details', [
              'Date: ${DateFormatter.display(invoice.date)}',
              if (invoice.dueDate != null) 'Due: ${DateFormatter.display(invoice.dueDate!)}',
              'Method: ${invoice.payment.method}',
              'Status: ${invoice.payment.status}',
            ]),
          ),
        ],
      ),
      pw.SizedBox(height: 28),
      _itemsTable(theme, invoice, totals),
      pw.SizedBox(height: 24),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: _notesTerms(theme, invoice) ?? pw.SizedBox.shrink(),
          ),
          pw.SizedBox(width: 16),
          pw.SizedBox(width: 240, child: _totals(theme, invoice, totals)),
        ],
      ),
      pw.SizedBox(height: 32),
      _signature(theme),
    ];
  }

  // ---------------------------------------------------------------------
  // Premium
  // ---------------------------------------------------------------------

  List<pw.Widget> _buildPremium(InvoiceTemplateTheme theme, InvoiceModel invoice, InvoiceTotals totals) {
    // Note: Premium's decorative corner accent in the Flutter template
    // (CustomPaint _TopRightAccent) doesn't translate neatly to PDF because
    // MultiPage content is rendered separately without a global Stack.
    // Omitting it from the PDF is an acceptable trade-off (the accent is
    // purely decorative, not information), while all functional sections
    // remain identical to the Flutter template.
    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _logoMark(invoice.company, size: 72, background: theme.pdfPrimary),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(invoice.documentTitle, style: theme.type.documentTitle.pdf),
                pw.Text(
                  '${invoice.numberLabel} ${invoice.number}',
                  style: theme.type.bodyStrong.pdf.copyWith(fontSize: 15, color: theme.pdfTextMuted),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 48),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _partyColumn(theme, 'Details', [
                'Issued: ${DateFormatter.display(invoice.date)}',
                if (invoice.dueDate != null) 'Due: ${DateFormatter.display(invoice.dueDate!)}',
              ]),
            ),
            pw.Expanded(
              child: _partyColumn(theme, 'From', [
                invoice.company.name,
                invoice.company.address.singleLine,
                invoice.company.email,
              ]),
            ),
            pw.Expanded(
              child: _partyColumn(theme, 'To', [
                invoice.customer.name,
                if (invoice.customer.billingAddress != null)
                  invoice.customer.billingAddress!.singleLine,
                if (invoice.customer.email != null) invoice.customer.email!,
              ]),
            ),
          ],
        ),
        pw.SizedBox(height: 48),
        _itemsTable(theme, invoice, totals),
        pw.SizedBox(height: 40),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PAYMENT INFORMATION', style: theme.type.sectionLabel.pdf),
                  pw.SizedBox(height: 8),
                  pw.Text('Method: ${invoice.payment.method}', style: theme.type.body.pdf),
                  if (invoice.bank != null) ...[
                    pw.Text('Bank: ${invoice.bank!.bankName}', style: theme.type.body.pdf),
                    pw.Text('A/C: ${invoice.bank!.accountNumber}', style: theme.type.body.pdf),
                  ],
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            pw.SizedBox(width: 260, child: _totals(theme, invoice, totals)),
          ],
        ),
        ..._notesTermsAndSignature(theme, invoice),
      ],
      ),
    ];
  }

  // ---------------------------------------------------------------------
  // Shared section builders — mirror the Flutter widgets section-for-section
  // (see lib/features/invoice_templates/widgets/) so the two are easy to
  // audit side by side even though they can't share widget code directly.
  // ---------------------------------------------------------------------

  pw.Widget _partyColumn(InvoiceTemplateTheme theme, String title, List<String> lines) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title.toUpperCase(), style: theme.type.sectionLabel.pdf),
        pw.SizedBox(height: 6),
        ...lines.map((l) => pw.Text(l, style: theme.type.bodyStrong.pdf)),
      ],
    );
  }

  pw.Widget _cardColumn(InvoiceTemplateTheme theme, String title, List<String> lines) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: theme.pdfSurfaceMuted,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border(left: pw.BorderSide(color: theme.pdfAccent, width: 3)),
      ),
      child: _partyColumn(theme, title, lines),
    );
  }

  static const _tableLabels = ['Description', 'Qty', 'Unit Price', 'Amount'];

  pw.Widget _itemsTable(InvoiceTemplateTheme theme, InvoiceModel invoice, InvoiceTotals totals) {
    final table = theme.table;
    return pw.TableHelper.fromTextArray(
      headers: [for (final l in _tableLabels) l.toUpperCase()],
      data: [
        for (final item in totals.lines)
          [
            item.name,
            MoneyFormatter.plain(item.quantity),
            MoneyFormatter.format(item.unitPrice, currency: invoice.currency),
            MoneyFormatter.format(item.lineTotal, currency: invoice.currency),
          ],
      ],
      headerStyle: theme.type.tableHeader.pdf,
      headerDecoration: table.headerBackground != null
          ? pw.BoxDecoration(color: PdfColor.fromInt(table.headerBackground!))
          : pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: theme.pdfDivider, width: 1.5)),
            ),
      cellStyle: theme.type.tableCell.pdf,
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: const {1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight},
      headerAlignments: const {1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight},
      border: null,
      headerAlignment: pw.Alignment.centerLeft,
      cellPadding: pw.EdgeInsets.symmetric(
        vertical: table.cellPaddingVertical,
        horizontal: table.cellPaddingHorizontal,
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(4.5),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.5),
      },
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(table.rowDivider))),
      ),
    );
  }

  pw.Widget _totals(InvoiceTemplateTheme theme, InvoiceModel invoice, InvoiceTotals totals) {
    final rows = <pw.Widget>[
      _amountLine(theme, 'Subtotal', totals.subtotal, invoice.currency, theme.type.totalLabel, theme.type.totalValue),
      if (totals.discount > 0)
        _amountLine(theme, 'Discount', -totals.discount, invoice.currency, theme.type.totalLabel, theme.type.totalValue),
      _amountLine(theme, 'Tax', totals.tax, invoice.currency, theme.type.totalLabel, theme.type.totalValue),
    ];
    final grandTotal = _amountLine(
      theme, 'Grand Total', totals.grandTotal, invoice.currency, theme.type.grandTotalLabel, theme.type.grandTotalValue,
    );

    if (theme.pdfGrandTotalCardBackground == null) {
      return pw.Column(
        children: [
          ...rows,
          pw.Divider(thickness: 1.5, height: 24, color: theme.pdfDivider),
          grandTotal,
        ],
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: theme.pdfGrandTotalCardBackground,
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Column(
        children: [
          ...rows,
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColor.fromInt(0x3DFFFFFF)),
          pw.SizedBox(height: 12),
          grandTotal,
        ],
      ),
    );
  }

  pw.Widget _amountLine(
    InvoiceTemplateTheme theme,
    String label,
    num value,
    String currency,
    InvoiceTextStyle labelStyle,
    InvoiceTextStyle valueStyle,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: labelStyle.pdf),
          pw.Text(MoneyFormatter.format(value, currency: currency), style: valueStyle.pdf),
        ],
      ),
    );
  }

  List<pw.Widget> _notesTermsAndSignature(InvoiceTemplateTheme theme, InvoiceModel invoice) {
    final notesTerms = _notesTerms(theme, invoice);
    return [
      if (notesTerms != null) ...[pw.SizedBox(height: 32), notesTerms],
      pw.SizedBox(height: 32),
      _signature(theme),
    ];
  }

  pw.Widget? _notesTerms(InvoiceTemplateTheme theme, InvoiceModel invoice) {
    final hasNotes = (invoice.notes ?? '').isNotEmpty;
    final hasTerms = (invoice.terms ?? '').isNotEmpty;
    if (!hasNotes && !hasTerms) return null;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (hasNotes) ...[
          pw.Text('NOTES', style: theme.type.sectionLabel.pdf),
          pw.SizedBox(height: 4),
          pw.Text(invoice.notes!, style: theme.type.body.pdf),
        ],
        if (hasNotes && hasTerms) pw.SizedBox(height: 12),
        if (hasTerms) ...[
          pw.Text('TERMS', style: theme.type.sectionLabel.pdf),
          pw.SizedBox(height: 4),
          pw.Text(invoice.terms!, style: theme.type.body.pdf),
        ],
      ],
    );
  }

  pw.Widget _signature(InvoiceTemplateTheme theme) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        children: [
          pw.SizedBox(width: 160, child: pw.Divider(color: theme.pdfAccent)),
          pw.Text('Authorized Signatory', style: theme.type.bodyStrong.pdf),
        ],
      ),
    );
  }

  pw.Widget _footer(InvoiceTemplateTheme theme, InvoiceModel invoice, pw.Context context) {
    final company = invoice.company;
    final contact = [company.name, company.phone, company.email]
        .where((e) => e.trim().isNotEmpty)
        .join('  •  ');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Divider(color: theme.pdfDivider),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(child: pw.Text(contact, style: theme.type.footer.pdf)),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: theme.type.footer.pdf,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _logoMark(CompanyModel company, {double size = 48, required PdfColor background}) {
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
        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: size * 0.32),
      ),
    );
  }
}
