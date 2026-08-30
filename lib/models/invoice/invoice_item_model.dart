class InvoiceItemModel {
  const InvoiceItemModel({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.hsnSac,
    this.unit = 'NOS',
    this.discount = 0,
    this.taxRate = 0,
  });

  final String sku;
  final String name;
  final String? hsnSac;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double discount;
  final double taxRate;

  double get gross => quantity * unitPrice;
}
