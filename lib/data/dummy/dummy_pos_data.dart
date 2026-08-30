import '../../models/invoice/address_model.dart';
import '../../models/invoice/company_model.dart';
import '../../models/invoice/customer_model.dart';
import '../../models/invoice/invoice_item_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/payment_model.dart';

class DummyPosData {
  static InvoiceModel order() {
    return InvoiceModel(
      number: 'INV-10001',
      date: DateTime(2026, 8, 28, 14, 32),
      currency: 'INR',
      cashier: 'Admin',
      orderNumber: 'POS-10001',
      taxRegime: TaxRegime.gstIndia,
      interState: false,
      notes: 'Thank You! Visit Again',
      terms: 'No returns on food items.',
      company: const CompanyModel(
        name: 'ABC STORE',
        gstin: '36ABCDE1234F1Z5',
        phone: '+91 9876543210',
        email: 'store@abc.com',
        address: AddressModel(
          line1: 'Madhapur',
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          pincode: '500081',
        ),
      ),
      customer: const CustomerModel(
        name: 'Walk-in Customer',
        phone: '+91 9000000000',
      ),
      payment: const PaymentInfo(
        method: 'CASH',
        status: 'paid',
        paidAmount: 700,
        changeAmount: 51,
      ),
      items: const [
        InvoiceItemModel(
          sku: 'BRG-01',
          name: 'Burger',
          quantity: 2,
          unitPrice: 100,
          taxRate: 18,
        ),
        InvoiceItemModel(
          sku: 'PZA-01',
          name: 'Pizza',
          quantity: 1,
          unitPrice: 250,
          discount: 20,
          taxRate: 18,
        ),
        InvoiceItemModel(
          sku: 'COF-01',
          name: 'Coffee',
          quantity: 2,
          unitPrice: 60,
          taxRate: 18,
        ),
      ],
    );
  }
}
