import '../../../models/invoice/invoice_totals.dart';
import 'document_format.dart';
import 'modern_sections.dart';

/// Tax summary rows, labelled the way the references label them.
class TaxLabels {
  const TaxLabels._();

  /// The references label each half of an Indian GST split with the combined
  /// rate of the tax it was split from — "CGST (12.00%)" against a 6% half —
  /// so the group rate is used wherever the calculator recorded one.
  static String label(TaxLineTotal tax) {
    final group = tax.groupRate;
    if (group == null) return tax.label;
    final kind = tax.label.split(' ').first;
    return '$kind (${group.toStringAsFixed(2)}%)';
  }

  static List<TotalRow> rows(List<TaxLineTotal> taxLines) => [
    for (final tax in taxLines)
      TotalRow(label(tax), DocumentFormat.amount(tax.amount)),
  ];
}
