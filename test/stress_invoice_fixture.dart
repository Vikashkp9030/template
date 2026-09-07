import 'package:invoice_template_preview/invoice_template_preview.dart';

/// Test-only data used to exercise the templates against the kind of
/// production content the brief calls out: long names/addresses, many line
/// items with long descriptions, discounts, multi-line notes/terms, and (for
/// [edgeCase]) every optional field left empty.
class StressInvoiceFixture {
  StressInvoiceFixture._();

  static InvoiceModel normal() => _invoice(itemCount: 8, longText: false, includeOptional: true);

  static InvoiceModel stress() => _invoice(itemCount: 32, longText: true, includeOptional: true);

  static InvoiceModel edgeCase() => _invoice(itemCount: 1, longText: false, includeOptional: false);

  static InvoiceModel _invoice({
    required int itemCount,
    required bool longText,
    required bool includeOptional,
  }) {
    final companyName = longText
        ? 'International Continental Manufacturing & Distribution Holdings Private Limited'
        : 'Acme Traders';
    final customerName = longText
        ? 'Mr. Alexander Bartholomew Worthington-Fitzgerald III of Worthington Global Enterprises'
        : 'Jane Doe';
    final addressLine = longText
        ? 'Unit 42B, Sky Tower Business Park, Sector 18, Phase IV, Near International Convention Centre'
        : '221B Baker Street';

    final company = CompanyModel(
      name: companyName,
      phone: '+91 9000000000',
      email: 'billing@example.com',
      website: 'https://example.com',
      address: AddressModel(
        line1: addressLine,
        city: 'Metropolis',
        state: 'Karnataka',
        country: 'India',
        pincode: '560001',
      ),
    );

    final customer = CustomerModel(
      name: customerName,
      phone: includeOptional ? '+91 9111111111' : null,
      email: includeOptional ? 'customer@example.com' : null,
      billingAddress: AddressModel(
        line1: addressLine,
        city: 'Gotham',
        state: 'Maharashtra',
        country: 'India',
        pincode: '400001',
      ),
    );

    final items = [
      for (var i = 0; i < itemCount; i++)
        InvoiceItemModel(
          sku: 'SKU-${1000 + i}',
          name: longText
              ? 'Premium Industrial Grade Stainless Steel Fastener Assembly Kit — Model ${i + 1}, Extra Long Product Name For Wrap Testing'
              : 'Product ${i + 1}',
          hsnSac: '998877',
          quantity: (i % 5) + 1,
          unitPrice: 199.5 + i,
          discount: i.isEven ? 10 : 0,
          discountType: 'AMOUNT',
          taxRate: i % 3 == 0 ? 18 : (i % 3 == 1 ? 12 : 5),
        ),
    ];

    return InvoiceModel(
      documentTitle: 'TAX INVOICE',
      number: 'INV-STRESS-0001',
      date: DateTime(2026, 1, 15),
      dueDate: includeOptional ? DateTime(2026, 2, 15) : null,
      currency: 'INR',
      company: company,
      customer: customer,
      headerDiscount: includeOptional ? 250 : 0,
      terms: includeOptional
          ? (longText
                ? 'Payment is due within thirty (30) days of the invoice date. Late payments are subject to a 2% monthly interest charge. Goods sold are non-returnable once dispatched. All disputes are subject to the jurisdiction of the Bengaluru courts only. Please quote the invoice number in all correspondence.'
                : 'Payment due within 15 days.')
          : null,
      notes: includeOptional
          ? (longText
                ? 'Thank you for your continued partnership. Please note that our warehouse will be closed for scheduled maintenance from the 20th to the 22nd of this month, which may affect delivery timelines for orders placed during that window.'
                : 'Thank you for your business.')
          : null,
      bank: includeOptional
          ? const BankDetails(
              bankName: 'Example Bank',
              accountName: 'Acme Traders',
              accountNumber: '000111222333',
              ifsc: 'EXAM0001234',
            )
          : null,
      payment: const PaymentInfo(method: 'Bank Transfer', status: 'unpaid'),
      items: items,
    );
  }
}
