import 'package:flutter/material.dart';

import '../../../models/invoice/company_model.dart';
import '../theme/invoice_template_theme.dart';

/// Running footer: company contact line under a hairline divider. The PDF
/// renderer adds real page numbers here (via `pw.MultiPage`'s footer
/// callback, which knows the true page count); the on-screen live template
/// is a single continuous flow with no discrete pages to number, so it
/// omits the page indicator rather than showing a fake one.
class FooterSection extends StatelessWidget {
  const FooterSection({super.key, required this.theme, required this.company});

  final InvoiceTemplateTheme theme;
  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    final parts = [
      company.name,
      company.phone,
      company.email,
    ].where((e) => e.trim().isNotEmpty).join('  •  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: Color(theme.divider)),
        const SizedBox(height: 6),
        Text(parts, textAlign: TextAlign.center, style: theme.type.footer.flutter),
      ],
    );
  }
}
