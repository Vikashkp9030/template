import 'package:flutter/material.dart';

import '../../../core/helpers/invoice_calculator.dart';
import '../../../models/invoice/invoice_model.dart';
import '../../../models/printer/thermal_paper_size.dart';
import '../thermal_template_registry.dart';
import '../thermal_template_type.dart';

class ThermalPreview extends StatelessWidget {
  const ThermalPreview({
    super.key,
    required this.invoice,
    required this.template,
    this.paperSize = ThermalPaperSize.mm80,
    this.calculator,
  });

  final InvoiceModel invoice;
  final ThermalTemplateType template;
  final ThermalPaperSize paperSize;
  final InvoiceCalculator? calculator;

  @override
  Widget build(BuildContext context) {
    final totals = (calculator ?? InvoiceCalculator()).calculate(invoice);
    return ThermalTemplateRegistry.get(template).build(
      context: context,
      invoice: invoice,
      totals: totals,
      paperSize: paperSize,
    );
  }
}
