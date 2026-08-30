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

class ProfessionalInvoiceTemplate implements InvoiceTemplate {
  @override
  InvoiceTemplateType get type => InvoiceTemplateType.professional;

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
          color: Color(0xFF1F2937),
          fontSize: 11,
          height: 1.35,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LogoMark(company: invoice.company, size: 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.company.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.professionalHeader,
                            ),
                          ),
                          Text(invoice.company.address.singleLine),
                          Text(
                            'Phone: ${invoice.company.phone}  •  ${invoice.company.email}',
                          ),
                          if (invoice.company.gstin != null)
                            Text('GSTIN: ${invoice.company.gstin}'),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          invoice.documentTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.professionalHeader,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text('${invoice.numberLabel} ${invoice.number}'),
                        Text('Date: ${DateFormatter.display(invoice.date)}'),
                        if (invoice.dueDate != null)
                          Text(
                            'Due: ${DateFormatter.display(invoice.dueDate!)}',
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 4, color: AppColors.professionalHeader),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _box('Bill To', [
                        invoice.customer.name,
                        if (invoice.customer.gstin != null)
                          'GSTIN: ${invoice.customer.gstin}',
                        if (invoice.customer.phone != null)
                          invoice.customer.phone!,
                        if (invoice.customer.email != null)
                          invoice.customer.email!,
                        if (invoice.customer.billingAddress != null)
                          invoice.customer.billingAddress!.singleLine,
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _box('Payment', [
                        'Method: ${invoice.payment.method}',
                        'Status: ${invoice.payment.status}',
                        if (invoice.bank != null) ...[
                          invoice.bank!.bankName,
                          'A/C ${invoice.bank!.accountNumber}',
                          'IFSC ${invoice.bank!.ifsc}',
                        ],
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _table(invoice, totals),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        invoice.terms ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: Column(
                        children: [
                          AmountLine(
                            label: 'Subtotal',
                            value: totals.subtotal,
                            currency: invoice.currency,
                          ),
                          AmountLine(
                            label: 'Discount',
                            value: totals.discount,
                            currency: invoice.currency,
                          ),
                          AmountLine(
                            label: 'Tax',
                            value: totals.tax,
                            currency: invoice.currency,
                          ),
                          const Divider(),
                          AmountLine(
                            label: 'Grand Total',
                            value: totals.grandTotal,
                            currency: invoice.currency,
                            emphasis: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: Text(invoice.notes ?? '')),
                    Column(
                      children: [
                        const SizedBox(
                          height: 36,
                          width: 160,
                          child: Divider(),
                        ),
                        const Text('Authorized Signature'),
                        Text(
                          invoice.company.name,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _box(String title, List<String> lines) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 10,
              color: AppColors.professionalAccent,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          for (final line in lines) Text(line),
        ],
      ),
    );
  }

  Widget _table(InvoiceModel invoice, InvoiceTotals totals) {
    return Table(
      border: TableBorder.all(color: const Color(0xFFCBD5E1)),
      columnWidths: const {
        0: FlexColumnWidth(3.2),
        1: FlexColumnWidth(0.8),
        2: FlexColumnWidth(1.1),
        3: FlexColumnWidth(1.1),
        4: FlexColumnWidth(1.0),
        5: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppColors.professionalHeader),
          children: [
            for (final h in [
              'Item',
              'Qty',
              'Unit price',
              'Discount',
              'Tax',
              'Total',
            ])
              Padding(
                padding: const EdgeInsets.all(6),
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
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text('${line.name}\n${line.sku}'),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(MoneyFormatter.plain(line.quantity)),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  MoneyFormatter.format(
                    line.unitPrice,
                    currency: invoice.currency,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  MoneyFormatter.format(
                    line.discount,
                    currency: invoice.currency,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text('${line.taxRate.toStringAsFixed(0)}%'),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  MoneyFormatter.format(
                    line.lineTotal,
                    currency: invoice.currency,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
