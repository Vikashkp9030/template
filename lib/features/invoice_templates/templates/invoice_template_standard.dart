import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
import '../../../widgets/common/invoice_bits.dart';
import '../invoice_template.dart';
import '../invoice_template_type.dart';

class StandardInvoiceTemplate implements InvoiceTemplate {
  @override
  InvoiceTemplateType get type => InvoiceTemplateType.standard;

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
    const accentColor = Color(0xFF2563EB);

    return ColoredBox(
      color: Colors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 11,
          height: 1.4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LogoMark(
                    company: invoice.company,
                    size: 64,
                    background: accentColor,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.company.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(invoice.company.address.singleLine),
                        Text('Tel: ${invoice.company.phone} | ${invoice.company.email}'),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          invoice.documentTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text('${invoice.numberLabel} ${invoice.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _infoBox('Bill To', [
                      invoice.customer.name,
                      if (invoice.customer.billingAddress != null)
                        invoice.customer.billingAddress!.singleLine,
                      if (invoice.customer.phone != null) 'Phone: ${invoice.customer.phone}',
                    ], accentColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _infoBox('Details', [
                      'Date: ${DateFormatter.display(invoice.date)}',
                      'Method: ${invoice.payment.method}',
                      'Status: ${invoice.payment.status}',
                    ], accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _itemTable(invoice, totals, accentColor),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (invoice.terms != null) ...[
                          const Text(
                            'TERMS',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(invoice.terms!, style: const TextStyle(fontSize: 10)),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 240,
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
                        const Divider(thickness: 1.5, height: 24),
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
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      const SizedBox(width: 160, child: Divider(color: accentColor)),
                      const Text('Authorized Signatory', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String title, List<String> lines, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          ...lines.map((l) => Text(l, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _itemTable(InvoiceModel invoice, InvoiceTotals totals, Color accent) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: accent,
          ),
          children: [
            for (final h in ['Description', 'Qty', 'Unit Price', 'Amount'])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Text(
                  h.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        for (final item in totals.lines)
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(MoneyFormatter.plain(item.quantity)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(MoneyFormatter.format(item.unitPrice, currency: invoice.currency)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(
                  MoneyFormatter.format(item.lineTotal, currency: invoice.currency),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
