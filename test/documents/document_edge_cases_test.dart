import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/data/dummy/dummy_document_data.dart';
import 'package:invoice_template_preview/models/document/document_model.dart';
import 'package:invoice_template_preview/models/document/document_type.dart';
import 'package:invoice_template_preview/models/invoice/address_model.dart';
import 'package:invoice_template_preview/models/invoice/company_model.dart';
import 'package:invoice_template_preview/models/invoice/customer_model.dart';
import 'package:invoice_template_preview/models/invoice/invoice_item_model.dart';
import 'package:invoice_template_preview/models/invoice/payment_model.dart';

import 'document_test_support.dart';

/// The layouts are measured against reference documents with one particular
/// shape of data. These exercise the shapes real data will take instead:
/// fields left empty, fields far longer than the reference's, and amounts far
/// larger.
void main() {
  final service = testService();

  /// Only the fields a document cannot do without.
  DocumentModel minimal(DocumentType type) {
    final base = DummyDocumentData.document(type);
    return DocumentModel(
      type: type,
      invoice: base.invoice.copyWith(
        company: const CompanyModel(
          name: 'A',
          phone: '',
          email: '',
          address: AddressModel(line1: 'X', country: ''),
        ),
        customer: const CustomerModel(name: 'B'),
        items: const [
          InvoiceItemModel(
            sku: 'S',
            name: 'Item',
            quantity: 1,
            unitPrice: 1,
            unit: '',
          ),
        ],
        payment: const PaymentInfo(method: 'cash'),
        notes: '',
        terms: '',
      ),
    );
  }

  /// Every field far longer, and every amount far larger, than the reference's.
  DocumentModel oversized(DocumentType type) {
    final base = DummyDocumentData.document(type);
    const longLine =
        'Unit 14B, Second Phase Industrial Estate, Off Grand Trunk Road';
    return base.copyWith(
      invoice: base.invoice.copyWith(
        company: CompanyModel(
          name: 'Kanakadurga Integrated Foods and Beverages Private Limited',
          phone: '+91 99584 65592 / +91 99584 65593',
          email: 'accounts.receivable.department@kanakadurgafoods.example.com',
          gstin: '07AAAPL9876U1Z1',
          website: 'https://www.kanakadurgafoods.example.com/invoicing',
          address: const AddressModel(
            line1: longLine,
            line2: 'Behind the old textile mill, Sector 44',
            city: 'Greater Noida West',
            state: 'Uttar Pradesh',
            pincode: '201318',
          ),
        ),
        customer: CustomerModel(
          name: 'Rob & Joe Traders and Distribution Partners LLP',
          gstin: '33GSPTN0372G1ZC',
          billingAddress: const AddressModel(
            line1: longLine,
            city: 'Chennai',
            state: 'Tamil Nadu',
            pincode: '631603',
          ),
          shippingAddress: const AddressModel(
            line1: longLine,
            city: 'Coimbatore',
            state: 'Tamil Nadu',
            pincode: '641045',
          ),
        ),
        items: [
          for (var i = 0; i < 3; i++)
            InvoiceItemModel(
              sku: 'SKU-$i',
              name:
                  'Fully automatic continuous-feed packaging line, model '
                  'KDF-${9000 + i}, with spare parts kit',
              description:
                  'Includes installation, commissioning, operator training '
                  'and a thirty-six month on-site warranty covering parts '
                  'and labour.',
              hsnSac: '84224000',
              quantity: 12.5,
              unit: 'Nos',
              unitPrice: 987654.321,
              taxRate: 18,
            ),
        ],
        terms: List.filled(
          6,
          'Payment is due within thirty days of the invoice date and '
          'carries interest at 18% per annum thereafter.',
        ).join(' '),
        notes: 'Thank you for your continued business over many years.',
      ),
      subject: 'Annual supply agreement, third amendment',
      description: 'Supply of packaging machinery under contract KDF/2026/114',
      creditsUsed: 1000000,
      paymentMade: 2500000,
      paymentRetention: 125000,
    );
  }

  for (final type in DocumentType.values) {
    group(type.displayName, () {
      test('renders with only the required fields', () async {
        final bytes = await service.generate(minimal(type));
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
        expect(pageCount(bytes), 1);
      });

      test('renders with long text and crore-scale amounts', () async {
        final bytes = await service.generate(oversized(type));
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
        expect(pageCount(bytes), greaterThanOrEqualTo(1));
      });

      test('keeps the reference page size whatever the data', () async {
        for (final document in [minimal(type), oversized(type)]) {
          final bytes = await service.generate(document);
          final expected = DummyDocumentData.document(type);
          final reference = pageSizes(await service.generate(expected)).first;
          for (final size in pageSizes(bytes)) {
            expect(size.width, closeTo(reference.width, 0.01));
            expect(size.height, closeTo(reference.height, 0.01));
          }
        }
      });
    });
  }
}
