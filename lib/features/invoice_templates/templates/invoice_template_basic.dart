import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
import '../invoice_template.dart';
import '../invoice_template_type.dart';
import '../theme/invoice_template_theme.dart';
import '../widgets/template_scaffold.dart';

/// Minimal, restrained invoice template with divider-based design.
///
/// Layout:
/// ┌──────────────────────────────────────────────────────────────┐
/// │ COMPANY NAME                                                 │
/// │ Address, Phone, Email                                        │
/// ├──────────────────────────────────────────────────────────────┤
/// │                                    INVOICE                   │
/// │                                    Date, Number              │
/// ├──────────────────────────────────────────────────────────────┤
/// │ BILL TO                          SHIP TO                     │
/// │ Customer details...              Shipping details...         │
/// ├──────────────────────────────────────────────────────────────┤
/// │ ITEM # | DESCRIPTION | QTY | UNIT PRICE | TOTAL              │
/// │        |             |     |            |                    │
/// ├──────────────────────────────────────────────────────────────┤
/// │ NOTES                                     TOTAL: $XXX.XX      │
/// │                                           TAX:   $XX.XX       │
/// │                                           DUE:   $XXX.XX      │
/// ├──────────────────────────────────────────────────────────────┤
/// │                 Thank You                                     │
/// └──────────────────────────────────────────────────────────────┘
class BasicInvoiceTemplate extends InvoiceTemplate {
  static const theme = InvoiceTemplateThemes.basic;

  // ================================================================
  // COLORS
  // ================================================================

  static const Color textBlack = Color(0xFF1F1F1F);
  static const Color textGray = Color(0xFF555555);
  static const Color borderGray = Color(0xFFAAAAAA);
  static const Color headerGray = Color(0xFFF5F5F5);
  static const Color white = Colors.white;

  // ================================================================
  // FONT SIZES
  // ================================================================

  static const double companyNameSize = 10;
  static const double companyDetailsSize = 7;

  static const double invoiceTitleSize = 20;
  static const double invoiceMetaSize = 7;

  static const double sectionHeaderSize = 7;
  static const double sectionContentSize = 7;

  static const double tableHeaderSize = 7;
  static const double tableCellSize = 7;

  static const double totalLabelSize = 7;
  static const double totalValueSize = 7;
  static const double grandTotalSize = 8;

  static const double footerSize = 8;

  // ================================================================
  // SPACING
  // ================================================================

  static const double pagePadding = 32;
  static const double sectionGap = 12;
  static const double dividerHeight = 0.8;

