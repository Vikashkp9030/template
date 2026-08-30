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

class PremiumInvoiceTemplate implements InvoiceTemplate {
  @override
  InvoiceTemplateType get type => InvoiceTemplateType.premium;

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
      color: AppColors.premiumPaper,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.premiumInk,
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: Row(
              children: [
                LogoMark(
                  company: invoice.company,
                  background: AppColors.premiumGold,
                  foreground: Colors.white,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.company.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        invoice.company.address.city.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.premiumGold,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'INVOICE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 6,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PREPARED FOR',
                            style: TextStyle(
                              letterSpacing: 1.5,
                              fontSize: 10,
                              color: AppColors.premiumGold,
                            ),
                          ),
                          Text(
                            invoice.customer.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (invoice.customer.email != null)
                            Text(invoice.customer.email!),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          invoice.number,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(DateFormatter.display(invoice.date)),
                        if (invoice.dueDate != null)
                          Text(
                            'Due ${DateFormatter.display(invoice.dueDate!)}',
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Table(
                  children: [
                    TableRow(
                      children: [
                        for (final h in [
                          'Description',
                          'Qty',
                          'Rate',
                          'Amount',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              h,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.premiumGold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (final line in totals.lines)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '${line.name}\n${line.sku}',
                              style: const TextStyle(height: 1.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(MoneyFormatter.plain(line.quantity)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              MoneyFormatter.format(
                                line.unitPrice,
                                currency: invoice.currency,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (invoice.bank != null) ...[
                            const Text(
                              'BANK DETAILS',
                              style: TextStyle(
                                letterSpacing: 1.2,
                                fontSize: 10,
                                color: AppColors.premiumGold,
                              ),
                            ),
                            Text(
                              '${invoice.bank!.bankName} · ${invoice.bank!.accountNumber}',
                            ),
                            Text('IFSC ${invoice.bank!.ifsc}'),
                            if (invoice.bank!.upi != null)
                              Text('UPI ${invoice.bank!.upi}'),
                          ],
                          const SizedBox(height: 16),
                          const SizedBox(
                            width: 160,
                            child: Divider(color: AppColors.premiumInk),
                          ),
                          const Text('Authorized Signature'),
                        ],
                      ),
                    ),
                    Container(
                      width: 240,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.premiumInk,
                          width: 1.2,
                        ),
                      ),
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
                          AmountLine(
                            label: 'Total due',
                            value: totals.balanceAmount,
                            currency: invoice.currency,
                            emphasis: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
