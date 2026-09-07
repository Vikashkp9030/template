import 'package:flutter/material.dart';

import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/invoice_totals.dart';
import '../../models/printer/paper_size.dart';
import 'invoice_template_type.dart';

abstract class InvoiceTemplate {
  InvoiceTemplateType get type;
  String get name;
  String get description;

  /// One widget per printed page, each sized to fill [paperSize].
  ///
  /// This is the single source of truth for both renderers: the on-screen
  /// preview stacks these, and `PdfService` rasterizes the same widgets into
  /// PDF pages. A template is therefore impossible to change in one place and
  /// not the other.
  List<Widget> buildPages({
    required InvoiceModel invoice,
    required InvoiceTotals totals,
    required InvoicePaperSize paperSize,
  });

  /// On-screen preview: the same pages, stacked with a gap between them.
  Widget build({
    required BuildContext context,
    required InvoiceModel invoice,
    required InvoiceTotals totals,
    required InvoicePaperSize paperSize,
  }) {
    final pages = buildPages(
      invoice: invoice,
      totals: totals,
      paperSize: paperSize,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, page) in pages.indexed) ...[
          if (index > 0) const SizedBox(height: 24),
          SizedBox(
            width: paperSize.width,
            height: paperSize.height,
            child: page,
          ),
        ],
      ],
    );
  }
}
