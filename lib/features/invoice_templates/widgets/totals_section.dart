import 'package:flutter/material.dart';

import '../../../models/invoice/invoice_totals.dart';
import '../../../widgets/common/invoice_bits.dart';
import '../theme/invoice_template_theme.dart';

/// Subtotal → discount → tax → grand total block shared by all three
/// templates. Renders as a plain list, or (when the theme defines a
/// [InvoiceTemplateTheme.grandTotalCardBackground]) inside a filled card —
/// Premium's style — without duplicating the row logic per template.
class TotalsSection extends StatelessWidget {
  const TotalsSection({
    super.key,
    required this.theme,
    required this.totals,
    required this.currency,
  });

  final InvoiceTemplateTheme theme;
  final InvoiceTotals totals;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isCard = theme.grandTotalCardBackground != null;
    final rows = <Widget>[
      AmountLine(
        label: 'Subtotal',
        value: totals.subtotal,
        currency: currency,
        labelStyle: theme.type.totalLabel.flutter,
        valueStyle: theme.type.totalValue.flutter,
      ),
      if (totals.discount > 0)
        AmountLine(
          label: 'Discount',
          value: -totals.discount,
          currency: currency,
          labelStyle: theme.type.totalLabel.flutter,
          valueStyle: theme.type.totalValue.flutter,
        ),
      AmountLine(
        label: 'Tax',
        value: totals.tax,
        currency: currency,
        labelStyle: theme.type.totalLabel.flutter,
        valueStyle: theme.type.totalValue.flutter,
      ),
    ];

    final grandTotal = AmountLine(
      label: 'Grand Total',
      value: totals.grandTotal,
      currency: currency,
      labelStyle: theme.type.grandTotalLabel.flutter,
      valueStyle: theme.type.grandTotalValue.flutter,
    );

    if (!isCard) {
      return Column(
        children: [
          ...rows,
          Divider(thickness: 1.5, height: 24, color: Color(theme.divider)),
          grandTotal,
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(theme.grandTotalCardBackground!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ...rows,
          const SizedBox(height: 12),
          Divider(color: Color(theme.grandTotalCardForeground!).withValues(alpha: 0.24)),
          const SizedBox(height: 12),
          grandTotal,
        ],
      ),
    );
  }
}
