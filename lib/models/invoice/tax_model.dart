enum TaxKind { cgst, sgst, igst, vat, none }

class TaxLine {
  const TaxLine({
    required this.kind,
    required this.label,
    required this.rate,
    required this.taxableAmount,
    required this.amount,
  });

  final TaxKind kind;
  final String label;
  final double rate;
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
