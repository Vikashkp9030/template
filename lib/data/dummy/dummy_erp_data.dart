import '../../models/invoice/address_model.dart';
import '../../models/invoice/company_model.dart';
import '../../models/invoice/customer_model.dart';
import '../../models/invoice/invoice_item_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/payment_model.dart';

class DummyErpData {
  static InvoiceModel invoice() {
    return InvoiceModel(
      number: 'ERP-2026-441',
      date: DateTime(2026, 8, 28),
      dueDate: DateTime(2026, 9, 12),
      currency: 'INR',
      salesperson: 'Kiran Rao',
      warehouse: 'HYD-WH-01',
      placeOfSupply: 'Maharashtra (27)',
      reverseCharge: false,
      taxRegime: TaxRegime.gstIndia,
      interState: true,
      terms: 'Interest @ 18% p.a. after due date.',
      notes: 'Dispatch via dedicated cargo.',
      company: const CompanyModel(
        name: 'ABC Technologies Pvt Ltd',
        gstin: '36ABCDE1234F1Z5',
        phone: '+91 9876543210',
        email: 'billing@abctech.com',
        website: 'https://abctech.com',
        address: AddressModel(
          line1: 'Madhapur',
          city: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
          pincode: '500081',
        ),
      ),
      customer: const CustomerModel(
        name: 'Nova Retail LLP',
        phone: '+91 9811100110',
        email: 'accounts@novaretail.in',
        gstin: '27BBBBB5678B1Z9',
        billingAddress: AddressModel(
          line1: 'Andheri East',
          city: 'Mumbai',
          state: 'Maharashtra',
          country: 'India',
          pincode: '400069',
        ),
        shippingAddress: AddressModel(
          line1: 'Bhiwandi DC',
          city: 'Thane',
          state: 'Maharashtra',
          country: 'India',
          pincode: '421302',
        ),
      ),
      bank: const BankDetails(
        bankName: 'ICICI Bank',
        accountName: 'ABC Technologies Pvt Ltd',
        accountNumber: '004401234567',
        ifsc: 'ICIC0000044',
        upi: 'abctech@icici',
      ),
      payment: const PaymentInfo(
        method: 'NEFT',
        status: 'unpaid',
        paidAmount: 0,
      ),
      items: const [
        InvoiceItemModel(
          sku: 'MON-27',
          name: '27-inch Monitor',
          hsnSac: '8528',
          quantity: 4,
          unitPrice: 18500,
          discount: 2000,
          taxRate: 18,
        ),
        InvoiceItemModel(
          sku: 'HDD-01',
          name: '1TB External SSD',
          hsnSac: '8471',
          quantity: 6,
          unitPrice: 7200,
          discount: 600,
          taxRate: 18,
        ),
      ],
    );
  }
}
