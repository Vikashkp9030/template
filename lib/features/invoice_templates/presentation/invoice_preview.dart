import 'package:flutter/material.dart';

import '../../../core/helpers/invoice_calculator.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/printer/paper_size.dart';
import '../invoice_template_registry.dart';
import '../invoice_template_type.dart';

class InvoicePreview extends StatelessWidget {
  const InvoicePreview({
    super.key,
    required this.invoice,
    required this.template,
    this.paperSize = InvoicePaperSize.a4,
    this.calculator,
  });

  final InvoiceModel invoice;
  final InvoiceTemplateType template;
  final InvoicePaperSize paperSize;
  final InvoiceCalculator? calculator;

  @override
  Widget build(BuildContext context) {
    final totals = (calculator ?? InvoiceCalculator()).calculate(invoice);
    return InvoiceTemplateRegistry.get(template).build(
      context: context,
      invoice: invoice,
      totals: totals,
      paperSize: paperSize,
    );
  }
}

class InvoiceTemplateRenderer extends InvoicePreview {
  const InvoiceTemplateRenderer({
    super.key,
    required super.invoice,
    required super.template,
    super.paperSize,
    super.calculator,
  });
}
