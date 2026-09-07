import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/core/helpers/invoice_calculator.dart';
import 'package:invoice_template_preview/data/dummy/dummy_invoice_data.dart';
import 'package:invoice_template_preview/features/invoice_templates/invoice_template_registry.dart';
import 'package:invoice_template_preview/features/invoice_templates/invoice_template_type.dart';
import 'package:invoice_template_preview/models/invoice/invoice_item_model.dart';
import 'package:invoice_template_preview/models/printer/paper_size.dart';

void main() {
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
