import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/thermal_paper_size.dart';
import '../thermal_template.dart';
import '../thermal_template_type.dart';

class ClassicThermalTemplate implements ThermalTemplate {
  @override
  ThermalTemplateType get type => ThermalTemplateType.classic;

  @override
  String get name => type.title;

  @override
  String get description => type.description;

  @override
  Widget build({
    required BuildContext context,
    required InvoiceModel invoice,
    required InvoiceTotals totals,
    required ThermalPaperSize paperSize,
  }) {
    final width = paperSize.previewWidth;
    final dash = '-' * (paperSize == ThermalPaperSize.mm58 ? 28 : 36);
    return ColoredBox(
      color: AppColors.receiptPaper,
      child: SizedBox(
        width: width,
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 12,
            color: AppColors.receiptInk,
            height: 1.25,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  invoice.company.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  invoice.company.address.line1,
                  textAlign: TextAlign.center,
                ),
                Text(invoice.company.phone, textAlign: TextAlign.center),
                if (invoice.company.gstin != null)
                  Text(
                    'GSTIN: ${invoice.company.gstin}',
                    textAlign: TextAlign.center,
                  ),
                Text(dash),
                Text('Invoice: ${invoice.number}'),
                Text('Date: ${DateFormatter.dateTime(invoice.date)}'),
                Text('Cashier: ${invoice.cashier ?? '-'}'),
                Text(dash),
                const Row(
                  children: [
                    Expanded(flex: 5, child: Text('Item')),
                    Expanded(flex: 2, child: Text('Qty')),
                    Expanded(
                      flex: 3,
                      child: Text('Price', textAlign: TextAlign.right),
                    ),
                  ],
                ),
                Text(dash),
                for (final line in totals.lines)
                  Row(
                    children: [
                      Expanded(flex: 5, child: Text(line.name)),
                      Expanded(
                        flex: 2,
                        child: Text(MoneyFormatter.plain(line.quantity)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          MoneyFormatter.plain(line.lineTotal),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                Text(dash),
                _kv('Subtotal', totals.subtotal),
                _kv('Discount', totals.discount),
                _kv('Tax', totals.tax),
                Text(dash),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.receiptInk,
                  ),
                  child: _kv('TOTAL', totals.grandTotal),
                ),
                Text(dash),
                Text('Payment: ${invoice.payment.method}'),
                _kv('Paid', invoice.payment.paidAmount),
                _kv('Change', invoice.payment.changeAmount),
                const SizedBox(height: 12),
                const Text(
                  'Thank You!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const Text('Visit Again', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String label, num value) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(MoneyFormatter.plain(value)),
      ],
    );
  }
}
