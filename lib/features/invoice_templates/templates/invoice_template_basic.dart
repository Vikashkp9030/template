import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
import '../../../widgets/common/invoice_bits.dart';
import '../invoice_template.dart';
import '../invoice_template_type.dart';

class BasicInvoiceTemplate implements InvoiceTemplate {
  @override
  InvoiceTemplateType get type => InvoiceTemplateType.basic;

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
    return ColoredBox(
      color: Colors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 12,
          height: 1.5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.documentTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${invoice.numberLabel} ${invoice.number}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'DATE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey),
                      ),
                      Text(DateFormatter.display(invoice.date)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FROM',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(invoice.company.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(invoice.company.address.singleLine),
                        Text('Phone: ${invoice.company.phone}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BILL TO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(invoice.customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (invoice.customer.billingAddress != null)
                          Text(invoice.customer.billingAddress!.singleLine),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(4),
                  1: IntrinsicColumnWidth(),
                  2: IntrinsicColumnWidth(),
                  3: IntrinsicColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
                    ),
                    children: [
                      _headerCell('Item'),
                      _headerCell('Qty'),
                      _headerCell('Price'),
                      _headerCell('Total'),
                    ],
                  ),
                  for (final item in totals.lines)
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                      ),
                      children: [
                        _cell(item.name),
                        _cell(MoneyFormatter.plain(item.quantity)),
                        _cell(MoneyFormatter.format(item.unitPrice, currency: invoice.currency)),
                        _cell(
                          MoneyFormatter.format(item.lineTotal, currency: invoice.currency),
                          align: TextAlign.right,
                        ),
                      ],
                    ),
                ],
              ),
              const Spacer(),
              const Divider(color: Color(0xFFE5E7EB)),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      AmountLine(
                        label: 'Grand Total',
                        value: totals.grandTotal,
                        currency: invoice.currency,
                        emphasis: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey),
        ),
      );

  Widget _cell(String text, {TextAlign align = TextAlign.left}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(text, textAlign: align),
      );
}
