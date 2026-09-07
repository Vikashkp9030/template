import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
import '../invoice_template.dart';
import '../invoice_template_type.dart';
import '../theme/invoice_template_theme.dart';
import '../widgets/template_scaffold.dart';

/// Tax invoice template matching exact reference design: left-side company header,
/// right-side INVOICE title with date/invoice# boxes, billing sections, info bar,
/// items table, totals sidebar, comments, and thank you footer.
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
          _buildHeader(invoice),
          const SizedBox(height: 30),
          _buildBillingSection(invoice),
          const SizedBox(height: 20),
          _buildInfoBar(),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildItemsTable(totals, invoice.currency),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 220,
                  child: _buildTotalsBox(totals, invoice.currency),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCommentsBox(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );
  }

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
                style: theme.type.bodyStrong.flutter.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                invoice.company.address.singleLine,
                style: theme.type.body.flutter.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 8),
              Text(
                'Phone: ${invoice.company.phone}',
                style: theme.type.body.flutter.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'INVOICE',
              style: theme.type.documentTitle.flutter,
            ),
            const SizedBox(height: 15),
            _buildMetaBox('DATE:', DateFormatter.display(invoice.date)),
            const SizedBox(height: 8),
            _buildMetaBox('INVOICE #', invoice.number),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: theme.type.body.flutter.copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF999999), width: 1),
            color: Colors.white,
          ),
          child: Text(
            value,
            style: theme.type.body.flutter.copyWith(fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingSection(InvoiceModel invoice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildBillingCard('BILL TO:', [
            invoice.customer.name,
            if (invoice.customer.billingAddress != null) invoice.customer.billingAddress!.singleLine,
            if (invoice.customer.phone != null) 'Phone: ${invoice.customer.phone}',
          ]),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: _buildBillingCard('SHIP TO (if different):', []),
        ),
      ],
    );
  }

  Widget _buildBillingCard(String title, List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Color(theme.accent),
          child: Text(
            title,
            style: theme.type.sectionLabel.flutter,
          ),
        ),
        const SizedBox(height: 8),
        ...lines.map((line) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(line, style: theme.type.body.flutter.copyWith(fontSize: 11)),
        )),
      ],
    );
  }

  Widget _buildInfoBar() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Color(theme.divider))),
      child: Column(
        children: [
          Row(
            children: [
              _buildInfoCell('SALESPERSON'),
              _buildInfoCell('P.O. #'),
              _buildInfoCell('SHIP DATE'),
              _buildInfoCell('SHIP VIA'),
              _buildInfoCell('F.O.B.'),
              _buildInfoCell('TERMS'),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border(right: BorderSide(color: Color(theme.divider)))),
              )),
              Expanded(child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border(right: BorderSide(color: Color(theme.divider)))),
              )),
              Expanded(child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border(right: BorderSide(color: Color(theme.divider)))),
              )),
              Expanded(child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border(right: BorderSide(color: Color(theme.divider)))),
              )),
              Expanded(child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border(right: BorderSide(color: Color(theme.divider)))),
              )),
              Expanded(child: Container(
                padding: const EdgeInsets.all(8),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCell(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Color(theme.accent),
          border: Border(right: BorderSide(color: Color(theme.divider))),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.type.tableHeader.flutter,
        ),
      ),
    );
  }

  Widget _buildItemsTable(InvoiceTotals totals, String currency) {
    return Table(
      border: TableBorder.all(color: Color(theme.divider), width: 1),
      columnWidths: const {
        0: FractionColumnWidth(0.08),
        1: FractionColumnWidth(0.45),
        2: FractionColumnWidth(0.15),
        3: FractionColumnWidth(0.15),
        4: FractionColumnWidth(0.17),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Color(theme.accent)),
          children: [
            _buildTableHeaderCell('ITEM #'),
            _buildTableHeaderCell('DESCRIPTION'),
            _buildTableHeaderCell('QTY'),
            _buildTableHeaderCell('UNIT PRICE'),
            _buildTableHeaderCell('TOTAL'),
          ],
        ),
        ...totals.lines.asMap().entries.map((entry) {
          final isEven = entry.key % 2 == 0;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven ? Color(theme.surfaceMuted) : Colors.white,
              border: Border(bottom: BorderSide(color: Color(theme.divider))),
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
        // Add empty rows to match reference height
        ...List.generate(8, (i) => TableRow(
          decoration: BoxDecoration(
            color: ((totals.lines.length + i) % 2 == 0) ? Color(theme.surfaceMuted) : Colors.white,
            border: Border(bottom: BorderSide(color: Color(theme.divider))),
          ),
          children: [
            _buildTableCell(''),
            _buildTableCell(''),
            _buildTableCell(''),
            _buildTableCell(''),
            _buildTableCell('${currency} 0.00', align: TextAlign.right),
          ],
        )),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: theme.type.tableHeader.flutter,
      ),
    );
  }

  Widget _buildTableCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        textAlign: align,
        style: theme.type.tableCell.flutter,
      ),
    );
  }

  Widget _buildTotalsBox(InvoiceTotals totals, String currency) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(theme.divider)),
        color: Color(theme.surfaceMuted),
      ),
      child: Column(
        children: [
          _buildTotalRow('SUBTOTAL', '$currency ${totals.subtotal.toStringAsFixed(2)}'),
          _buildTotalRow('TAX RATE', '0.00%'),
          _buildTotalRow('TAX', '$currency ${totals.tax.toStringAsFixed(2)}'),
          _buildTotalRow('S & H', '$currency 0.00'),
          _buildTotalRow('OTHER', '$currency 0.00'),
          _buildTotalRow('TOTAL', '$currency ${totals.grandTotal.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(theme.divider))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                label,
                style: (isTotal
                  ? theme.type.grandTotalLabel.flutter
                  : theme.type.totalLabel.flutter
                ).copyWith(fontSize: 11),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: (isTotal
                ? theme.type.grandTotalValue.flutter
                : theme.type.totalValue.flutter
              ).copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsBox() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(theme.divider)),
        color: Color(0xFFF0F0F0),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Other Comments or Special Instructions',
            style: theme.type.body.flutter.copyWith(fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(height: 8),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Thank You For Your Business!',
          style: theme.type.footer.flutter.copyWith(fontStyle: FontStyle.italic, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Text(
          'If you have any questions about this invoice, please contact us',
          style: theme.type.footer.flutter.copyWith(fontSize: 10, color: const Color(0xFF666666)),
        ),
      ],
    );
  }
}
