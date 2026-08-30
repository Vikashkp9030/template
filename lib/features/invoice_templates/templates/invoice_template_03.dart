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

class GstInvoiceTemplate implements InvoiceTemplate {
  @override
  InvoiceTemplateType get type => InvoiceTemplateType.gst;

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
          fontSize: 10.5,
          color: Colors.black87,
          height: 1.3,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.gstBand,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${invoice.documentTitle}  ·  GST',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.company.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(invoice.company.address.singleLine),
                        Text('GSTIN: ${invoice.company.gstin ?? '-'}'),
                        Text('Phone: ${invoice.company.phone}'),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${invoice.numberLabel} ${invoice.number}'),
                      Text('Date: ${DateFormatter.display(invoice.date)}'),
                      if (invoice.dueDate != null)
                        Text(
                          'Due Date: ${DateFormatter.display(invoice.dueDate!)}',
                        ),
                      Text('Place of Supply: ${invoice.placeOfSupply ?? '-'}'),
                      Text(
                        'Reverse Charge: ${invoice.reverseCharge ? 'Yes' : 'No'}',
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: AppColors.gstRule),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _party(
                      'Details of Receiver (Bill to)',
                      invoice.customer.name,
                      invoice.customer.gstin,
                      invoice.customer.billingAddress?.singleLine,
                    ),
                  ),
                  Expanded(
                    child: _party(
                      'Details of Consignee (Ship to)',
                      invoice.customer.name,
                      invoice.customer.gstin,
                      invoice.customer.shippingAddress?.singleLine ??
                          invoice.customer.billingAddress?.singleLine,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.black54, width: 0.6),
                columnWidths: const {
                  0: FlexColumnWidth(0.4),
                  1: FlexColumnWidth(2.2),
                  2: FlexColumnWidth(0.9),
                  3: FlexColumnWidth(0.7),
                  4: FlexColumnWidth(1.1),
                  5: FlexColumnWidth(1.1),
                  6: FlexColumnWidth(1.0),
                  7: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFDBEAFE)),
                    children: [
                      for (final h in [
                        '#',
                        'Description',
                        'HSN/SAC',
                        'Qty',
                        'Taxable',
                        'Tax %',
                        'Tax Amt',
                        'Amount',
                      ])
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            h,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                    ],
                  ),
                  for (var i = 0; i < totals.lines.length; i++)
                    TableRow(
                      children: [
                        _cell('${i + 1}'),
                        _cell(totals.lines[i].name),
                        _cell(totals.lines[i].hsnSac ?? '-'),
                        _cell(MoneyFormatter.plain(totals.lines[i].quantity)),
                        _cell(
                          MoneyFormatter.plain(
                            totals.lines[i].discountedAmount,
                          ),
                        ),
                        _cell(MoneyFormatter.plain(totals.lines[i].taxRate)),
                        _cell(MoneyFormatter.plain(totals.lines[i].taxAmount)),
                        _cell(MoneyFormatter.plain(totals.lines[i].lineTotal)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Table(
                      border: TableBorder.all(
                        color: Colors.black45,
                        width: 0.6,
                      ),
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFDBEAFE),
                          ),
                          children: [
                            for (final h in [
                              'Tax',
                              'Taxable Amt',
                              'Rate',
                              'Tax Amt',
                            ])
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  h,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        for (final tax in totals.taxLines)
                          TableRow(
                            children: [
                              _cell(tax.label),
                              _cell(MoneyFormatter.plain(tax.taxableAmount)),
                              _cell('${tax.rate.toStringAsFixed(1)}%'),
                              _cell(MoneyFormatter.plain(tax.amount)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 220,
                    child: Column(
                      children: [
                        AmountLine(
                          label: 'Taxable Amount',
                          value: totals.subtotal - totals.discount,
                          currency: invoice.currency,
                        ),
                        AmountLine(
                          label: 'Total Tax',
                          value: totals.tax,
                          currency: invoice.currency,
                        ),
                        const Divider(),
                        AmountLine(
                          label: 'Invoice Total',
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
              if (invoice.bank != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bank: ${invoice.bank!.bankName}  A/C: ${invoice.bank!.accountNumber}  IFSC: ${invoice.bank!.ifsc}',
                  ),
                ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Terms: ${invoice.terms ?? '-'}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _party(String title, String name, String? gstin, String? address) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(name),
          Text('GSTIN: ${gstin ?? '-'}'),
          Text(address ?? '-'),
        ],
      ),
    );
  }

  Widget _cell(String text) =>
      Padding(padding: const EdgeInsets.all(4), child: Text(text));
}
