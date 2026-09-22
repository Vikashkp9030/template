import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/core/errors/app_exception.dart';
import 'package:invoice_template_preview/data/dummy/dummy_document_data.dart';
import 'package:invoice_template_preview/features/documents/document_fonts.dart';
import 'package:invoice_template_preview/features/documents/document_pdf_service.dart';
import 'package:invoice_template_preview/features/documents/document_template_registry.dart';
import 'package:invoice_template_preview/models/document/document_type.dart';
import 'package:invoice_template_preview/models/invoice/invoice_item_model.dart';

import 'document_test_support.dart';

void main() {
  late DocumentPdfService service;

  setUp(() {
    service = testService();
  });

  test('every document type has a template', () {
    for (final type in DocumentType.values) {
      expect(
        DocumentTemplateRegistry.templates.containsKey(type),
        isTrue,
        reason: '${type.displayName} has no registered template',
      );
    }
  });

  group('renders each reference document', () {
    for (final type in DocumentType.values) {
      test(type.displayName, () async {
        final bytes = await service.generate(DummyDocumentData.document(type));

        expect(bytes, isNotEmpty);
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');

        final geometry = DocumentTemplateRegistry.get(type).geometry;
        final sizes = pageSizes(bytes);
        expect(sizes, isNotEmpty);
        for (final size in sizes) {
          expect(size.width, closeTo(geometry.width, 0.01));
          expect(size.height, closeTo(geometry.height, 0.01));
        }
      });
    }
  });

  test('the reference data fits the page count the references use', () async {
    // Every reference is a single page except sales invoice 2, whose closing
    // sections run over.
    for (final type in DocumentType.values) {
      final bytes = await service.generate(DummyDocumentData.document(type));
      final expected = type == DocumentType.salesInvoiceTemplate2 ? 2 : 1;
      expect(
        pageCount(bytes),
        expected,
        reason: '${type.displayName} should be $expected page(s)',
      );
    }
  });

  group('long item lists paginate', () {
    for (final type in DocumentType.values) {
      test(type.displayName, () async {
        final base = DummyDocumentData.document(type);
        final items = [
          for (var i = 0; i < 60; i++)
            InvoiceItemModel(
              sku: 'SKU-$i',
              name: 'Line item number $i with a reasonably long name',
              description:
                  'A description long enough to wrap onto a second line in '
                  'every one of the eight layouts.',
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

        expect(pageCount(bytes), greaterThan(1));
      });
    }
  });

  group('rejects unusable data', () {
    test('an empty item list', () async {
      final base = DummyDocumentData.document(DocumentType.salesOrder);
      expect(
        () => service.generate(
          base.copyWith(
            invoice: base.invoice.copyWith(items: const []),
          ),
        ),
        throwsA(isA<InvoiceValidationException>()),
      );
    });

    test('a negative price', () async {
      final base = DummyDocumentData.document(DocumentType.salesOrder);
      expect(
        () => service.generate(
          base.copyWith(
            invoice: base.invoice.copyWith(
              items: const [
                InvoiceItemModel(
                  sku: 'BAD',
                  name: 'Bad line',
                  quantity: 1,
                  unitPrice: -10,
                ),
              ],
            ),
          ),
        ),
        throwsA(isA<InvoiceValidationException>()),
      );
    });
  });

  test('reports a helpful error when the fonts cannot be loaded', () async {
    final broken = DocumentPdfService(
      fontLoader: () =>
          DocumentFonts.load(loader: (_) async => throw 'no such asset'),
    );
    await expectLater(
      broken.generate(
        DummyDocumentData.document(DocumentType.salesOrder),
      ),
      throwsA(
        isA<PdfGenerationException>().having(
          (e) => e.message,
          'message',
          contains('font'),
        ),
      ),
    );
  });

  test('optional sections collapse instead of leaving gaps', () async {
    final base = DummyDocumentData.document(DocumentType.deliveryChallan);
    final stripped = base.copyWith(
      invoice: base.invoice.copyWith(notes: '', terms: ''),
      showSignature: false,
      showAmountInWords: false,
    );

    final full = await service.generate(base);
    final bare = await service.generate(stripped);

    expect(pageCount(bare), 1);
    expect(bare.length, lessThan(full.length));
  });
}
