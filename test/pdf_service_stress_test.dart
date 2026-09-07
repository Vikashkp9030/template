import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/invoice_template_preview.dart';

import 'stress_invoice_fixture.dart';

/// Generates a real PDF for every template against normal/stress/edge-case
/// data. This is the authoritative "Preview" surface (`InvoicePreviewPage`
/// embeds these exact bytes), so a failure here is a Template=Preview=PDF
/// break, not just a cosmetic one.
void main() {
  final pdfService = PdfService();

  final fixtures = {
    'normal': StressInvoiceFixture.normal(),
    'stress (32 items, long text)': StressInvoiceFixture.stress(),
    'edgeCase (no optional fields)': StressInvoiceFixture.edgeCase(),
  };

  for (final template in InvoiceTemplateType.values) {
    for (final entry in fixtures.entries) {
      test('${template.name} generates a valid PDF for ${entry.key}', () async {
        final bytes = await pdfService.generateInvoice(
          invoice: entry.value,
          template: template,
        );
        expect(bytes, isNotEmpty);
        // Minimal structural sanity check: a well-formed PDF file.
        final header = String.fromCharCodes(bytes.take(5));
        expect(header, '%PDF-');
      });
    }
  }

  test('stress data (32 items) forces multiple PDF pages', () async {
    final bytes = await pdfService.generateInvoice(
      invoice: StressInvoiceFixture.stress(),
      template: InvoiceTemplateType.basic,
      paperSize: InvoicePaperSize.a5,
    );
    final content = String.fromCharCodes(bytes);
    final pageObjectCount = RegExp(r'/Type\s*/Page[^s]').allMatches(content).length;
    expect(pageObjectCount, greaterThan(1));
  });
}
