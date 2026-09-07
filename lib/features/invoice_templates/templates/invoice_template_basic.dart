import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../../../models/printer/paper_size.dart';
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

/// Minimal, restrained layout for everyday business documents: no color
/// blocks or decoration, just clear hierarchy and generous whitespace.
class BasicInvoiceTemplate implements InvoiceTemplate {
  static const theme = InvoiceTemplateThemes.basic;

  @override
  InvoiceTemplateType get type => InvoiceTemplateType.basic;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.documentTitle.toUpperCase(),
                    style: theme.type.documentTitle.flutter,
                  ),
                  const SizedBox(height: 8),
                  Text('${invoice.numberLabel} ${invoice.number}', style: theme.type.body.flutter),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('DATE', style: theme.type.sectionLabel.flutter),
                  Text(DateFormatter.display(invoice.date), style: theme.type.body.flutter),
                  if (invoice.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Text('DUE', style: theme.type.sectionLabel.flutter),
                    Text(DateFormatter.display(invoice.dueDate!), style: theme.type.body.flutter),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          PartyInfoSection(
            theme: theme,
            columns: [
              PartyInfoColumn(
                title: 'From',
                lines: [
                  invoice.company.name,
                  invoice.company.address.singleLine,
                  'Phone: ${invoice.company.phone}',
                ],
              ),
              PartyInfoColumn(
                title: 'Bill To',
                lines: [
                  invoice.customer.name,
                  if (invoice.customer.billingAddress != null)
                    invoice.customer.billingAddress!.singleLine,
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          ItemsTableSection(theme: theme, lines: totals.lines, currency: invoice.currency),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220,
              child: TotalsSection(theme: theme, totals: totals, currency: invoice.currency),
            ),
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
