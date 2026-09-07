import 'package:flutter/material.dart';

import '../theme/invoice_template_theme.dart';

/// Notes + terms block. Each half collapses independently when its text is
/// null/empty, and the whole section collapses (no orphaned spacing) when
/// both are absent — callers should wrap the call site's `SizedBox` gap in
/// the same null-check rather than always reserving space for it.
class NotesTermsSection extends StatelessWidget {
  const NotesTermsSection({
    super.key,
    required this.theme,
    this.notes,
    this.terms,
  });

  final InvoiceTemplateTheme theme;
  final String? notes;
  final String? terms;

  bool get hasContent => (notes?.isNotEmpty ?? false) || (terms?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    if (!hasContent) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (notes != null && notes!.isNotEmpty) ...[
          Text('NOTES', style: theme.type.sectionLabel.flutter),
          const SizedBox(height: 4),
          Text(notes!, style: theme.type.body.flutter, softWrap: true),
        ],
        if (notes != null && notes!.isNotEmpty && terms != null && terms!.isNotEmpty)
          const SizedBox(height: 12),
        if (terms != null && terms!.isNotEmpty) ...[
          Text('TERMS', style: theme.type.sectionLabel.flutter),
          const SizedBox(height: 4),
          Text(terms!, style: theme.type.body.flutter, softWrap: true),
        ],
      ],
    );
  }
}
