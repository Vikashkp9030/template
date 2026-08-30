import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/data/yaml/yaml_parser.dart';
import 'package:invoice_template_preview/features/invoice_templates/invoice_template_type.dart';
import 'package:invoice_template_preview/features/invoice_templates/presentation/invoice_preview.dart';
import 'package:invoice_template_preview/features/printing/pdf_service.dart';
import 'package:invoice_template_preview/models/printer/paper_size.dart';

void main() {
  testWidgets('YAML → InvoiceModel → template preview → PDF', (tester) async {
    const yaml = '''
template: professional
paperSize: a4
company:
  name: "ABC Technologies Pvt Ltd"
  gstin: "36ABCDE1234F1Z5"
  phone: "+91 9876543210"
  email: "billing@abctech.com"
  address:
    line1: "Madhapur"
    city: "Hyderabad"
    state: "Telangana"
    country: "India"
    pincode: "500081"
customer:
  name: "Rahul Sharma"
invoice:
  number: "INV-2026-001"
  date: "2026-08-28"
  currency: "INR"
items:
  - sku: "LAP-001"
    name: "Laptop"
    quantity: 1
    unitPrice: 65000
    discount: 2000
    taxRate: 18
''';
    final parsed = const YamlParser().parse(yaml);
    expect(parsed.invoice.number, 'INV-2026-001');
    final template = InvoiceTemplateTypeX.parse(parsed.templateKey);
    final paper = InvoicePaperSizeX.parse(parsed.paperSizeKey);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 1100,
            child: InvoicePreview(
              invoice: parsed.invoice,
              template: template,
              paperSize: paper,
            ),
          ),
        ),
      ),
    );
    expect(find.text('TAX INVOICE'), findsOneWidget);
    expect(find.textContaining('Laptop'), findsWidgets);

    final bytes = await PdfService().generateInvoice(
      invoice: parsed.invoice,
      template: template,
      paperSize: paper,
    );
    expect(bytes.length, greaterThan(100));
    expect(bytes[0], 0x25);
  });
}
