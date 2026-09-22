// Imports the barrel and nothing else, the way a consuming app does — this is
// the surface `admin_restro` depends on via pubspec, so a missing export here
// breaks their build rather than ours.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/invoice_template_preview.dart';

void main() {
  test('a consumer can generate a document through the barrel alone', () async {
    final invoice = InvoiceModel(
      number: 'INV-17',
      documentTitle: 'TAX INVOICE',
      date: DateTime(2026, 9, 21),
      currency: 'INR',
      company: const CompanyModel(
        name: 'Restro Admin',
        phone: '9958465592',
        email: 'billing@example.com',
        gstin: '07AAAPL9876U1Z1',
        address: AddressModel(line1: 'Delhi', country: 'India'),
      ),
      customer: const CustomerModel(name: 'Table 4'),
      items: const [
        InvoiceItemModel(
          sku: 'ITM-1',
          name: 'Paneer Tikka',
          quantity: 2,
          unitPrice: 240,
          taxRate: 5,
        ),
      ],
      payment: const PaymentInfo(method: 'upi'),
    );

    final service = DocumentPdfService(
      fontLoader: () => DocumentFonts.load(
        loader: (key) async =>
            File(key).readAsBytesSync().buffer.asByteData(),
      ),
    );

    for (final type in DocumentType.values) {
      final bytes = await service.generate(
        DocumentModel(type: type, invoice: invoice),
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    }
  });

  test('every document type and its geometry are reachable', () {
    for (final type in DocumentType.values) {
      expect(type.displayName, isNotEmpty);
      expect(DocumentTemplateRegistry.get(type).geometry.width, greaterThan(0));
    }
    expect(AmountInWords.convert(705.60), contains('Seven Hundred Five'));
  });
}
