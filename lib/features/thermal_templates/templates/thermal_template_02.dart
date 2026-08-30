import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/thermal_paper_size.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../../../widgets/common/invoice_bits.dart';
import '../thermal_template.dart';
import '../thermal_template_type.dart';

class ModernThermalTemplate implements ThermalTemplate {
  @override
  ThermalTemplateType get type => ThermalTemplateType.modern;

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
    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        width: paperSize.previewWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.receiptInk,
              height: 1.3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    LogoMark(
                      company: invoice.company,
                      size: 36,
                      background: AppColors.modernAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.company.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            invoice.company.phone,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Customer  ${invoice.customer.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Order  ${invoice.orderNumber ?? invoice.number}'),
                Text(DateFormatter.dateTime(invoice.date)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                for (final line in totals.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${line.name}\n${line.quantity} × ${MoneyFormatter.plain(line.unitPrice)}  disc ${MoneyFormatter.plain(line.discount)}',
                          ),
                        ),
                        Text(
                          MoneyFormatter.plain(line.lineTotal),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                _row('Tax', totals.tax),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.receiptInk, width: 1.4),
                  ),
                  child: _row('TOTAL', totals.grandTotal, bold: true),
                ),
                Text('Paid via ${invoice.payment.method}'),
                const SizedBox(height: 10),
                Center(
                  child: QrImageView(
                    data: invoice.orderNumber ?? invoice.number,
                    size: 72,
                  ),
                ),
                const Text(
                  'Scan to pay / feedback',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thanks for stopping by.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, num value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(MoneyFormatter.plain(value), style: style),
      ],
    );
  }
}
