import 'package:flutter/material.dart';

import '../theme/invoice_template_theme.dart';

/// Authorized-signatory line, right-aligned under a short rule in the
/// template's accent color.
class SignatureSection extends StatelessWidget {
  const SignatureSection({super.key, required this.theme});

  final InvoiceTemplateTheme theme;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            child: Divider(color: Color(theme.accent)),
          ),
          Text('Authorized Signatory', style: theme.type.bodyStrong.flutter),
        ],
      ),
    );
  }
}
