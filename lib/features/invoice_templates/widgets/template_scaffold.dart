import 'package:flutter/material.dart';

import '../theme/invoice_template_theme.dart';

/// Common page shell every invoice template renders into: background color,
/// default text style, and the theme's page margin. Keeping this in one
/// place means every template's page geometry is driven by the same
/// [InvoiceTemplateTheme.pageMargin] the PDF renderer uses.
class TemplateScaffold extends StatelessWidget {
  const TemplateScaffold({
    super.key,
    required this.theme,
    required this.child,
    this.decoration,
  });

  final InvoiceTemplateTheme theme;
  final Widget child;

  /// Optional decorative layer painted behind the content (e.g. Premium's
  /// corner accent). Callers are responsible for their own `Positioned`
  /// placement within the page-sized `Stack`.
  final Widget? decoration;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Color(theme.background),
      child: DefaultTextStyle(
        style: theme.type.body.flutter,
        child: Stack(
          children: [
            if (decoration case final d?) ...[d],
            Padding(
              padding: EdgeInsets.all(theme.pageMargin),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
