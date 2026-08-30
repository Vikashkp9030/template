import '../../models/invoice/address_model.dart';
import '../../models/invoice/company_model.dart';
import '../../models/invoice/customer_model.dart';
import '../../models/invoice/invoice_item_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/payment_model.dart';

class DummyInvoiceData {
  static InvoiceModel invoice() {
    const company = CompanyModel(
      name: 'ABC Technologies Pvt Ltd',
      gstin: '36ABCDE1234F1Z5',
      phone: '+91 9876543210',
      email: 'billing@abctech.com',
      website: 'https://abctech.com',
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
      number: 'INV-2026-001',
      date: DateTime(2026, 8, 28),
      dueDate: DateTime(2026, 9, 5),
      currency: 'INR',
      company: company,
      customer: customer,
      salesperson: 'Anita Reddy',
      warehouse: 'HYD-WH-01',
      cashier: 'Admin',
      orderNumber: 'SO-88421',
      placeOfSupply: 'Telangana (36)',
      reverseCharge: false,
      taxRegime: TaxRegime.gstIndia,
      interState: false,
      terms: 'Payment due within 7 days. Goods once sold cannot be returned.',
      notes: 'Thank you for your business.',
      bank: const BankDetails(
        bankName: 'HDFC Bank',
        accountName: 'ABC Technologies Pvt Ltd',
        accountNumber: '50200011223344',
        ifsc: 'HDFC0001234',
        upi: 'abctech@hdfcbank',
      ),
      payment: const PaymentInfo(
        method: 'UPI',
        status: 'partial',
        paidAmount: 50000,
      ),
      items: const [
        InvoiceItemModel(
          sku: 'LAP-001',
          name: 'Laptop',
          hsnSac: '8471',
          quantity: 1,
          unitPrice: 65000,
          discount: 2000,
          taxRate: 18,
        ),
        InvoiceItemModel(
          sku: 'MOU-001',
          name: 'Wireless Mouse',
          hsnSac: '8471',
          quantity: 2,
          unitPrice: 1200,
          discount: 100,
          taxRate: 18,
        ),
        InvoiceItemModel(
          sku: 'KBD-002',
          name: 'Mechanical Keyboard',
          hsnSac: '8471',
          quantity: 1,
          unitPrice: 4500,
          discount: 0,
          taxRate: 18,
        ),
      ],
    );
  }
}
