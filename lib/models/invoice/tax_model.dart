enum TaxKind { cgst, sgst, igst, vat, none }

class TaxLine {
  const TaxLine({
    required this.kind,
    required this.label,
    required this.rate,
    required this.taxableAmount,
    required this.amount,
    this.groupRate,
  });

  final TaxKind kind;
  final String label;

  /// Rate this line itself was charged at — half of [groupRate] for the
  /// CGST/SGST halves of an Indian GST split.
  final double rate;

  /// Rate of the tax the line was split out of, when it was split. Printed
  /// documents label the halves with the combined rate ("CGST (12.00%)"), so
  /// they need the original alongside [rate].
  final double? groupRate;

  final double taxableAmount;
  final double amount;
}

class LineComputation {
  const LineComputation({
    required this.item,
    required this.gross,
    required this.discount,
    required this.discountedAmount,
    required this.taxAmount,
    required this.lineTotal,
  });

  final Object item;
  final double gross;
  final double discount;
  final double discountedAmount;
  final double taxAmount;
  final double lineTotal;
}
