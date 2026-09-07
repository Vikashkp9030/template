import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
import '../invoice_template.dart';
import '../invoice_template_type.dart';
import '../theme/invoice_template_theme.dart';
import '../widgets/template_scaffold.dart';

/// Premium invoice template with luxury design elements.
///
/// Features:
/// - Dark grand-total card with gold accent border
/// - Violet accent lines and accents
/// - Refined typography and spacing
/// - Decorative corner elements
/// - Professional, high-end appearance
class PremiumInvoiceTemplate extends InvoiceTemplate {
  static const theme = InvoiceTemplateThemes.premium;

  // ================================================================
  // COLORS
  // ================================================================

  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentViolet = Color(0xFF7B5BA1);
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFF16213E);

  static const Color textWhite = Color(0xFFFAFAFA);
  static const Color textBlack = Color(0xFF0F0F0F);
  static const Color textGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFFF8F8F8);
  static const Color borderGray = Color(0xFFDDDDDD);
  static const Color tableAltRow = Color(0xFFFBFBFB);
  static const Color white = Colors.white;

  // ================================================================
  // FONT SIZES
  // ================================================================

  static const double companyNameSize = 12;
  static const double companyDetailsSize = 6.5;

  static const double invoiceTitleSize = 24;

  static const double metaLabelSize = 6.0;
  static const double metaValueSize = 6.5;

  static const double sectionHeaderSize = 7;
  static const double sectionContentSize = 6.5;

  static const double tableHeaderSize = 6.5;
  static const double tableCellSize = 6.5;

  static const double totalLabelSize = 6.5;
  static const double totalValueSize = 6.5;
  static const double grandTotalSize = 8;

  static const double footerSize = 6;

  // ================================================================
  // SPACING
  // ================================================================

  static const double pagePadding = 36;
  static const double sectionGap = 16;
  static const double decorativeLineWidth = 3.0;

  @override
  InvoiceTemplateType get type => InvoiceTemplateType.premium;

  @override
  String get name => type.title;

  @override
  String get description => type.description;

  @override
  List<Widget> buildPages({
    required InvoiceModel invoice,
    required InvoiceTotals totals,
    required InvoicePaperSize paperSize,
  }) {
    const itemsPerPage = 12;
    final hasMultiplePages = totals.lines.length > itemsPerPage;

    return [
      _page(
        _buildFirstPage(
          invoice,
          totals,
          itemsPerPage,
          hasMultiplePages,
        ),
      ),
      if (hasMultiplePages)
        ..._buildAdditionalPages(
          invoice,
          totals,
          itemsPerPage,
        ),
    ];
  }

  /// Page shell shared by the first and every continuation page.
  Widget _page(Widget content) {
    return TemplateScaffold(
      theme: theme,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(pagePadding),
        child: content,
      ),
    );
  }

  // ================================================================
  // FIRST PAGE
  // ================================================================

  Widget _buildFirstPage(
    InvoiceModel invoice,
    InvoiceTotals totals,
    int itemsPerPage,
    bool hasMultiplePages,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(invoice),
        const SizedBox(height: sectionGap),
        _buildAccentLine(),
        const SizedBox(height: sectionGap),
        _buildBillingSection(invoice),
        const SizedBox(height: sectionGap + 4),
        _buildOrderInfo(invoice),
        const SizedBox(height: sectionGap + 4),
        _buildItemsTable(
          totals,
          invoice.currency,
          startIndex: 0,
          endIndex: itemsPerPage,
        ),
        const SizedBox(height: sectionGap),
        if (!hasMultiplePages)
          _buildBottomSection(invoice, totals)
        else
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 240,
              child: _buildTotalsCard(totals, invoice),
            ),
          ),
        const SizedBox(height: sectionGap),
        if (!hasMultiplePages) _buildFooter(invoice),
      ],
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(InvoiceModel invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.company.name,
                style: const TextStyle(
                  fontSize: companyNameSize,
                  fontWeight: FontWeight.w900,
                  color: textBlack,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                invoice.company.address.line1,
                style: const TextStyle(
                  fontSize: companyDetailsSize,
                  color: textGray,
                ),
              ),
              Text(
                '${invoice.company.address.city}, ${invoice.company.address.state} ${invoice.company.address.pincode}',
                style: const TextStyle(
                  fontSize: companyDetailsSize,
                  color: textGray,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${invoice.company.phone} • ${invoice.company.email}',
                style: const TextStyle(
                  fontSize: companyDetailsSize,
                  color: textGray,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'INVOICE',
                style: TextStyle(
                  fontSize: invoiceTitleSize,
                  fontWeight: FontWeight.w900,
                  color: accentViolet,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              _buildMetaRow(
                'Date',
                DateFormatter.display(invoice.date),
              ),
              const SizedBox(height: 4),
              _buildMetaRow(
                'Invoice #',
                invoice.number,
              ),
              const SizedBox(height: 4),
              _buildMetaRow(
                'Order #',
                invoice.orderNumber ?? '-',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: metaLabelSize,
            fontWeight: FontWeight.w600,
            color: textGray,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: metaValueSize,
            fontWeight: FontWeight.w600,
            color: textBlack,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // ACCENT LINE
  // ================================================================

  Widget _buildAccentLine() {
    return Container(
      height: decorativeLineWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentViolet, accentGold, accentViolet],
          stops: const [0, 0.5, 1],
        ),
      ),
    );
  }

  // ================================================================
  // BILLING SECTION
  // ================================================================

  Widget _buildBillingSection(InvoiceModel invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildBillToBox(invoice),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: _buildShipToBox(invoice),
        ),
      ],
    );
  }

  Widget _buildBillToBox(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BILL TO',
          style: TextStyle(
            fontSize: sectionHeaderSize,
            fontWeight: FontWeight.w800,
            color: accentViolet,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          invoice.customer.name,
          style: const TextStyle(
            fontSize: sectionContentSize,
            fontWeight: FontWeight.w700,
            color: textBlack,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          invoice.customer.billingAddress?.line1 ?? '',
          style: const TextStyle(
            fontSize: sectionContentSize,
            color: textGray,
          ),
        ),
        Text(
          '${invoice.customer.billingAddress?.city}, ${invoice.customer.billingAddress?.state} ${invoice.customer.billingAddress?.pincode}',
          style: const TextStyle(
            fontSize: sectionContentSize,
            color: textGray,
          ),
        ),
        if (invoice.customer.phone != null) ...[
          const SizedBox(height: 3),
          Text(
            invoice.customer.phone!,
            style: const TextStyle(
              fontSize: sectionContentSize,
              color: textGray,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShipToBox(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHIP TO',
          style: TextStyle(
            fontSize: sectionHeaderSize,
            fontWeight: FontWeight.w800,
            color: accentViolet,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          invoice.customer.name,
          style: const TextStyle(
            fontSize: sectionContentSize,
            fontWeight: FontWeight.w700,
            color: textBlack,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          invoice.customer.shippingAddress?.line1 ?? '',
          style: const TextStyle(
            fontSize: sectionContentSize,
            color: textGray,
          ),
        ),
        Text(
          '${invoice.customer.shippingAddress?.city}, ${invoice.customer.shippingAddress?.state} ${invoice.customer.shippingAddress?.pincode}',
          style: const TextStyle(
            fontSize: sectionContentSize,
            color: textGray,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // ORDER INFORMATION BAR
  // ================================================================

  Widget _buildOrderInfo(InvoiceModel invoice) {
    final headers = [
      'SALESPERSON',
      'P.O. #',
      'SHIP DATE',
      'SHIP VIA',
      'F.O.B.',
      'TERMS',
    ];

    final values = [
      invoice.salesperson ?? '-',
      invoice.orderNumber ?? '-',
      '-',
      '-',
      '-',
      invoice.terms?.split('.').first ?? '-',
    ];

    return Table(
      border: TableBorder.all(
        color: borderGray,
        width: 0.7,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.20),
        1: FlexColumnWidth(0.85),
        2: FlexColumnWidth(0.85),
        3: FlexColumnWidth(1.20),
        4: FlexColumnWidth(0.85),
        5: FlexColumnWidth(1.20),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: darkCard),
          children: headers.map(_buildOrderHeaderCell).toList(),
        ),
        TableRow(
          children: values.map(_buildOrderValueCell).toList(),
        ),
      ],
    );
  }

  Widget _buildOrderHeaderCell(String text) {
    return Container(
      height: 26,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 6.0,
          fontWeight: FontWeight.w800,
          color: accentGold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildOrderValueCell(String text) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 6.3,
          color: textBlack,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ================================================================
  // ITEMS TABLE
  // ================================================================

  Widget _buildItemsTable(
    InvoiceTotals totals,
    String currency, {
    required int startIndex,
    required int endIndex,
  }) {
    final safeEnd = endIndex.clamp(0, totals.lines.length);
    final lines = totals.lines.sublist(
      startIndex.clamp(0, totals.lines.length),
      safeEnd,
    );

    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: borderGray,
          width: 0.5,
        ),
      ),
      columnWidths: const {
        0: FlexColumnWidth(0.8),
        1: FlexColumnWidth(2.8),
        2: FlexColumnWidth(0.7),
        3: FlexColumnWidth(1.0),
        4: FlexColumnWidth(1.0),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: lightGray,
            border: Border(
              top: BorderSide(color: borderGray, width: 1),
              bottom: BorderSide(color: borderGray, width: 1),
            ),
          ),
          children: const [
            _PremiumTableHeader('ITEM #'),
            _PremiumTableHeader('DESCRIPTION'),
            _PremiumTableHeader('QTY'),
            _PremiumTableHeader('UNIT PRICE'),
            _PremiumTableHeader('TOTAL'),
          ],
        ),
        ...lines.asMap().entries.map((entry) {
          final line = entry.value;
          return TableRow(
            decoration: BoxDecoration(
              color: entry.key.isEven ? white : tableAltRow,
            ),
            children: [
              _buildTableCell(''),
              _buildTableCell(line.name),
              _buildTableCell(
                _formatQuantity(line.quantity),
                align: TextAlign.center,
              ),
              _buildTableCell(
                '$currency ${line.unitPrice.toStringAsFixed(2)}',
                align: TextAlign.right,
              ),
              _buildTableCell(
                '$currency ${line.discountedAmount.toStringAsFixed(2)}',
                align: TextAlign.right,
                bold: true,
              ),
            ],
          );
        }),
      ],
    );
  }

  static String _formatQuantity(dynamic value) {
    if (value is num) {
      if (value % 1 == 0) return value.toInt().toString();
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  Widget _buildTableCell(
    String text, {
    TextAlign align = TextAlign.left,
    bool bold = false,
  }) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Align(
        alignment: align == TextAlign.right
            ? Alignment.centerRight
            : align == TextAlign.center
                ? Alignment.center
                : Alignment.centerLeft,
        child: Text(
          text,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: tableCellSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: textBlack,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // BOTTOM SECTION
  // ================================================================

  Widget _buildBottomSection(
    InvoiceModel invoice,
    InvoiceTotals totals,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildNotes(invoice),
        ),
        const SizedBox(width: 30),
        SizedBox(
          width: 240,
          child: _buildTotalsCard(totals, invoice),
        ),
      ],
    );
  }

  // ================================================================
  // NOTES
  // ================================================================

  Widget _buildNotes(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMMENTS',
          style: TextStyle(
            fontSize: sectionHeaderSize,
            fontWeight: FontWeight.w800,
            color: accentViolet,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (invoice.terms != null) ...[
          Text(
            invoice.terms!,
            style: const TextStyle(
              fontSize: sectionContentSize,
              color: textGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
        ],
        if (invoice.customerNotes != null)
          Text(
            invoice.customerNotes!,
            style: const TextStyle(
              fontSize: sectionContentSize,
              color: textGray,
              height: 1.5,
            ),
          ),
      ],
    );
  }

  // ================================================================
  // TOTALS CARD
  // ================================================================

  Widget _buildTotalsCard(
    InvoiceTotals totals,
    InvoiceModel invoice,
  ) {
    final taxRate = totals.subtotal > 0
        ? (totals.tax / totals.subtotal * 100)
        : 0;

    return Column(
      children: [
        _buildTotalLineLight('SUBTOTAL', _money(totals.subtotal, invoice.currency)),
        _buildTotalLineLight('TAX RATE', '${taxRate.toStringAsFixed(3)}%'),
        _buildTotalLineLight('TAX', _money(totals.tax, invoice.currency)),
        _buildTotalLineLight('S & H', _money(0, invoice.currency)),
        _buildTotalLineLight('OTHER', _money(invoice.otherCharges, invoice.currency)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: darkCard,
            border: Border(
              top: BorderSide(color: accentGold, width: 2),
              bottom: BorderSide(color: accentGold, width: 2),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: grandTotalSize,
                      fontWeight: FontWeight.w900,
                      color: accentGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    _money(totals.grandTotal, invoice.currency),
                    style: TextStyle(
                      fontSize: grandTotalSize,
                      fontWeight: FontWeight.w900,
                      color: accentGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Make checks payable to',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 6,
            color: textGray,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          invoice.company.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 6.5,
            fontWeight: FontWeight.w700,
            color: textBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalLineLight(String label, String value) {
    return SizedBox(
      height: 22,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: totalLabelSize,
              fontWeight: FontWeight.w600,
              color: textBlack,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: totalValueSize,
              fontWeight: FontWeight.w600,
              color: textBlack,
            ),
          ),
        ],
      ),
    );
  }

  static String _money(num value, String currency) {
    return '$currency ${value.toStringAsFixed(2)}';
  }

  // ================================================================
  // FOOTER
  // ================================================================

  Widget _buildFooter(InvoiceModel invoice) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: borderGray,
        ),
        const SizedBox(height: 8),
        Text(
          'For inquiries: ${invoice.company.email} • ${invoice.company.phone}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: footerSize,
            color: textGray,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Thank You for Your Business',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: footerSize + 1,
            fontWeight: FontWeight.w600,
            color: accentViolet,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // MULTI-PAGE
  // ================================================================

  List<Widget> _buildAdditionalPages(
    InvoiceModel invoice,
    InvoiceTotals totals,
    int itemsPerPage,
  ) {
    final pages = <Widget>[];
    int startIndex = itemsPerPage;
    int pageNumber = 2;

    while (startIndex < totals.lines.length) {
      final endIndex = (startIndex + itemsPerPage).clamp(0, totals.lines.length);
      final isLastPage = endIndex >= totals.lines.length;

      pages.add(
        _page(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.company.name,
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      color: accentViolet,
                    ),
                  ),
                  Text(
                    'INVOICE ${invoice.number}  •  Page $pageNumber',
                    style: const TextStyle(
                      fontSize: 6,
                      color: textGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildItemsTable(
                totals,
                invoice.currency,
                startIndex: startIndex,
                endIndex: endIndex,
              ),
              if (isLastPage) ...[
                const SizedBox(height: sectionGap),
                _buildBottomSection(invoice, totals),
                const SizedBox(height: sectionGap),
                _buildFooter(invoice),
              ],
            ],
          ),
        ),
      );

      startIndex = endIndex;
      pageNumber++;
    }

    return pages;
  }
}

// ==================================================================
// TABLE HEADER WIDGET
// ==================================================================

class _PremiumTableHeader extends StatelessWidget {
  final String text;

  const _PremiumTableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 6.5,
          fontWeight: FontWeight.w700,
          color: PremiumInvoiceTemplate.textBlack,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
