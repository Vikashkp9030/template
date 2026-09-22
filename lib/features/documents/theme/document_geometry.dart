import 'package:pdf/pdf.dart';

/// Page size and content box of a reference layout.
///
/// The references are not on the ISO/ANSI nominal sizes — the A4 exports
/// measure 595.42 x 841.69pt and the Letter exports 612 x 792pt — so the
/// exact numbers are reproduced here rather than using [PdfPageFormat.a4].
class DocumentGeometry {
  const DocumentGeometry({
    required this.width,
    required this.height,
    required this.left,
    required this.right,
  });

  final double width;
  final double height;

  /// Left edge of the content box, in points from the left of the page.
  final double left;

  /// Right edge of the content box, in points from the left of the page.
  final double right;

  double get contentWidth => right - left;

  double get rightMargin => width - right;

  PdfPageFormat get pageFormat => PdfPageFormat(width, height);

  /// A4 as the Zoho exporter emits it.
  static const a4 = DocumentGeometry(
    width: 595.42,
    height: 841.69,
    left: 45.60,
    right: 560.63,
  );

  /// A4 for the two bordered templates, whose content box runs to the frame
  /// rather than to the wider margin the spreadsheet templates use.
  static const a4Bordered = DocumentGeometry(
    width: 595.42,
    height: 841.69,
    left: 39.60,
    right: 566.63,
  );

  /// US Letter as the Zoho exporter emits it.
  static const letter = DocumentGeometry(
    width: 612,
    height: 792,
    left: 45.72,
    right: 561.60,
  );
}
