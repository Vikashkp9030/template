import 'package:flutter/material.dart';

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
    const primaryColor = Color(0xFF0F172A);
    const accentColor = Color(0xFF8B5CF6);

    return ColoredBox(
      color: Colors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: primaryColor,
          fontSize: 11,
          height: 1.5,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              width: 200,
              height: 200,
              child: CustomPaint(painter: _TopRightAccent(accentColor.withValues(alpha: 0.1))),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LogoMark(
                        company: invoice.company,
                        size: 80,
                        background: primaryColor,
                        foreground: Colors.white,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            invoice.documentTitle,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                              letterSpacing: -1.0,
                            ),
                          ),
                          Text(
                            'INV-${invoice.number}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _section('DETAILS', [
                          'ISSUED: ${DateFormatter.display(invoice.date)}',
                          if (invoice.dueDate != null) 'DUE: ${DateFormatter.display(invoice.dueDate!)}',
                        ], accentColor),
                      ),
                      Expanded(
                        child: _section('FROM', [
                          invoice.company.name.toUpperCase(),
                          invoice.company.address.singleLine,
                          invoice.company.email,
                        ], accentColor),
                      ),
                      Expanded(
                        child: _section('TO', [
                          invoice.customer.name.toUpperCase(),
                          if (invoice.customer.billingAddress != null)
                            invoice.customer.billingAddress!.singleLine,
                          if (invoice.customer.email != null) invoice.customer.email!,
                        ], accentColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  _buildTable(invoice, totals, accentColor),
                  const SizedBox(height: 48),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PAYMENT INFORMATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: accentColor)),
                            const SizedBox(height: 8),
                            Text('METHOD: ${invoice.payment.method}'),
                            if (invoice.bank != null) ...[
                              Text('BANK: ${invoice.bank!.bankName}'),
                              Text('A/C: ${invoice.bank!.accountNumber}'),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _summaryRow('SUBTOTAL', totals.subtotal, invoice.currency, Colors.white70),
                              _summaryRow('TAX', totals.tax, invoice.currency, Colors.white70),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white24),
                              const SizedBox(height: 12),
                              _summaryRow('GRAND TOTAL', totals.grandTotal, invoice.currency, Colors.white, isTotal: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<String> lines, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: accent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...lines.map((l) => Text(l, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
      ],
    );
  }

  Widget _buildTable(InvoiceModel invoice, InvoiceTotals totals, Color accent) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(5),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.2), width: 1)),
          ),
          children: [
            for (final h in ['DESCRIPTION', 'QTY', 'PRICE', 'AMOUNT'])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(
                  h,
                  style: TextStyle(fontWeight: FontWeight.w900, color: accent, fontSize: 9, letterSpacing: 1.0),
                ),
              ),
          ],
        ),
        for (final item in totals.lines)
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Text(MoneyFormatter.plain(item.quantity)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Text(MoneyFormatter.format(item.unitPrice, currency: invoice.currency)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Text(
                  MoneyFormatter.format(item.lineTotal, currency: invoice.currency),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _summaryRow(String label, double value, String currency, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            color: color,
            fontSize: isTotal ? 12 : 9,
          ),
        ),
        Text(
          MoneyFormatter.format(value, currency: currency),
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            color: color,
            fontSize: isTotal ? 18 : 12,
          ),
        ),
      ],
    );
  }
}

class _TopRightAccent extends CustomPainter {
  final Color color;
  _TopRightAccent(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, 0)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.2, size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
