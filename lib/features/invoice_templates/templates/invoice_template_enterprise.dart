import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
import '../invoice_template.dart';
import '../invoice_template_type.dart';
import '../theme/invoice_template_theme.dart';
import '../widgets/template_scaffold.dart';

/// Invoice template matching the supplied reference design.
///
/// Layout:
/// ┌──────────────────────────────────────────────────────────────┐
/// │ COMPANY INFORMATION                         INVOICE          │
/// │                                             DATE             │
/// │                                             INVOICE #        │
/// │                                             CUSTOMER ID      │
/// ├─────────────────────────┬────────────────────────────────────┤
/// │ BILL TO                  │ SHIP TO                           │
/// ├─────────────────────────┴────────────────────────────────────┤
/// │ SALESPERSON | P.O. # | SHIP DATE | SHIP VIA | F.O.B | TERMS │
/// ├──────────────────────────────────────────────────────────────┤
/// │ ITEM # | DESCRIPTION | QTY | UNIT PRICE | TOTAL              │
/// │        |             |     |            |                    │
/// ├──────────────────────────────────────────────────────────────┤
/// │ COMMENTS                              SUBTOTAL               │
/// │                                        TAX RATE               │
/// │                                        TAX                    │
/// │                                        S & H                   │
/// │                                        OTHER                  │
/// │                                        TOTAL                  │
/// ├──────────────────────────────────────────────────────────────┤
/// │                 Contact / Thank You                           │
/// └──────────────────────────────────────────────────────────────┘
class EnterpriseInvoiceTemplate extends InvoiceTemplate {
  static const theme = InvoiceTemplateThemes.enterprise;

  // ================================================================
  // REFERENCE DESIGN COLORS
  // ================================================================

  static const Color primaryBlue = Color(0xFF315D9B);
  static const Color darkBlue = Color(0xFF2D5792);
  static const Color headerBlue = Color(0xFF315D9B);

  static const Color textBlack = Color(0xFF111111);
  static const Color textDark = Color(0xFF252525);
  static const Color textGray = Color(0xFF555555);
  static const Color lightGray = Color(0xFFE6E6E6);
  static const Color borderGray = Color(0xFF777777);
  static const Color tableGray = Color(0xFFF1F3F5);
  static const Color totalGray = Color(0xFFE8EDF4);
  static const Color white = Colors.white;

  // ================================================================
  // FONT SIZES
  // ================================================================

  static const double companyNameSize = 9.5;
  static const double companyDetailsSize = 6.3;

  static const double invoiceTitleSize = 26;

  static const double metaLabelSize = 6.0;
  static const double metaValueSize = 6.5;

  static const double sectionTitleSize = 6.7;
  static const double customerNameSize = 6.7;
  static const double customerDetailsSize = 6.0;

  static const double infoHeaderSize = 6.0;
  static const double infoValueSize = 6.2;

  static const double tableHeaderSize = 6.5;
  static const double tableCellSize = 6.3;

  static const double totalLabelSize = 6.5;
  static const double totalValueSize = 6.5;
  static const double grandTotalSize = 7.2;

  static const double footerSize = 6.0;
  static const double thankYouSize = 8.5;

  // ================================================================
  // SPACING
  // ================================================================

  static const double pagePadding = 36;
  static const double sectionGap = 14;

  @override
  InvoiceTemplateType get type => InvoiceTemplateType.standard;

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
    const itemsPerPage = 11;
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
        // ------------------------------------------------------------
        // HEADER
        // ------------------------------------------------------------
        _buildHeader(invoice),

        const SizedBox(height: 18),

        // ------------------------------------------------------------
        // BILL TO / SHIP TO
        // ------------------------------------------------------------
        _buildBillingSection(invoice),

        const SizedBox(height: 18),

        // ------------------------------------------------------------
        // ORDER INFORMATION
        // ------------------------------------------------------------
        _buildOrderInfo(invoice),

        const SizedBox(height: 18),

