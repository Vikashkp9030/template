import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
import '../../../widgets/common/invoice_bits.dart';
import '../invoice_template.dart';
import '../invoice_template_type.dart';
import '../theme/invoice_template_theme.dart';
import '../widgets/footer_section.dart';
import '../widgets/items_table_section.dart';
import '../widgets/notes_terms_section.dart';
import '../widgets/party_info_section.dart';
import '../widgets/signature_section.dart';
import '../widgets/template_scaffold.dart';
import '../widgets/totals_section.dart';

/// High-end, brand-focused layout: refined type scale, a dark summary card
/// for the grand total, and a subtle decorative corner accent. Restrained
/// on purpose — polished, not flashy.
class PremiumInvoiceTemplate implements InvoiceTemplate {
  static const theme = InvoiceTemplateThemes.premium;

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
    return TemplateScaffold(
      theme: theme,
      decoration: Positioned(
        top: 0,
        right: 0,
        width: 200,
        height: 200,
        child: CustomPaint(
          painter: _TopRightAccent(Color(theme.accent).withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LogoMark(
                company: invoice.company,
                size: 72,
                background: Color(theme.primary),
                foreground: Colors.white,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(invoice.documentTitle, style: theme.type.documentTitle.flutter),
                  Text(
                    '${invoice.numberLabel} ${invoice.number}',
                    style: theme.type.bodyStrong.flutter.copyWith(
                      fontSize: 15,
                      color: Color(theme.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          PartyInfoSection(
            theme: theme,
            columns: [
              PartyInfoColumn(
                title: 'Details',
                lines: [
                  'Issued: ${DateFormatter.display(invoice.date)}',
                  if (invoice.dueDate != null) 'Due: ${DateFormatter.display(invoice.dueDate!)}',
                ],
              ),
              PartyInfoColumn(
                title: 'From',
                lines: [
                  invoice.company.name,
                  invoice.company.address.singleLine,
                  invoice.company.email,
                ],
              ),
              PartyInfoColumn(
                title: 'To',
                lines: [
                  invoice.customer.name,
                  if (invoice.customer.billingAddress != null)
                    invoice.customer.billingAddress!.singleLine,
                  if (invoice.customer.email != null) invoice.customer.email!,
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          ItemsTableSection(theme: theme, lines: totals.lines, currency: invoice.currency),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PAYMENT INFORMATION', style: theme.type.sectionLabel.flutter),
                    const SizedBox(height: 8),
                    Text('Method: ${invoice.payment.method}', style: theme.type.body.flutter),
                    if (invoice.bank != null) ...[
                      Text('Bank: ${invoice.bank!.bankName}', style: theme.type.body.flutter),
                      Text('A/C: ${invoice.bank!.accountNumber}', style: theme.type.body.flutter),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 260,
                child: TotalsSection(theme: theme, totals: totals, currency: invoice.currency),
              ),
            ],
          ),
          if (NotesTermsSection(theme: theme, notes: invoice.notes, terms: invoice.terms)
              .hasContent) ...[
            const SizedBox(height: 32),
            NotesTermsSection(theme: theme, notes: invoice.notes, terms: invoice.terms),
          ],
          const SizedBox(height: 32),
          SignatureSection(theme: theme),
          const SizedBox(height: 24),
          FooterSection(theme: theme, company: invoice.company),
        ],
      ),
    );
  }
}

class _TopRightAccent extends CustomPainter {
  _TopRightAccent(this.color);
  final Color color;

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
