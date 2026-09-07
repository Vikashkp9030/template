import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
import '../invoice_template.dart';
import '../invoice_template_type.dart';
import '../theme/invoice_template_theme.dart';
import '../widgets/template_scaffold.dart';

/// Professional invoice template matching reference design:
/// Company header (left) + INVOICE title (right top) +
/// billing sections + info bar + items table + totals + comments + footer
class EnterpriseInvoiceTemplate implements InvoiceTemplate {
  static const theme = InvoiceTemplateThemes.enterprise;

  @override
  InvoiceTemplateType get type => InvoiceTemplateType.standard;

  @override
  String get name => type.title;

  @override
  String get description => type.description;

  @override
  Widget build({
    required BuildContext context,
    required InvoiceModel invoice,
    required InvoiceTotals totals,
    required InvoicePaperSize paperSize,
  }) {
    final totalLines = totals.lines.length;
    final itemsPerPage = _calculateItemsPerPage();
    final hasMultiplePages = totalLines > itemsPerPage;

    return TemplateScaffold(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Page 1: Header + Billing + Info + Items
          _buildFirstPage(invoice, totals, invoice.currency, itemsPerPage, hasMultiplePages),

          // Additional pages if needed
          if (hasMultiplePages) ...[
            const SizedBox(height: 20),
            ..._buildAdditionalPages(invoice, totals, invoice.currency, itemsPerPage),
          ],
        ],
      ),
    );
  }

  int _calculateItemsPerPage() {
    return 8;
  }

  Widget _buildFirstPage(
    InvoiceModel invoice,
    InvoiceTotals totals,
    String currency,
    int itemsPerPage,
    bool hasMultiplePages,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: Company (left) + INVOICE Title (right)
        _buildHeaderSection(invoice),
        const SizedBox(height: 16),

        // Bill To / Ship To
        _buildBillingSection(invoice),
        const SizedBox(height: 12),

        // Info Bar (Salesperson, P.O., etc.)
        _buildInfoBar(invoice),
        const SizedBox(height: 12),

        // Items Table (full width) - First page items
        Expanded(
          child: _buildItemsTablePaginated(
            totals,
            currency,
            startIndex: 0,
            endIndex: itemsPerPage,
            emptyRows: hasMultiplePages ? 0 : 5,
          ),
        ),
        const SizedBox(height: 12),

        // Totals Section (right-aligned) - Only on last page
        if (!hasMultiplePages)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Container()),
              SizedBox(
                width: 200,
                child: _buildTotalsSection(totals, invoice),
              ),
            ],
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 200,
              child: _buildTotalsSection(totals, invoice),
            ),
          ),
        const SizedBox(height: 12),

        // Comments + Footer - Only on last page
        if (!hasMultiplePages) ...[
          _buildCommentsSection(invoice),
          const SizedBox(height: 6),
          _buildFooterSection(),
        ],
      ],
    );
  }

  List<Widget> _buildAdditionalPages(
    InvoiceModel invoice,
    InvoiceTotals totals,
    String currency,
    int itemsPerPage,
  ) {
    final pages = <Widget>[];
    int pageIndex = 1;
    int startIndex = itemsPerPage;

    while (startIndex < totals.lines.length) {
      final endIndex = (startIndex + itemsPerPage).clamp(0, totals.lines.length);
      final isLastPage = endIndex >= totals.lines.length;

      pages.add(
        _buildContinuationPage(
          invoice,
          totals,
          currency,
          startIndex,
          endIndex,
          pageIndex,
          isLastPage,
        ),
      );

      startIndex = endIndex;
      pageIndex++;
    }

    return pages;
  }

  Widget _buildContinuationPage(
    InvoiceModel invoice,
    InvoiceTotals totals,
    String currency,
    int startIndex,
    int endIndex,
    int pageNumber,
    bool isLastPage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Page header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${invoice.company.name} - Invoice ${invoice.number}',
              style: const TextStyle(
                fontSize: 5.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1e3a5f),
              ),
            ),
            Text(
              'Page $pageNumber',
              style: const TextStyle(
                fontSize: 5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Items Table (full width)
        Expanded(
          child: _buildItemsTablePaginated(
            totals,
            currency,
            startIndex: startIndex,
            endIndex: endIndex,
            emptyRows: isLastPage ? 0 : 5,
          ),
        ),
        const SizedBox(height: 12),

        // Totals and Footer - Only on last page
        if (isLastPage) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Container()),
              SizedBox(
                width: 200,
                child: _buildTotalsSection(totals, invoice),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCommentsSection(invoice),
          const SizedBox(height: 6),
          _buildFooterSection(),
        ],
      ],
    );
  }

  /// Header: Company info on left, INVOICE title + date fields on right
  Widget _buildHeaderSection(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Company details with accent bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 28,
                    color: const Color(0xFF1e3a5f),
                    margin: const EdgeInsets.only(bottom: 4),
                  ),
                  Text(
                    invoice.company.name,
                    style: const TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1e3a5f),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Text(
                    invoice.company.address.line1,
                    style: const TextStyle(fontSize: 5, color: Color(0xFF555555), fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${invoice.company.address.city}, ${invoice.company.address.state} ${invoice.company.address.pincode}',
                    style: const TextStyle(fontSize: 5, color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Phone: ${invoice.company.phone}',
                    style: const TextStyle(fontSize: 5, color: Color(0xFF666666), fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Email: ${invoice.company.email}',
                    style: const TextStyle(fontSize: 5, color: Color(0xFF666666), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Right: INVOICE title + date boxes
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 6),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1e3a5f), width: 3)),
                  ),
                  child: Text(
                    'INVOICE',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1e3a5f),
                      height: 1.0,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _buildDateField('DATE:', DateFormatter.display(invoice.date), 52),
                    const SizedBox(width: 5),
                    _buildDateField('INVOICE #', invoice.number, 52),
                    const SizedBox(width: 5),
                    _buildDateField('Customer ID', invoice.orderNumber ?? '-', 32),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          height: 1,
          color: const Color(0xFFE0E0E0),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String value, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 4.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1e3a5f),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 1),
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 2.5),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1e3a5f), width: 1),
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xFFFAFBFC),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e3a5f),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Bill To / Ship To sections
  Widget _buildBillingSection(InvoiceModel invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildBillingBlock('BILL TO:', invoice),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildShippingBlock('SHIP TO (if different):', invoice),
        ),
      ],
    );
  }

  Widget _buildBillingBlock(String title, InvoiceModel invoice) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: const Color(0xFF1e3a5f), width: 3)),
        color: const Color(0xFFFAFBFC),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1e3a5f),
              fontSize: 5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            invoice.customer.name,
            style: const TextStyle(fontSize: 5.5, fontWeight: FontWeight.w700, color: Color(0xFF1e3a5f)),
          ),
          if (invoice.customer.billingAddress != null) ...[
            const SizedBox(height: 1.5),
            Text(
              invoice.customer.billingAddress!.line1,
              style: const TextStyle(fontSize: 4.5, color: Color(0xFF555555), fontWeight: FontWeight.w500),
            ),
            Text(
              '${invoice.customer.billingAddress!.city}, ${invoice.customer.billingAddress!.state} ${invoice.customer.billingAddress!.pincode}',
              style: const TextStyle(fontSize: 4.5, color: Color(0xFF555555)),
            ),
          ],
          if (invoice.customer.phone != null) ...[
            const SizedBox(height: 1.5),
            Text(
              'Phone: ${invoice.customer.phone}',
              style: const TextStyle(fontSize: 4.5, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShippingBlock(String title, InvoiceModel invoice) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: const Color(0xFF2d5a8c), width: 3)),
        color: const Color(0xFFF5F8FB),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2d5a8c),
              fontSize: 5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            invoice.customer.name,
            style: const TextStyle(fontSize: 5.5, fontWeight: FontWeight.w700, color: Color(0xFF2d5a8c)),
          ),
          if (invoice.customer.shippingAddress != null) ...[
            const SizedBox(height: 1.5),
            Text(
              invoice.customer.shippingAddress!.line1,
              style: const TextStyle(fontSize: 4.5, color: Color(0xFF555555), fontWeight: FontWeight.w500),
            ),
            Text(
              '${invoice.customer.shippingAddress!.city}, ${invoice.customer.shippingAddress!.state} ${invoice.customer.shippingAddress!.pincode}',
              style: const TextStyle(fontSize: 4.5, color: Color(0xFF555555)),
            ),
          ],
        ],
      ),
    );
  }

  /// Info bar: Salesperson, P.O., Ship Date, etc.
  Widget _buildInfoBar(InvoiceModel invoice) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(1), topRight: Radius.circular(1)),
            ),
            child: Row(
              children: [
                _buildInfoHeader('SALESPERSON'),
                _buildInfoHeader('P.O. #'),
                _buildInfoHeader('SHIP DATE'),
                _buildInfoHeader('SHIP VIA'),
                _buildInfoHeader('F.O.B.'),
                _buildInfoHeader('TERMS'),
              ],
            ),
          ),
          // Value row
          Row(
            children: [
              _buildInfoValue(invoice.salesperson ?? '-'),
              _buildInfoValue(invoice.orderNumber ?? '-'),
              _buildInfoValue('-'),
              _buildInfoValue('-'),
              _buildInfoValue('-'),
              _buildInfoValue(invoice.terms?.split('.')[0] ?? '-', isLast: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoHeader(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4.5),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 4.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoValue(String value, {bool isLast = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            right: !isLast ? const BorderSide(color: Color(0xFFE0E5F0), width: 0.5) : BorderSide.none,
            bottom: const BorderSide(color: Color(0xFFE0E5F0), width: 0.5),
          ),
          color: const Color(0xFFFBFCFE),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Items table - Paginated version
  Widget _buildItemsTablePaginated(
    InvoiceTotals totals,
    String currency, {
    required int startIndex,
    required int endIndex,
    required int emptyRows,
  }) {
    final paginatedLines = totals.lines.sublist(
      startIndex,
      endIndex.clamp(0, totals.lines.length),
    );

    return _buildItemsTableWithLines(paginatedLines, currency, emptyRows);
  }

  /// Items table - Core implementation
  Widget _buildItemsTableWithLines(
    List<dynamic> lines,
    String currency,
    int emptyRows,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 2, spreadRadius: 0),
        ],
      ),
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder(
            horizontalInside: const BorderSide(color: Color(0xFFE8EBF0), width: 0.5),
            verticalInside: const BorderSide(color: Color(0xFFE8EBF0), width: 0.5),
          ),
          columnWidths: const {
            0: FractionColumnWidth(0.12),
            1: FractionColumnWidth(0.40),
            2: FractionColumnWidth(0.12),
            3: FractionColumnWidth(0.18),
            4: FractionColumnWidth(0.18),
          },
          children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2)),
            ),
            children: [
              _buildTableHeader('ITEM #'),
              _buildTableHeader('DESCRIPTION'),
              _buildTableHeader('QTY'),
              _buildTableHeader('UNIT PRICE'),
              _buildTableHeader('TOTAL'),
            ],
          ),
          // Data rows
          ...lines.asMap().entries.map((entry) {
            final isEven = entry.key % 2 == 0;
            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? const Color(0xFFFBFCFE) : const Color(0xFFFFFFFF),
              ),
              children: [
                _buildTableCell(''),
                _buildTableCell(entry.value.name),
                _buildTableCell(entry.value.quantity.toStringAsFixed(2), align: TextAlign.right),
                _buildTableCell('$currency ${entry.value.unitPrice.toStringAsFixed(2)}', align: TextAlign.right),
                _buildTableCell('$currency ${entry.value.discountedAmount.toStringAsFixed(2)}', align: TextAlign.right, isBold: true),
              ],
            );
          }),
          // Empty rows
          ...List.generate(emptyRows, (i) {
            final isEven = (lines.length + i) % 2 == 0;
            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? const Color(0xFFFBFCFE) : const Color(0xFFFFFFFF),
              ),
              children: [
                _buildTableCell(''),
                _buildTableCell(''),
                _buildTableCell(''),
                _buildTableCell(''),
                _buildTableCell('$currency 0.00', align: TextAlign.right),
              ],
            );
          }),
        ],
        ),
      ),
    );
  }


  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 4.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {TextAlign align = TextAlign.left, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 5,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: const Color(0xFF2C3E50),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Totals section (right sidebar)
  Widget _buildTotalsSection(InvoiceTotals totals, InvoiceModel invoice) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
        borderRadius: BorderRadius.circular(2),
        color: const Color(0xFFFBFCFE),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 2, spreadRadius: 0),
        ],
      ),
      child: Column(
        children: [
          _buildTotalRow('SUBTOTAL', totals.subtotal, invoice.currency),
          _buildTotalRow('TAX RATE', totals.tax > 0 ? '${(totals.tax / totals.subtotal * 100).toStringAsFixed(2)}%' : '0.00%', null),
          _buildTotalRow('TAX', totals.tax, invoice.currency),
          _buildTotalRow('S & H', 0, invoice.currency),
          _buildTotalRow('OTHER', invoice.otherCharges, invoice.currency),
          Container(
            decoration: BoxDecoration(
              border: const Border(top: BorderSide(color: Color(0xFF1e3a5f), width: 2.5)),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(2), bottomRight: Radius.circular(2)),
              color: const Color(0xFF1e3a5f),
            ),
            child: _buildTotalRowBold('TOTAL', totals.grandTotal, invoice.currency),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, dynamic value, String? currency) {
    final valueStr = currency != null
        ? '$currency ${(value is double ? value : value.toDouble()).toStringAsFixed(2)}'
        : value.toString();

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8EBF0), width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
                letterSpacing: 0.2,
              ),
            ),
            Text(
              valueStr,
              style: const TextStyle(
                fontSize: 5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1e3a5f),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRowBold(String label, double value, String currency) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            '$currency ${value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Comments section + Footer
  Widget _buildCommentsSection(InvoiceModel invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFFFBFCFE),
            ),
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Other Comments or Special Instructions',
                  style: TextStyle(
                    fontSize: 5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1e3a5f),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3.5),
                if (invoice.terms != null)
                  Text(
                    '1. ${invoice.terms!}',
                    style: const TextStyle(fontSize: 4.5, color: Color(0xFF555555), fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (invoice.customerNotes != null) ...[
                  const SizedBox(height: 1.5),
                  Text(
                    '2. ${invoice.customerNotes!}',
                    style: const TextStyle(fontSize: 4.5, color: Color(0xFF555555), fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1e3a5f), width: 1.5),
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFFFAFBFC),
            ),
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Make all checks payable to',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 4.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  invoice.company.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 5.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1e3a5f),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        Container(
          height: 1,
          color: const Color(0xFFD0D5E0),
          margin: const EdgeInsets.only(bottom: 5),
        ),
        const Text(
          'If you have any questions about this invoice, please contact',
          style: TextStyle(
            fontSize: 4.5,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1.5),
        const Text(
          '[Name, Phone #, E-mail]',
          style: TextStyle(
            fontSize: 4.5,
            color: Color(0xFF999999),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4.5),
        Text(
          'Thank You For Your Business!',
          style: const TextStyle(
            fontSize: 6.5,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1e3a5f),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
