import 'tax_model.dart';

class InvoiceTotals {
  const InvoiceTotals({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceAmount,
    required this.lines,
    required this.taxLines,
  });

  final double subtotal;
  final double discount;
  final double tax;
  final double grandTotal;
  final double paidAmount;
  final double balanceAmount;
  final List<LineTotal> lines;
  final List<TaxLineTotal> taxLines;
}

class LineTotal {
  const LineTotal({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.gross,
    required this.discount,
    required this.discountedAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.lineTotal,
    this.hsnSac,
  });

  final String sku;
  final String name;
  final String? hsnSac;
  final double quantity;
  final double unitPrice;
  final double gross;
  final double discount;
  final double discountedAmount;
  final double taxRate;
  final double taxAmount;
  final double lineTotal;
}

class TaxLineTotal {
  const TaxLineTotal({
    required this.label,
    required this.rate,
    required this.taxableAmount,
    required this.amount,
    this.kind = TaxKind.none,
    this.groupRate,
  });

  final String label;
  final double rate;

  /// Rate of the tax this line was split out of; see [TaxLine.groupRate].
  final double? groupRate;

  final TaxKind kind;
  final double taxableAmount;
  final double amount;
}
