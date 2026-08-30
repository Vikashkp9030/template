import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/core/errors/app_exception.dart';
import 'package:invoice_template_preview/core/helpers/invoice_calculator.dart';
import 'package:invoice_template_preview/data/dummy/dummy_invoice_data.dart';
import 'package:invoice_template_preview/data/yaml/yaml_parser.dart';
import 'package:invoice_template_preview/models/invoice/invoice_item_model.dart';

void main() {
  group('YamlParser', () {
    const parser = YamlParser();

    test('parses a valid invoice document', () {
      const raw = '''
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
  phone: "+91 9123456789"
  email: "rahul@example.com"
  gstin: "36AAAAA1234A1Z5"
invoice:
  number: "INV-2026-001"
  date: "2026-08-28"
  dueDate: "2026-09-05"
  currency: "INR"
items:
  - sku: "LAP-001"
    name: "Laptop"
    quantity: 1
    unitPrice: 65000
    discount: 2000
    taxRate: 18
''';
      final parsed = parser.parse(raw);
      expect(parsed.invoice.number, 'INV-2026-001');
      expect(parsed.invoice.company.name, 'ABC Technologies Pvt Ltd');
      expect(parsed.invoice.items, hasLength(1));
    });

    test('rejects invalid YAML', () {
      expect(
        () => parser.parse(':::not yaml'),
        throwsA(isA<YamlParseException>()),
      );
    });

    test('rejects empty product list', () {
      const raw = '''
company:
  name: "A"
  phone: "1"
  email: "a@b.c"
  address:
    line1: "x"
    city: "y"
    state: "z"
    country: "India"
    pincode: "1"
customer:
  name: "C"
invoice:
  number: "1"
  date: "2026-08-28"
items: []
''';
      expect(
        () => parser.parse(raw),
        throwsA(isA<InvoiceValidationException>()),
      );
    });

    test('rejects invalid dates', () {
      const raw = '''
company:
  name: "A"
  phone: "1"
  email: "a@b.c"
  address:
    line1: "x"
    city: "y"
    state: "z"
    country: "India"
    pincode: "1"
customer:
  name: "C"
invoice:
  number: "1"
  date: "not-a-date"
items:
  - sku: "A"
    name: "B"
    quantity: 1
    unitPrice: 1
''';
      expect(
        () => parser.parse(raw),
        throwsA(isA<InvoiceValidationException>()),
      );
    });
  });

  group('InvoiceCalculator', () {
    final calculator = InvoiceCalculator();

    test('computes line and invoice totals', () {
      final invoice = DummyInvoiceData.invoice();
      final totals = calculator.calculate(invoice);
      // 65000 + 2400 + 4500 = 71900
      expect(totals.subtotal, 71900);
      expect(totals.discount, 2100);
      expect(totals.tax, closeTo(12564, 0.01));
      expect(totals.grandTotal, closeTo(82364, 0.01));
      expect(totals.paidAmount, 50000);
      expect(totals.balanceAmount, closeTo(32364, 0.01));
    });

    test('splits CGST and SGST for intra-state GST', () {
      final totals = calculator.calculate(DummyInvoiceData.invoice());
      expect(totals.taxLines.any((t) => t.label.startsWith('CGST')), isTrue);
      expect(totals.taxLines.any((t) => t.label.startsWith('SGST')), isTrue);
    });

    test('uses IGST for inter-state GST', () {
      final invoice = DummyInvoiceData.invoice().copyWith(interState: true);
      final totals = calculator.calculate(invoice);
      expect(totals.taxLines.every((t) => t.label.startsWith('IGST')), isTrue);
    });

    test('rejects invalid tax values', () {
      final invoice = DummyInvoiceData.invoice().copyWith(
        items: const [
          InvoiceItemModel(
            sku: 'X',
            name: 'Bad',
            quantity: 1,
            unitPrice: 10,
            taxRate: 140,
          ),
        ],
      );
      expect(
        () => calculator.calculate(invoice),
        throwsA(isA<InvoiceValidationException>()),
      );
    });
  });
}
