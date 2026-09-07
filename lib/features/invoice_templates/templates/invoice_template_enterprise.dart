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

/// Corporate, structured layout with strong information hierarchy: a
/// branded header band, accent-bordered info cards, and a filled table
/// header — sophisticated without becoming visually heavy.
class EnterpriseInvoiceTemplate implements InvoiceTemplate {
  static const theme = InvoiceTemplateThemes.enterprise;

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
    return TemplateScaffold(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LogoMark(
                company: invoice.company,
                size: 60,
                background: Color(theme.accent),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.company.name, style: theme.type.bodyStrong.flutter.copyWith(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(invoice.company.address.singleLine, style: theme.type.body.flutter),
                    Text('Tel: ${invoice.company.phone} | ${invoice.company.email}', style: theme.type.body.flutter),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(theme.accent).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(invoice.documentTitle, style: theme.type.documentTitle.flutter),
                    const SizedBox(height: 2),
                    Text('${invoice.numberLabel} ${invoice.number}', style: theme.type.bodyStrong.flutter),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          PartyInfoSection(
            theme: theme,
            variant: PartyInfoVariant.card,
            columns: [
              PartyInfoColumn(
                title: 'Bill To',
                lines: [
                  invoice.customer.name,
                  if (invoice.customer.billingAddress != null)
                    invoice.customer.billingAddress!.singleLine,
                  if (invoice.customer.phone != null) 'Phone: ${invoice.customer.phone}',
                ],
              ),
              PartyInfoColumn(
                title: 'Details',
                lines: [
                  'Date: ${DateFormatter.display(invoice.date)}',
                  if (invoice.dueDate != null) 'Due: ${DateFormatter.display(invoice.dueDate!)}',
                  'Method: ${invoice.payment.method}',
                  'Status: ${invoice.payment.status}',
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          ItemsTableSection(theme: theme, lines: totals.lines, currency: invoice.currency),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NotesTermsSection(theme: theme, notes: invoice.notes, terms: invoice.terms),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 240,
                child: TotalsSection(theme: theme, totals: totals, currency: invoice.currency),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SignatureSection(theme: theme),
          const SizedBox(height: 24),
          FooterSection(theme: theme, company: invoice.company),
        ],
      ),
    );
  }
}
