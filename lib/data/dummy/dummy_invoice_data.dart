import '../../models/invoice/address_model.dart';
import '../../models/invoice/company_model.dart';
import '../../models/invoice/customer_model.dart';
import '../../models/invoice/invoice_item_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/payment_model.dart';

/// Dummy document shaped like a POS / ERP sales invoice (INR, GST India).
class DummyInvoiceData {
  static InvoiceModel invoice() {
    const company = CompanyModel(
      name: 'Spice Garden Restaurant',
      gstin: '36AABCU9603R1ZX',
      phone: '+91 9876543210',
      email: 'accounts@spicegarden.in',
      website: 'https://spicegarden.in',
      address: AddressModel(
        line1: 'Plot 12, HITEC City',
        line2: 'Madhapur',
        city: 'Hyderabad',
        state: 'Telangana',
        country: 'India',
        pincode: '500081',
      ),
    );

    const customer = CustomerModel(
      name: 'Rahul Sharma',
      phone: '+91 9123456789',
      email: 'rahul@example.com',
      gstin: '36AAAAA1234A1Z5',
      billingAddress: AddressModel(
        line1: '12 Banjara Hills',
        city: 'Hyderabad',
        state: 'Telangana',
        country: 'India',
        pincode: '500034',
      ),
      shippingAddress: AddressModel(
        line1: 'Warehouse 4, Nacharam',
        city: 'Hyderabad',
        state: 'Telangana',
        country: 'India',
        pincode: '500076',
      ),
    );

    return InvoiceModel(
      documentTitle: 'TAX INVOICE',
      numberLabel: 'Invoice #',
      number: 'INV-2026-001',
      date: DateTime(2026, 8, 28),
      dueDate: DateTime(2026, 9, 5),
      currency: 'INR',
      company: company,
      customer: customer,
      salesperson: 'Anita Reddy',
      warehouse: 'HYD-WH-01',
      branch: 'Madhapur',
      cashier: 'Admin',
      orderNumber: 'SO-88421',
      placeOfSupply: 'Telangana (36)',
      reverseCharge: false,
      taxRegime: TaxRegime.gstIndia,
      interState: false,
      taxInclusive: false,
      terms: 'Payment due within 7 days. Goods once sold cannot be returned.',
      notes: 'Thank you for your business.',
      customerNotes: 'Please pack extra chutney.',
      bank: const BankDetails(
        bankName: 'HDFC Bank',
        accountName: 'Spice Garden Restaurant',
        accountNumber: '50200011223344',
        ifsc: 'HDFC0001234',
        upi: 'spicegarden@hdfcbank',
      ),
      payment: const PaymentInfo(
        method: 'UPI',
        status: 'partial',
        paidAmount: 500,
      ),
      items: const [
        InvoiceItemModel(
          sku: 'ITM-PBM',
          name: 'Paneer Butter Masala',
          hsnSac: '996331',
          quantity: 2,
          unit: 'NOS',
          unitPrice: 280,
          discount: 0,
          taxRate: 5,
        ),
        InvoiceItemModel(
          sku: 'ITM-NAAN',
          name: 'Butter Naan',
          hsnSac: '996331',
          quantity: 4,
          unit: 'NOS',
          unitPrice: 40,
          discount: 0,
          taxRate: 5,
        ),
        InvoiceItemModel(
          sku: 'ITM-DOSA',
          name: 'Masala Dosa',
          hsnSac: '996331',
          quantity: 1,
          unit: 'NOS',
          unitPrice: 120,
          discount: 20,
          taxRate: 5,
        ),
      ],
    );
  }
}
