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
    return TemplateScaffold(
      theme: theme,
      child: Column(
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

          // Items Table + Totals
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildItemsTable(totals, invoice.currency),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  child: _buildTotalsSection(totals, invoice),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Comments + Footer
          _buildCommentsSection(invoice),
          const SizedBox(height: 6),
          _buildFooterSection(),
        ],
      ),
    );
  }

  /// Header: Company info on left, INVOICE title + date fields on right
  Widget _buildHeaderSection(InvoiceModel invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Company details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.company.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                invoice.company.address.line1,
                style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
              ),
              Text(
                '${invoice.company.address.city}, ${invoice.company.address.state} ${invoice.company.address.pincode}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 2),
              Text(
                'Phone: ${invoice.company.phone}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
              ),
              Text(
                'Email: ${invoice.company.email}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
              ),
            ],
          ),
        ),

        // Right: INVOICE title + date boxes
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'INVOICE',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e3a5f),
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('DATE:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF999999), width: 1),
                      ),
                      child: Text(
                        DateFormatter.display(invoice.date),
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('INVOICE #', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF999999), width: 1),
                      ),
                      child: Text(
                        invoice.number,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Customer ID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF999999), width: 1),
                      ),
                      child: Text(
                        invoice.orderNumber ?? '-',
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: const Color(0xFF1e3a5f),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          invoice.customer.name,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        if (invoice.customer.billingAddress != null) ...[
          Text(
            invoice.customer.billingAddress!.line1,
            style: const TextStyle(fontSize: 9),
          ),
          Text(
            '${invoice.customer.billingAddress!.city}, ${invoice.customer.billingAddress!.state} ${invoice.customer.billingAddress!.pincode}',
            style: const TextStyle(fontSize: 9),
          ),
        ],
        if (invoice.customer.phone != null)
          Text(
            'Phone: ${invoice.customer.phone}',
            style: const TextStyle(fontSize: 9),
          ),
      ],
    );
  }

  Widget _buildShippingBlock(String title, InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: const Color(0xFF1e3a5f),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          invoice.customer.name,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        if (invoice.customer.shippingAddress != null) ...[
          Text(
            invoice.customer.shippingAddress!.line1,
            style: const TextStyle(fontSize: 9),
          ),
          Text(
            '${invoice.customer.shippingAddress!.city}, ${invoice.customer.shippingAddress!.state} ${invoice.customer.shippingAddress!.pincode}',
            style: const TextStyle(fontSize: 9),
          ),
        ],
      ],
    );
  }

  /// Info bar: Salesperson, P.O., Ship Date, etc.
  Widget _buildInfoBar(InvoiceModel invoice) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              _buildInfoHeader('SALESPERSON'),
              _buildInfoHeader('P.O. #'),
              _buildInfoHeader('SHIP DATE'),
              _buildInfoHeader('SHIP VIA'),
              _buildInfoHeader('F.O.B.'),
              _buildInfoHeader('TERMS'),
            ],
          ),
          // Value row
          Row(
            children: [
              _buildInfoValue(invoice.salesperson ?? '-'),
              _buildInfoValue(invoice.orderNumber ?? '-'),
              _buildInfoValue('-'),
              _buildInfoValue('-'),
              _buildInfoValue('-'),
              _buildInfoValue(invoice.terms?.split('.')[0] ?? '-'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoHeader(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: const Color(0xFF1e3a5f),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoValue(String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Color(0xFFCCCCCC), width: 1),
            bottom: BorderSide(color: Color(0xFFCCCCCC), width: 1),
          ),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Items table
  Widget _buildItemsTable(InvoiceTotals totals, String currency) {
    return Table(
      border: TableBorder.all(color: const Color(0xFFCCCCCC), width: 1),
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
          decoration: const BoxDecoration(color: Color(0xFF1e3a5f)),
          children: [
            _buildTableHeader('ITEM #'),
            _buildTableHeader('DESCRIPTION'),
            _buildTableHeader('QTY'),
            _buildTableHeader('UNIT PRICE'),
            _buildTableHeader('TOTAL'),
          ],
        ),
        // Data rows
        ...totals.lines.asMap().entries.map((entry) {
          final isEven = entry.key % 2 == 0;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven ? const Color(0xFFF5F5F5) : Colors.white,
            ),
            children: [
              _buildTableCell(''),
              _buildTableCell(entry.value.name),
              _buildTableCell(entry.value.quantity.toStringAsFixed(2), align: TextAlign.right),
              _buildTableCell('$currency ${entry.value.unitPrice.toStringAsFixed(2)}', align: TextAlign.right),
              _buildTableCell('$currency ${entry.value.discountedAmount.toStringAsFixed(2)}', align: TextAlign.right),
            ],
          );
        }),
        // Empty rows
        ...List.generate(5, (i) {
          final isEven = (totals.lines.length + i) % 2 == 0;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven ? const Color(0xFFF5F5F5) : Colors.white,
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
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(fontSize: 9),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Totals section (right sidebar)
  Widget _buildTotalsSection(InvoiceTotals totals, InvoiceModel invoice) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
        color: const Color(0xFFF5F5F5),
      ),
      child: Column(
        children: [
          _buildTotalRow('SUBTOTAL', totals.subtotal, invoice.currency),
          _buildTotalRow('TAX RATE', totals.tax > 0 ? '${(totals.tax / totals.subtotal * 100).toStringAsFixed(2)}%' : '0.00%', null),
          _buildTotalRow('TAX', totals.tax, invoice.currency),
          _buildTotalRow('S & H', 0, invoice.currency),
          _buildTotalRow('OTHER', invoice.otherCharges, invoice.currency),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFCCCCCC), width: 2)),
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
        border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC), width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
            ),
            Text(
              valueStr,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRowBold(String label, double value, String currency) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            '$currency ${value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
              border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
              color: const Color(0xFFF0F0F0),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Other Comments or Special Instructions',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                if (invoice.terms != null)
                  Text(
                    '1. ${invoice.terms!}',
                    style: const TextStyle(fontSize: 8.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (invoice.customerNotes != null)
                  Text(
                    '2. ${invoice.customerNotes!}',
                    style: const TextStyle(fontSize: 8.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Make all checks payable to\n${invoice.company.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
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
        const Text(
          'If you have any questions about this invoice, please contact',
          style: TextStyle(fontSize: 8.5, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 2),
        const Text(
          '[Name, Phone #, E-mail]',
          style: TextStyle(fontSize: 8.5, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 8),
        Text(
          'Thank You For Your Business!',
          style: const TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
