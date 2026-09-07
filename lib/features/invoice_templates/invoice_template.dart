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
  ///
  /// A page is a fixed [InvoicePaperSize] and will not shrink, so this scales
  /// the stack down to whatever width the caller allows and scrolls it
  /// vertically. That keeps the widget embeddable in an arbitrary box — a
  /// caller does not have to know the paper dimensions to avoid an overflow.
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.hasBoundedWidth
            ? (constraints.maxWidth / paperSize.width).clamp(0.0, 1.0)
            : 1.0;

        final stack = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, page) in pages.indexed) ...[
              if (index > 0) SizedBox(height: 24 * scale),
              SizedBox(
                width: paperSize.width * scale,
                height: paperSize.height * scale,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox(
                    width: paperSize.width,
                    height: paperSize.height,
                    child: page,
                  ),
                ),
              ),
            ],
          ],
        );

        // A scroll view needs a bounded main axis; when the caller gives us
        // unbounded height (inside an unconstrained InteractiveViewer, say)
        // the stack is already free to be as tall as it likes.
        if (!constraints.hasBoundedHeight) return stack;

        return SingleChildScrollView(child: Center(child: stack));
      },
    );
  }
}
