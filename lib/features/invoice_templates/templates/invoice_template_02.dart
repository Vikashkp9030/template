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

class ModernInvoiceTemplate implements InvoiceTemplate {
  @override
  InvoiceTemplateType get type => InvoiceTemplateType.modern;

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
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(36, 40, 36, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    invoice.company.name.toUpperCase(),
                    style: const TextStyle(
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.modernMuted,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: invoice.payment.status),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                invoice.number,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w200,
                  color: AppColors.modernAccent,
                  height: 1,
                ),
              ),
              Text(
                'Issued ${DateFormatter.display(invoice.date)}'
                '${invoice.dueDate != null ? '  ·  Due ${DateFormatter.display(invoice.dueDate!)}' : ''}',
                style: const TextStyle(color: AppColors.modernMuted),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CUSTOMER',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.modernMuted,
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
                          if (invoice.customer.phone != null)
                            Text(invoice.customer.phone!),
                        ],
                      ),
                    ),
                    QrPlaceholder(caption: invoice.bank?.upi ?? 'Pay now'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    for (final line in totals.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${line.sku}  ·  ${line.quantity} × ${MoneyFormatter.format(line.unitPrice, currency: invoice.currency)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.modernMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              MoneyFormatter.format(
                                line.lineTotal,
                                currency: invoice.currency,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.modernAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
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
                        const Divider(color: Colors.white54),
                        AmountLine(
                          label: 'Total',
                          value: totals.grandTotal,
                          currency: invoice.currency,
                          emphasis: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                invoice.notes ?? invoice.terms ?? '',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.modernMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