  @override
  InvoiceTemplateType get type => InvoiceTemplateType.basic;

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
    const itemsPerPage = 13;
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
        _buildDivider(),
        const SizedBox(height: sectionGap),
        _buildInvoiceMetadata(invoice),
        _buildDivider(),
        const SizedBox(height: sectionGap),
        _buildBillingSection(invoice),
        _buildDivider(),
        const SizedBox(height: sectionGap),
        _buildOrderInfo(invoice),
        _buildDivider(),
        const SizedBox(height: sectionGap),
        _buildItemsTable(
          totals,
          invoice.currency,
          startIndex: 0,
          endIndex: itemsPerPage,
        ),
        _buildDivider(),
        const SizedBox(height: sectionGap),
        if (!hasMultiplePages)
          _buildBottomSection(invoice, totals)
        else
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 200,
              child: _buildTotals(totals, invoice),
            ),
          ),
        const SizedBox(height: sectionGap),
        if (!hasMultiplePages) _buildFooter(),
      ],
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(InvoiceModel invoice) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invoice.company.name,
            style: const TextStyle(
              fontSize: companyNameSize,
              fontWeight: FontWeight.w800,
              color: textBlack,
            ),
          ),
          const SizedBox(height: 3),
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
          const SizedBox(height: 2),
          Text(
            '${invoice.company.phone} • ${invoice.company.email}',
            style: const TextStyle(
              fontSize: companyDetailsSize,
              color: textGray,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DIVIDER
  // ================================================================

  Widget _buildDivider() {
    return Container(
      height: dividerHeight,
      color: borderGray,
    );
  }

  // ================================================================
  // INVOICE METADATA
  // ================================================================

  Widget _buildInvoiceMetadata(InvoiceModel invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox.shrink(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'INVOICE',
              style: TextStyle(
                fontSize: invoiceTitleSize,
                fontWeight: FontWeight.w700,
                color: textBlack,
              ),
            ),
            const SizedBox(height: 4),
            _buildMetaRow('Date:', DateFormatter.display(invoice.date)),
            _buildMetaRow('Invoice #:', invoice.number),
            _buildMetaRow('Order #:', invoice.orderNumber ?? '-'),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: invoiceMetaSize,
            fontWeight: FontWeight.w600,
            color: textBlack,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: invoiceMetaSize,
            color: textBlack,
          ),
        ),
      ],
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
          child: _buildCustomerBox(
            title: 'BILL TO',
            invoice: invoice,
            isShipping: false,
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: _buildCustomerBox(
            title: 'SHIP TO',
            invoice: invoice,
            isShipping: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerBox({
    required String title,
    required InvoiceModel invoice,
    required bool isShipping,
  }) {
    final address = isShipping
        ? invoice.customer.shippingAddress
        : invoice.customer.billingAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: sectionHeaderSize,
            fontWeight: FontWeight.w700,
            color: textBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          invoice.customer.name,
          style: const TextStyle(
            fontSize: sectionContentSize,
            fontWeight: FontWeight.w600,
            color: textBlack,
          ),
        ),
        if (address != null) ...[
          const SizedBox(height: 2),
          Text(
            address.line1,
            style: const TextStyle(
              fontSize: sectionContentSize,
              color: textGray,
            ),
          ),
          Text(
            '${address.city}, ${address.state} ${address.pincode}',
            style: const TextStyle(
              fontSize: sectionContentSize,
              color: textGray,
            ),
          ),
        ],
        if (invoice.customer.phone != null) ...[
          const SizedBox(height: 2),
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
        width: dividerHeight,
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
          decoration: const BoxDecoration(color: headerGray),
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
      height: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 6.2,
          fontWeight: FontWeight.w700,
          color: textBlack,
        ),
      ),
    );
  }

  Widget _buildOrderValueCell(String text) {
    return Container(
      height: 22,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 6.5,
          color: textBlack,
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
        bottom: BorderSide(
          color: borderGray,
          width: dividerHeight,
        ),
      ),
      columnWidths: const {
        0: FlexColumnWidth(0.8),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(0.7),
        3: FlexColumnWidth(1.0),
        4: FlexColumnWidth(1.0),
      },
      children: [
        // Table header
        TableRow(
          decoration: const BoxDecoration(
            color: headerGray,
          ),
          children: const [
            _BasicTableHeader('ITEM #'),
            _BasicTableHeader('DESCRIPTION'),
            _BasicTableHeader('QTY'),
            _BasicTableHeader('UNIT PRICE'),
            _BasicTableHeader('TOTAL'),
          ],
        ),
        // Data rows
        ...lines.map((line) {
          return TableRow(
            children: [
              _buildBasicCell(''),
              _buildBasicCell(line.name),
              _buildBasicCell(_formatQuantity(line.quantity), align: TextAlign.center),
              _buildBasicCell('$currency ${line.unitPrice.toStringAsFixed(2)}', align: TextAlign.right),
              _buildBasicCell('$currency ${line.discountedAmount.toStringAsFixed(2)}', align: TextAlign.right),
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

  Widget _buildBasicCell(
    String text, {
    TextAlign align = TextAlign.left,
  }) {
    return Container(
      height: 24,
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
          style: const TextStyle(
            fontSize: tableCellSize,
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
          width: 200,
          child: _buildTotals(totals, invoice),
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
        const Text(
          'COMMENTS',
          style: TextStyle(
            fontSize: sectionHeaderSize,
            fontWeight: FontWeight.w700,
            color: textBlack,
          ),
        ),
        const SizedBox(height: 4),
        if (invoice.terms != null)
          Text(
            '1. ${invoice.terms!}',
            style: const TextStyle(
              fontSize: sectionContentSize,
              color: textGray,
              height: 1.4,
            ),
          ),
        if (invoice.customerNotes != null) ...[
          const SizedBox(height: 3),
          Text(
            '2. ${invoice.customerNotes!}',
            style: const TextStyle(
              fontSize: sectionContentSize,
              color: textGray,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  // ================================================================
  // TOTALS
  // ================================================================

  Widget _buildTotals(
    InvoiceTotals totals,
    InvoiceModel invoice,
  ) {
    final taxRate = totals.subtotal > 0
        ? (totals.tax / totals.subtotal * 100)
        : 0;

    return Column(
      children: [
        _buildTotalLine('SUBTOTAL', _money(totals.subtotal, invoice.currency)),
        _buildTotalLine('TAX RATE', '${taxRate.toStringAsFixed(3)}%'),
        _buildTotalLine('TAX', _money(totals.tax, invoice.currency)),
        _buildTotalLine('S & H', _money(0, invoice.currency)),
        _buildTotalLine('OTHER', _money(invoice.otherCharges, invoice.currency)),
        const SizedBox(height: 8),
        _buildGrandTotalLine('TOTAL', _money(totals.grandTotal, invoice.currency)),
      ],
    );
  }

  Widget _buildTotalLine(String label, String value) {
    return SizedBox(
      height: 22,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: totalLabelSize,
              color: textBlack,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: totalValueSize,
              color: textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalLine(String label, String value) {
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: grandTotalSize,
              fontWeight: FontWeight.w700,
              color: textBlack,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: grandTotalSize,
              fontWeight: FontWeight.w700,
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

  Widget _buildFooter() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          height: dividerHeight,
          color: borderGray,
        ),
        const SizedBox(height: 8),
        const Text(
          'Thank You!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: footerSize,
            fontWeight: FontWeight.w600,
            color: textBlack,
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
              Text(
                '${invoice.company.name} • INVOICE ${invoice.number} • Page $pageNumber',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 6.5,
                  color: textGray,
                ),
              ),
              const SizedBox(height: 12),
              _buildItemsTable(
                totals,
                invoice.currency,
                startIndex: startIndex,
                endIndex: endIndex,
              ),
              if (isLastPage) ...[
                const SizedBox(height: 12),
                _buildBottomSection(invoice, totals),
                const SizedBox(height: 12),
                _buildFooter(),
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

class _BasicTableHeader extends StatelessWidget {
  final String text;

  const _BasicTableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w700,
          color: BasicInvoiceTemplate.textBlack,
        ),
      ),
    );
  }
}
