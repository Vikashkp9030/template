import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/core/helpers/invoice_calculator.dart';
import 'package:invoice_template_preview/data/dummy/dummy_invoice_data.dart';
import 'package:invoice_template_preview/features/invoice_templates/invoice_template_registry.dart';
import 'package:invoice_template_preview/features/invoice_templates/invoice_template_type.dart';
import 'package:invoice_template_preview/models/invoice/invoice_item_model.dart';
import 'package:invoice_template_preview/features/invoice_templates/presentation/invoice_preview.dart';
import 'package:invoice_template_preview/models/printer/paper_size.dart';

void main() {
  _embedding();

  final base = DummyInvoiceData.invoice();

  for (final count in [3, 30]) {
    for (final type in InvoiceTemplateType.values) {
      testWidgets('$type renders $count items without overflow', (tester) async {
        final invoice = base.copyWith(
          items: [
            for (var i = 0; i < count; i++)
              InvoiceItemModel(
                sku: 'SKU-${i + 1}',
                name: 'Item ${i + 1}',
                quantity: 2,
                unitPrice: 100,
                taxRate: base.items.first.taxRate,
              ),
          ],
        );
        final totals = InvoiceCalculator().calculate(invoice);
        const paper = InvoicePaperSize.a4;

        final pages = InvoiceTemplateRegistry.get(type).buildPages(
          invoice: invoice,
          totals: totals,
          paperSize: paper,
        );

        expect(pages, isNotEmpty, reason: 'must produce at least one page');

        tester.view.physicalSize = Size(paper.width, paper.height);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        for (final page in pages) {
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(size: Size(paper.width, paper.height)),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SizedBox(
                  width: paper.width,
                  height: paper.height,
                  child: page,
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
        }

        debugPrint('$type / $count items -> ${pages.length} page(s)');
      });
    }
  }
}

/// Regression: `InvoicePreview` must survive a caller that hands it a box
/// smaller than the paper, which is how restro_admin embeds it (it once
/// overflowed by 462px because pages are a fixed paper height).
void _embedding() {
  testWidgets('InvoicePreview fits a box smaller than the page', (tester) async {
    final invoice = DummyInvoiceData.invoice();

    for (final type in InvoiceTemplateType.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                // Smaller than A4 (794x1123) in both axes.
                constraints: const BoxConstraints(maxWidth: 900, maxHeight: 661),
                child: InvoicePreview(invoice: invoice, template: type),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$type overflowed');
    }
  });
}
