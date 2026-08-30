import 'package:flutter/material.dart';

import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/invoice_totals.dart';
import '../../models/printer/thermal_paper_size.dart';
import 'thermal_template_type.dart';

abstract class ThermalTemplate {
  ThermalTemplateType get type;
  String get name;
  String get description;

  Widget build({
    required BuildContext context,
    required InvoiceModel invoice,
    required InvoiceTotals totals,
    required ThermalPaperSize paperSize,
  });
}
