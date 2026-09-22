import 'package:pdf/pdf.dart';

/// Exact colours sampled from the reference PDFs' content streams.
class DocumentPalette {
  const DocumentPalette._();

  /// Body copy and most labels.
  static const text = PdfColor.fromInt(0xFF333333);

  /// Item names, amounts and the document title.
  static const strong = PdfColor.fromInt(0xFF000000);

  /// Item descriptions and unit names.
  static const muted = PdfColor.fromInt(0xFF727272);

  /// Dark bar behind the item table header.
  static const tableHeader = PdfColor.fromInt(0xFF3C3D3A);

  static const onTableHeader = PdfColor.fromInt(0xFFFFFFFF);

  /// Hairline under item rows.
  static const rule = PdfColor.fromInt(0xFFADADAD);

  /// Outer frame and cell borders of the bordered templates.
  static const frame = PdfColor.fromInt(0xFF9E9E9E);

  /// Fill behind "Bill To" / "Ship To" and the bordered table header.
  static const band = PdfColor.fromInt(0xFFF2F3F4);

  /// Fill behind the grand-total row.
  static const highlight = PdfColor.fromInt(0xFFF5F4F3);

  static const pageNumber = PdfColor.fromInt(0xFF6C718A);

  /// Rules above and below the packaging slip's detail strip.
  static const stripRule = PdfColor.fromInt(0xFFF0F0F0);

  /// Fill behind the packaging slip's total-quantity cell.
  static const stripFill = PdfColor.fromInt(0xFFEEEEEE);

  /// Deductions such as "Payment Made" and "Credits Used".
  static const negative = PdfColor.fromInt(0xFFFF0000);
}
