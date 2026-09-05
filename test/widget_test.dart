import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/data/dummy/dummy_invoice_data.dart';
import 'package:invoice_template_preview/data/dummy/dummy_pos_data.dart';
import 'package:invoice_template_preview/features/invoice_templates/invoice_template_type.dart';
import 'package:invoice_template_preview/features/invoice_templates/presentation/invoice_preview.dart';
import 'package:invoice_template_preview/features/thermal_templates/presentation/thermal_preview.dart';
import 'package:invoice_template_preview/features/thermal_templates/thermal_template_type.dart';
import 'package:invoice_template_preview/models/printer/thermal_paper_size.dart';

void main() {
  testWidgets('invoice templates render distinct headings', (tester) async {
    final invoice = DummyInvoiceData.invoice();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 1100,
            child: InvoicePreview(
              invoice: invoice,
              template: InvoiceTemplateType.basic,
            ),
          ),
        ),
      ),
    );
    expect(find.text('TAX INVOICE'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 1100,
            child: InvoicePreview(
              invoice: invoice,
              template: InvoiceTemplateType.standard,
            ),
          ),
        ),
      ),
    );
    expect(find.text(invoice.number), findsWidgets);
  });

  testWidgets('thermal template renders store name', (tester) async {
    final invoice = DummyPosData.order();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ThermalPreview(
            invoice: invoice,
            template: ThermalTemplateType.thermal,
            paperSize: ThermalPaperSize.mm80,
          ),
        ),
      ),
    );
    expect(find.text('SPICE GARDEN'), findsOneWidget);
    expect(find.textContaining('THANK YOU'), findsOneWidget);
  });

  testWidgets('thermal paper size changes preview width', (tester) async {
    final invoice = DummyPosData.order();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ThermalPreview(
            key: const ValueKey('58'),
            invoice: invoice,
            template: ThermalTemplateType.thermal,
            paperSize: ThermalPaperSize.mm58,
          ),
        ),
      ),
    );
    final box58 = tester.widget<SizedBox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.width == ThermalPaperSize.mm58.previewWidth,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ThermalPreview(
            key: const ValueKey('80'),
            invoice: invoice,
            template: ThermalTemplateType.thermal,
            paperSize: ThermalPaperSize.mm80,
          ),
        ),
      ),
    );
    final box80 = tester.widget<SizedBox>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.width == ThermalPaperSize.mm80.previewWidth,
      ),
    );
    expect(box58.width, ThermalPaperSize.mm58.previewWidth);
    expect(box80.width, ThermalPaperSize.mm80.previewWidth);
    expect(box80.width, greaterThan(box58.width!));
  });
}
