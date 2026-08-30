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

class RetailInvoiceTemplate implements InvoiceTemplate {
  @override
  InvoiceTemplateType get type => InvoiceTemplateType.retail;

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
      color: const Color(0xFFFFF7ED),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                LogoMark(
                  company: invoice.company,
                  background: AppColors.retailAccent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    invoice.company.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  invoice.number,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.retailAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Customer', invoice.customer.name),
                _chip('Salesperson', invoice.salesperson ?? '-'),
                _chip('Warehouse', invoice.warehouse ?? '-'),
                _chip('Date', DateFormatter.display(invoice.date)),
                _chip('Pay', invoice.payment.method),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              color: Colors.white,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.1),
                  1: FlexColumnWidth(2.4),
                  2: FlexColumnWidth(0.7),
                  3: FlexColumnWidth(1.1),
                  4: FlexColumnWidth(1.0),
                  5: FlexColumnWidth(0.8),
                  6: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: AppColors.retailAccent,
                    ),
                    children: [
                      for (final h in [
                        'SKU',
                        'Product',
                        'Qty',
                        'Price',
                        'Disc',
                        'Tax',
                        'Total',
                      ])
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            h,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (final line in totals.lines)
                    TableRow(
                      children: [
                        _td(line.sku),
                        _td(line.name),
                        _td(MoneyFormatter.plain(line.quantity)),
                        _td(MoneyFormatter.plain(line.unitPrice)),
                        _td(MoneyFormatter.plain(line.discount)),
                        _td('${line.taxRate.toStringAsFixed(0)}%'),
                        _td(MoneyFormatter.plain(line.lineTotal)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Paid ${MoneyFormatter.format(totals.paidAmount, currency: invoice.currency)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'Outstanding ${MoneyFormatter.format(totals.balanceAmount, currency: invoice.currency)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.retailAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.retailChip,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _td(String text) =>
      Padding(padding: const EdgeInsets.all(8), child: Text(text));
}
