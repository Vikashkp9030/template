import 'package:flutter/material.dart';

import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/invoice_totals.dart';
import '../../models/printer/paper_size.dart';
import 'invoice_template_type.dart';

abstract class InvoiceTemplate {
  InvoiceTemplateType get type;
  String get name;
  String get description;

  Widget build({
    required BuildContext context,
    required InvoiceModel invoice,
    required InvoiceTotals totals,
    required InvoicePaperSize paperSize,
  });
}
