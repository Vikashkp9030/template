import '../../models/document/document_model.dart';
import '../../models/document/document_type.dart';
import '../../models/invoice/address_model.dart';
import '../../models/invoice/company_model.dart';
import '../../models/invoice/customer_model.dart';
import '../../models/invoice/invoice_item_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/payment_model.dart';

/// Sample documents that reproduce the reference PDFs under `context/`.
///
/// Used by the preview screen and by the render tests that compare generated
/// output against those references. It is sample data only — nothing in the
/// rendering or calculation path reads from here.
class DummyDocumentData {
  const DummyDocumentData._();

  static final DateTime documentDate = DateTime(2026, 9, 21);
  static final DateTime linkedInvoiceDate = DateTime(2018, 1, 1);

  static CompanyModel company() => const CompanyModel(
    name: 'JUST foods',
    phone: '9958465592',
    email: 'devashishpore@gmail.com',
    gstin: '07AAAPL9876U1Z1',
    address: AddressModel(line1: 'Delhi', country: 'India'),
  );

  static CustomerModel customer() => const CustomerModel(
    name: 'Rob & Joe Traders',
    gstin: '33GSPTN0372G1ZC',
    billingAddress: AddressModel(
      line1: '34, Riche Street',
      city: 'Chennai',
      state: 'Tamil Nadu',
      pincode: '631603',
      country: 'India',
    ),
    shippingAddress: AddressModel(
      line1: '34, Riche Street',
      city: 'Chennai',
      state: 'Tamil Nadu',
      pincode: '631603',
      country: 'India',
    ),
  );

  static List<InvoiceItemModel> items({double? returnedQuantity}) => [
    InvoiceItemModel(
      sku: 'BRO-001',
      name: 'Brochure Design',
      description: 'Brochure Design Single Sided Color',
      hsnSac: '52161559',
      quantity: 1,
      unit: 'Nos',
      unitPrice: 300,
      taxRate: 12,
      returnedQuantity: returnedQuantity,
    ),
    InvoiceItemModel(
      sku: 'WEB-001',
      name: 'Web Design Packages(Template) - Basic',
      description: 'Custom Themes for your business. Inclusive of 10 hours '
          'of marketing and annual training',
      hsnSac: '52161559',
      quantity: 1,
      unit: 'Nos',
      unitPrice: 250,
      taxRate: 12,
      returnedQuantity: returnedQuantity,
    ),
    InvoiceItemModel(
      sku: 'ADS-001',
      name: 'Print Ad - Basic - Color',
      description: 'Print Ad 1/8 size Color',
      hsnSac: '52161559',
      quantity: 1,
      unit: 'Nos',
      unitPrice: 80,
      taxRate: 12,
      returnedQuantity: returnedQuantity,
    ),
  ];

  static InvoiceModel invoice({
    required String number,
    required String documentTitle,
    double? returnedQuantity,
    String? notes = 'Thanks for your business.',
    String? terms,
  }) {
    return InvoiceModel(
      number: number,
      documentTitle: documentTitle,
      date: documentDate,
      currency: 'INR',
      company: company(),
      customer: customer(),
      items: items(returnedQuantity: returnedQuantity),
      payment: const PaymentInfo(method: 'credit'),
      placeOfSupply: 'Tamil Nadu',
      notes: notes,
      terms: terms,
    );
  }

  /// Default terms text, which names the settings page of the document type.
  static String terms(DocumentType type) =>
      "Your company's Terms and Conditions will be displayed here. You can "
      'add it in the ${type.preferencesPageName} Preferences page under '
      'Settings.';

  static DocumentModel document(DocumentType type) {
    return switch (type) {
      DocumentType.creditNoteTemplate1 ||
      DocumentType.creditNoteTemplate2 => DocumentModel(
        type: type,
        invoice: invoice(
          number: 'CN-17',
          documentTitle: 'CREDIT NOTE',
          terms: terms(type),
        ),
        referenceNumber: 'SO-17',
        linkedInvoiceNumber: 'INV-1',
        linkedInvoiceDate: linkedInvoiceDate,
        subject: '',
        description: 'Description',
        creditsUsed: 100,
      ),
      DocumentType.salesInvoiceTemplate1 ||
      DocumentType.salesInvoiceTemplate2 => DocumentModel(
        type: type,
        invoice: invoice(
          number: 'INV-17',
          documentTitle: 'TAX INVOICE',
          terms: terms(type),
        ).copyWith(dueDate: documentDate),
        referenceNumber: 'SO-17',
        paymentTerms: 'Due on Receipt',
        subject: '',
        description: 'Description',
        paymentRetention: 10,
        paymentMade: 100,
        showPaymentOptions: true,
      ),
      DocumentType.deliveryChallan => DocumentModel(
        type: type,
        invoice: invoice(
          number: 'INV-17',
          documentTitle: 'DELIVERY CHALLAN',
          terms: terms(type),
        ),
        referenceNumber: 'SO-17',
        challanType: 'Supply on Approval',
      ),
      DocumentType.salesOrder => DocumentModel(
        type: type,
        invoice: invoice(
          number: 'SO-17',
          documentTitle: 'SALES ORDER',
          terms: terms(type),
        ),
        referenceNumber: 'SO-17',
        salesOrderNumber: 'SO-17',
        orderDate: documentDate,
        expectedShipmentDate: documentDate,
        deliveryMethod: 'UPS',
      ),
      DocumentType.packagingSlip => DocumentModel(
        type: type,
        invoice: invoice(
          number: 'PKG-17',
          documentTitle: 'PACKAGE',
          notes: null,
        ),
        packageNumber: 'PKG-17',
        packageDate: documentDate,
        orderDate: documentDate,
        salesOrderNumber: 'SO-17',
        showAmountInWords: false,
        showSignature: false,
      ),
      DocumentType.salesReturn => DocumentModel(
        type: type,
        invoice: invoice(
          number: 'RMA-17',
          documentTitle: 'SALES RETURN',
          returnedQuantity: 2,
          notes: null,
        ),
        returnNumber: 'RMA-17',
        returnReason: 'Reason Name',
        showAmountInWords: false,
        showSignature: false,
      ),
    };
  }
}
