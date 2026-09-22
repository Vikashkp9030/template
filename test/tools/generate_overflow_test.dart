@Tags(['tool'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/data/dummy/dummy_document_data.dart';
import 'package:invoice_template_preview/models/document/document_type.dart';
import 'package:invoice_template_preview/models/invoice/invoice_item_model.dart';

import '../documents/document_test_support.dart';

/// Writes the awkward variants of each template — a long item list, and a
/// document with every optional section removed — so pagination and section
/// collapsing can be inspected by eye.
void main() {
  test('generate overflow documents', () async {
    final outDir = Directory('build/documents/overflow')
      ..createSync(recursive: true);
    final service = testService();

    for (final type in DocumentType.values) {
      final base = DummyDocumentData.document(type);
      final items = [
        for (var i = 0; i < 24; i++)
          InvoiceItemModel(
            sku: 'SKU-$i',
            name: 'Line item number ${i + 1} with a reasonably long name',
            description: 'A description long enough to wrap onto a second '
                'line in every one of the eight layouts.',
            hsnSac: '52161559',
            quantity: 2,
            unit: 'Nos',
            unitPrice: 125.5 + i,
            taxRate: 12,
          ),
      ];
      final bytes = await service.generate(
        base.copyWith(invoice: base.invoice.copyWith(items: items)),
      );
      File('${outDir.path}/${type.name}.pdf').writeAsBytesSync(bytes);
    }
  });

  test('generate documents with the optional sections removed', () async {
    final outDir = Directory('build/documents/minimal')
      ..createSync(recursive: true);
    final service = testService();

    for (final type in DocumentType.values) {
      final base = DummyDocumentData.document(type);
      final bytes = await service.generate(
        base.copyWith(
          invoice: base.invoice.copyWith(notes: '', terms: ''),
          showAmountInWords: false,
          showPaymentOptions: false,
        ),
      );
      File('${outDir.path}/${type.name}.pdf').writeAsBytesSync(bytes);
    }
  });
}
