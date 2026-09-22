class InvoiceItemModel {
  const InvoiceItemModel({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.hsnSac,
    this.unit = 'NOS',
    this.discount = 0,
    this.discountType = 'AMOUNT',
    this.taxRate = 0,
    this.freeQuantity = 0,
    this.description,
    this.returnedQuantity,
  });

  final String sku;
  final String name;
  final String? hsnSac;
  final double quantity;
  final String unit;
  final double unitPrice;

  /// Line discount. Interpreted with [discountType]:
  /// `AMOUNT` = total rupees off the line; `PERCENT` = % of qty × rate.
  final double discount;
  final String discountType;
  final double taxRate;
  final double freeQuantity;
  final String? description;

  /// Quantity coming back on a sales return, which a return document prints
  /// instead of [quantity]. It does not affect pricing — the credited amount
  /// stays the one the original line was billed at.
  final double? returnedQuantity;

  double get gross => quantity * unitPrice;

  double get discountAmount {
    if (discountType.toUpperCase() == 'PERCENT') {
      return gross * discount / 100;
    }
    return discount;
  }
}
