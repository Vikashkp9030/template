import 'package:flutter/material.dart';

import '../theme/invoice_template_theme.dart';

enum PartyInfoVariant {
  /// Bare label + lines, no background (Basic, Premium).
  plain,

  /// Accent-bordered card with a muted background (Enterprise).
  card,
}

class PartyInfoColumn {
  const PartyInfoColumn({required this.title, required this.lines});

  final String title;
  final List<String> lines;
}

/// Renders the From/Bill-To/Details party columns shared by all three
/// templates. Column count and per-template chrome vary, but wrapping,
/// spacing, and typography always come from [theme].
class PartyInfoSection extends StatelessWidget {
  const PartyInfoSection({
    super.key,
    required this.theme,
    required this.columns,
    this.variant = PartyInfoVariant.plain,
  });

  final InvoiceTemplateTheme theme;
  final List<PartyInfoColumn> columns;
  final PartyInfoVariant variant;

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: _column(columns[i])),
        ],
      ],
    );
  }

  Widget _column(PartyInfoColumn column) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(column.title.toUpperCase(), style: theme.type.sectionLabel.flutter),
        const SizedBox(height: 6),
        for (final line in column.lines)
          Text(
            line,
            style: theme.type.bodyStrong.flutter,
            softWrap: true,
          ),
      ],
    );

    if (variant == PartyInfoVariant.plain) return content;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(theme.surfaceMuted),
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: Color(theme.accent), width: 3)),
      ),
      child: content,
    );
  }
}