        // ------------------------------------------------------------
        // ITEMS TABLE
        // ------------------------------------------------------------
        _buildItemsTable(
          totals,
          invoice.currency,
          startIndex: 0,
          endIndex: itemsPerPage,
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------------
        // COMMENTS + TOTALS
        // ------------------------------------------------------------
        if (!hasMultiplePages)
          _buildBottomSection(invoice, totals)
        else
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 235,
              child: _buildTotals(totals, invoice),
            ),
          ),

        const SizedBox(height: 18),

        // ------------------------------------------------------------
        // FOOTER
        // ------------------------------------------------------------
        if (!hasMultiplePages) _buildFooter(invoice),
      ],
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(InvoiceModel invoice) {
    return SizedBox(
      height: 145,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------------
          // COMPANY INFORMATION
          // ----------------------------------------------------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.company.name,
                    style: const TextStyle(
                      fontSize: companyNameSize,
                      fontWeight: FontWeight.w900,
                      color: textBlack,
                      height: 1.0,
                    ),
                  ),

                  const SizedBox(height: 4),

                  if (invoice.company.address.line1.isNotEmpty)
                    Text(
                      invoice.company.address.line1,
                      style: const TextStyle(
                        fontSize: companyDetailsSize,
                        color: textBlack,
                        height: 1.15,
                      ),
                    ),

                  Text(
                    '${invoice.company.address.city}, '
                    '${invoice.company.address.state} '
                    '${invoice.company.address.pincode}',
                    style: const TextStyle(
                      fontSize: companyDetailsSize,
                      color: textBlack,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Phone: ${invoice.company.phone}',
                    style: const TextStyle(
                      fontSize: companyDetailsSize,
                      color: textBlack,
                      height: 1.15,
                    ),
                  ),

                  Text(
                    'Email: ${invoice.company.email}',
                    style: const TextStyle(
                      fontSize: companyDetailsSize,
                      color: textBlack,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ----------------------------------------------------------
          // RIGHT SIDE INVOICE
          // ----------------------------------------------------------
          SizedBox(
            width: 285,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'INVOICE',
                  style: TextStyle(
                    fontSize: invoiceTitleSize,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                    height: 1,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 18),

                _buildMetaRow(
                  'DATE:',
                  DateFormatter.display(invoice.date),
                ),

                _buildMetaRow(
                  'INVOICE #',
                  invoice.number,
                ),

                _buildMetaRow(
                  'Customer ID',
                  invoice.orderNumber ?? '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // INVOICE META
  // ================================================================

  Widget _buildMetaRow(
    String label,
    String value,
  ) {
    return SizedBox(
      height: 26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: metaLabelSize,
                fontWeight: FontWeight.w800,
                color: textBlack,
              ),
            ),
          ),

          const SizedBox(width: 7),

          Container(
            width: 90,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: borderGray,
                width: 0.8,
              ),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: metaValueSize,
                fontWeight: FontWeight.w500,
                color: textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BILL TO / SHIP TO
  // ================================================================

  Widget _buildBillingSection(InvoiceModel invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCustomerBox(
            title: 'BILL TO:',
            invoice: invoice,
            isShipping: false,
          ),
        ),

        const SizedBox(width: 25),

        Expanded(
          child: _buildCustomerBox(
            title: 'SHIP TO (if different):',
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Blue section header
        Container(
          height: 28,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          color: primaryBlue,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: sectionTitleSize,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(height: 7),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.customer.name,
                style: const TextStyle(
                  fontSize: customerNameSize,
                  fontWeight: FontWeight.w700,
                  color: textBlack,
                ),
              ),

              if (address != null) ...[
                const SizedBox(height: 3),

                Text(
                  address.line1,
                  style: const TextStyle(
                    fontSize: customerDetailsSize,
                    color: textBlack,
                  ),
                ),

                Text(
                  '${address.city}, ${address.state} ${address.pincode}',
                  style: const TextStyle(
                    fontSize: customerDetailsSize,
                    color: textBlack,
                  ),
                ),
              ],

              if (invoice.customer.phone != null) ...[
                const SizedBox(height: 3),
                Text(
                  invoice.customer.phone!,
                  style: const TextStyle(
                    fontSize: customerDetailsSize,
                    color: textBlack,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // ORDER INFORMATION BAR
  // ================================================================

  Widget _buildOrderInfo(InvoiceModel invoice) {
    final values = [
      invoice.salesperson ?? '-',
      invoice.orderNumber ?? '-',
      '-',
      '-',
      '-',
      invoice.terms?.split('.').first ?? '-',
    ];

    final headers = [
      'SALESPERSON',
      'P.O. #',
      'SHIP DATE',
      'SHIP VIA',
      'F.O.B.',
      'TERMS',
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
          decoration: const BoxDecoration(
            color: primaryBlue,
          ),
          children: headers
              .map(
                (header) => _buildOrderHeader(header),
              )
              .toList(),
        ),

        TableRow(
          children: values
              .asMap()
              .entries
              .map(
                (entry) => _buildOrderValue(
                  entry.value,
                  entry.key == values.length - 1,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildOrderHeader(String text) {
    return Container(
      height: 29,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: infoHeaderSize,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildOrderValue(
    String text,
    bool last,
  ) {
    return Container(
      height: 25,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          right: last
              ? BorderSide.none
              : const BorderSide(
                  color: borderGray,
                  width: 0.5,
                ),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: infoValueSize,
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
    final safeEnd = endIndex.clamp(
      0,
      totals.lines.length,
    );

    final lines = totals.lines.sublist(
      startIndex.clamp(0, totals.lines.length),
      safeEnd,
    );

    return Table(
      border: TableBorder.all(
        color: borderGray,
        width: 0.7,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.00),
        1: FlexColumnWidth(2.80),
        2: FlexColumnWidth(0.72),
        3: FlexColumnWidth(1.10),
        4: FlexColumnWidth(1.10),
      },
      children: [
        // ------------------------------------------------------------
        // TABLE HEADER
        // ------------------------------------------------------------
        TableRow(
          decoration: const BoxDecoration(
            color: primaryBlue,
          ),
          children: const [
            _EnterpriseTableHeader('ITEM #'),
            _EnterpriseTableHeader('DESCRIPTION'),
            _EnterpriseTableHeader('QTY'),
            _EnterpriseTableHeader('UNIT PRICE'),
            _EnterpriseTableHeader('TOTAL'),
          ],
        ),

        // ------------------------------------------------------------
        // DATA ROWS
        // ------------------------------------------------------------
        ...lines.asMap().entries.map(
          (entry) {
            final line = entry.value;

            return TableRow(
              decoration: BoxDecoration(
                color: entry.key.isEven
                    ? tableGray
                    : Colors.white,
              ),
              children: [
                _buildItemCell(
                  '',
                  align: TextAlign.left,
                ),

                _buildItemCell(
                  line.name,
                  align: TextAlign.left,
                ),

                _buildItemCell(
                  _formatQuantity(line.quantity),
                  align: TextAlign.center,
                ),

                _buildItemCell(
                  '$currency ${line.unitPrice.toStringAsFixed(2)}',
                  align: TextAlign.right,
                ),

                _buildItemCell(
                  '$currency ${line.discountedAmount.toStringAsFixed(2)}',
                  align: TextAlign.right,
                  bold: true,
                ),
              ],
            );
          },
        ),

      ],
    );
  }

  static String _formatQuantity(dynamic value) {
    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      }

      return value.toStringAsFixed(2);
    }

    return value.toString();
  }

  Widget _buildItemCell(
    String text, {
    TextAlign align = TextAlign.left,
    bool bold = false,
  }) {
    return Container(
      height: 26,
      alignment: align == TextAlign.right
          ? Alignment.centerRight
          : align == TextAlign.center
              ? Alignment.center
              : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: tableCellSize,
          fontWeight: bold
              ? FontWeight.w700
              : FontWeight.w400,
          color: textBlack,
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
        // ------------------------------------------------------------
        // COMMENTS
        // ------------------------------------------------------------
        Expanded(
          flex: 58,
          child: _buildComments(invoice),
        ),

        const SizedBox(width: 35),

        // ------------------------------------------------------------
        // TOTALS
        // ------------------------------------------------------------
        SizedBox(
          width: 235,
          child: _buildTotals(
            totals,
            invoice,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // COMMENTS
  // ================================================================

  Widget _buildComments(InvoiceModel invoice) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderGray,
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 28,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
            ),
            color: const Color(0xFFD8D8D8),
            child: const Text(
              'Other Comments or Special Instructions',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w800,
                color: textBlack,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              8,
              8,
              8,
              5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (invoice.terms != null)
                  Text(
                    '1. ${invoice.terms!}',
                    style: const TextStyle(
                      fontSize: 6.2,
                      color: textBlack,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                if (invoice.customerNotes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '2. ${invoice.customerNotes!}',
                    style: const TextStyle(
                      fontSize: 6.2,
                      color: textBlack,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
        _buildTotalLine(
          'SUBTOTAL',
          _money(totals.subtotal, invoice.currency),
        ),

        _buildTotalLine(
          'TAX RATE',
          '${taxRate.toStringAsFixed(3)}%',
        ),

        _buildTotalLine(
          'TAX',
          _money(totals.tax, invoice.currency),
        ),

        _buildTotalLine(
          'S & H',
          _money(0, invoice.currency),
        ),

        _buildTotalLine(
          'OTHER',
          _money(
            invoice.otherCharges,
            invoice.currency,
          ),
        ),

        const SizedBox(height: 2),

        Container(
          height: 31,
          decoration: const BoxDecoration(
            color: totalGray,
            border: Border(
              top: BorderSide(
                color: primaryBlue,
                width: 2,
              ),
              bottom: BorderSide(
                color: primaryBlue,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: grandTotalSize,
                  fontWeight: FontWeight.w900,
                  color: textBlack,
                ),
              ),

              Text(
                _money(
                  totals.grandTotal,
                  invoice.currency,
                ),
                style: const TextStyle(
                  fontSize: grandTotalSize,
                  fontWeight: FontWeight.w900,
                  color: textBlack,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Make all checks payable to',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 6.2,
            color: textBlack,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          invoice.company.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w800,
            color: textBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalLine(
    String label,
    String value,
  ) {
    return SizedBox(
      height: 25,
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

          Container(
            width: 145,
            height: 25,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
            ),
            decoration: const BoxDecoration(
              color: totalGray,
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: totalValueSize,
                fontWeight: FontWeight.w600,
                color: textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _money(
    num value,
    String currency,
  ) {
    return '$currency ${value.toStringAsFixed(2)}';
  }

  // ================================================================
  // FOOTER
  // ================================================================

  Widget _buildFooter(InvoiceModel invoice) {
    return Column(
      children: [
        Container(
          height: 1,
          color: const Color(0xFFDDDDDD),
        ),

        const SizedBox(height: 13),

        const Text(
          'If you have any questions about this invoice, please contact',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: footerSize,
            color: textBlack,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          '${invoice.company.name} • '
          '${invoice.company.phone} • '
          '${invoice.company.email}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: footerSize,
            color: textBlack,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Thank You For Your Business!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: thankYouSize,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
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
      final endIndex = (startIndex + itemsPerPage)
          .clamp(0, totals.lines.length);

      final isLastPage =
          endIndex >= totals.lines.length;

      pages.add(
        _buildContinuationPage(
          invoice,
          totals,
          startIndex,
          endIndex,
          pageNumber,
          isLastPage,
          itemsPerPage,
        ),
      );

      startIndex = endIndex;
      pageNumber++;
    }

    return pages;
  }

  Widget _buildContinuationPage(
    InvoiceModel invoice,
    InvoiceTotals totals,
    int startIndex,
    int endIndex,
    int pageNumber,
    bool isLastPage,
    int itemsPerPage,
  ) {
    return _page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.company.name,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: primaryBlue,
                ),
              ),

              Text(
                'INVOICE ${invoice.number}  •  Page $pageNumber',
                style: const TextStyle(
                  fontSize: 6.5,
                  fontWeight: FontWeight.w600,
                  color: textGray,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildItemsTable(
            totals,
            invoice.currency,
            startIndex: startIndex,
            endIndex: endIndex,
          ),

          if (isLastPage) ...[
            const SizedBox(height: 18),

            _buildBottomSection(
              invoice,
              totals,
            ),

            const SizedBox(height: 18),

            _buildFooter(invoice),
          ],
        ],
      ),
    );
  }
}

// ==================================================================
// TABLE HEADER WIDGET
// ==================================================================

class _EnterpriseTableHeader extends StatelessWidget {
  final String text;

  const _EnterpriseTableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 6.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
