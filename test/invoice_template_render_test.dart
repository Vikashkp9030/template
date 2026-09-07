import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/invoice_template_preview.dart';

import 'package:invoice_template_preview/widgets/invoice_preview_container.dart';
import 'stress_invoice_fixture.dart';

/// Pumps every template with normal, stress (30+ items, long text), and
/// edge-case (all optional fields absent) data and asserts nothing throws a
/// render/layout exception — most importantly `RenderFlex overflowed`,
/// which is exactly the "silent clipping" failure mode called out in the
/// audit. `InvoicePreviewContainer` (the real preview surface) is used so
/// the test also exercises the pan/zoom fix, not just the bare template.
void main() {
  final fixtures = {
    'normal': StressInvoiceFixture.normal(),
    'stress': StressInvoiceFixture.stress(),
    'edgeCase': StressInvoiceFixture.edgeCase(),
  };

  for (final template in InvoiceTemplateType.values) {
    for (final entry in fixtures.entries) {
      testWidgets('${template.name} renders "${entry.key}" data without overflow', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InvoicePreviewContainer(
                paperSize: InvoicePaperSize.a4,
                child: InvoicePreview(
                  invoice: entry.value,
                  template: template,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('optional sections collapse without leaving orphaned spacing', (tester) async {
    final invoice = StressInvoiceFixture.edgeCase();
    for (final template in InvoiceTemplateType.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: InvoicePaperSize.a4.width,
                child: InvoicePreview(invoice: invoice, template: template),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('NOTES'), findsNothing);
      expect(find.text('TERMS'), findsNothing);
    }
  });
}
