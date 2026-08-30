import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
import '../../../widgets/common/invoice_bits.dart';
import '../invoice_template.dart';
import '../invoice_template_type.dart';

class CompactInvoiceTemplate implements InvoiceTemplate {
  @override
  InvoiceTemplateType get type => InvoiceTemplateType.compact;

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
          fontSize: 10,
          color: AppColors.compactInk,
          height: 1.25,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.company.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    invoice.number,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text(invoice.company.address.singleLine)),
                  Text(DateFormatter.display(invoice.date)),
                ],
              ),
              if (invoice.company.gstin != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('GSTIN ${invoice.company.gstin}'),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Divider(height: 1, color: AppColors.compactRule),
              ),
              Row(
                children: [
                  Expanded(child: Text('Customer: ${invoice.customer.name}')),
                  if (invoice.dueDate != null)
                    Text('Due ${DateFormatter.display(invoice.dueDate!)}'),
                ],
              ),
              if (invoice.customer.gstin != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Customer GSTIN ${invoice.customer.gstin}'),
                ),
              const SizedBox(height: 8),
              Table(
                border: const TableBorder(
                  horizontalInside: BorderSide(
                    color: AppColors.compactRule,
                    width: 0.4,
                  ),
                  top: BorderSide(color: AppColors.compactInk),
                  bottom: BorderSide(color: AppColors.compactInk),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(2.6),
                  1: FlexColumnWidth(0.6),
                  2: FlexColumnWidth(1.0),
                  3: FlexColumnWidth(0.8),
                  4: FlexColumnWidth(0.8),
                  5: FlexColumnWidth(1.1),
                },
                children: [
                  TableRow(
                    children: [
                      for (final h in [
                        'Item',
                        'Qty',
                        'Price',
                        'Disc',
                        'Tax',
                        'Amt',
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            h,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                    ],
                  ),
                  for (final line in totals.lines)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text('${line.name} (${line.sku})'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(MoneyFormatter.plain(line.quantity)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(MoneyFormatter.plain(line.unitPrice)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(MoneyFormatter.plain(line.discount)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text('${line.taxRate.toStringAsFixed(0)}%'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(MoneyFormatter.plain(line.lineTotal)),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tax summary',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        for (final tax in totals.taxLines)
                          Text(
                            '${tax.label}: ${MoneyFormatter.plain(tax.amount)}',
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Payment: ${invoice.payment.method} (${invoice.payment.status})',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: Column(
                      children: [
                        AmountLine(
                          label: 'Subtotal',
                          value: totals.subtotal,
                          currency: invoice.currency,
                        ),
                        AmountLine(
                          label: 'Tax',
                          value: totals.tax,
                          currency: invoice.currency,
                        ),
                        AmountLine(
                          label: 'Total',
                          value: totals.grandTotal,
                          currency: invoice.currency,
                          emphasis: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.compactRule),
              Text(invoice.terms ?? invoice.notes ?? invoice.company.email),
            ],
          ),
        ),
      ),
    );
  }
}
