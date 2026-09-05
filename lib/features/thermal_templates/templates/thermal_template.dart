import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/thermal_paper_size.dart';
import '../thermal_template.dart';
import '../thermal_template_type.dart';

class ThermalPrinterTemplate implements ThermalTemplate {
  @override
  ThermalTemplateType get type => ThermalTemplateType.thermal;

  @override
  String get name => type.title;

  @override
  String get description => type.description;

  @override
  Widget build({
    required BuildContext context,
    required InvoiceModel invoice,
    required ThermalPaperSize paperSize,
    required InvoiceTotals totals,
  }) {
    return Container(
      width: paperSize.previewWidth,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontFamily: 'monospace',
          height: 1.2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              invoice.company.name.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(invoice.company.address.singleLine, textAlign: TextAlign.center),
            Text('TEL: ${invoice.company.phone}', textAlign: TextAlign.center),
            const Text('--------------------------------'),
            Text(invoice.documentTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('NO: ${invoice.number}'),
            Text('DATE: ${DateFormatter.display(invoice.date)}'),
            const Text('--------------------------------'),
            const Row(
              children: [
                Expanded(flex: 3, child: Text('ITEM')),
                Expanded(child: Text('QTY', textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right)),
              ],
            ),
            const Text('--------------------------------'),
            for (final item in totals.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: Text(item.name)),
                    Expanded(child: Text(MoneyFormatter.plain(item.quantity), textAlign: TextAlign.right)),
                    Expanded(
                      flex: 2,
                      child: Text(
                        MoneyFormatter.plain(item.lineTotal),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            const Text('--------------------------------'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  MoneyFormatter.format(totals.grandTotal, currency: invoice.currency),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Text('--------------------------------'),
            const SizedBox(height: 10),
            Text('PAYMENT: ${invoice.payment.method}'),
            const SizedBox(height: 20),
            const Text('THANK YOU FOR YOUR BUSINESS!', textAlign: TextAlign.center),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
