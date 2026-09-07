import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'invoice_template_theme.dart';

/// Maps the shared [InvoiceTemplateTheme] token model onto `package:pdf`
/// types, so `PdfService` never hardcodes a color or font size that could
/// drift from the Flutter widget renderer — both read the same theme
/// instance, this file only converts the *type*.
extension InvoiceFontWeightPdfX on InvoiceFontWeight {
  pw.FontWeight get pdf => switch (this) {
    InvoiceFontWeight.regular => pw.FontWeight.normal,
    InvoiceFontWeight.medium => pw.FontWeight.normal,
    InvoiceFontWeight.semiBold => pw.FontWeight.bold,
    InvoiceFontWeight.bold => pw.FontWeight.bold,
    InvoiceFontWeight.black => pw.FontWeight.bold,
  };
}

extension InvoiceTextStylePdfX on InvoiceTextStyle {
  pw.TextStyle get pdf => pw.TextStyle(
    fontSize: fontSize,
    fontWeight: weight.pdf,
    color: PdfColor.fromInt(color),
    letterSpacing: letterSpacing,
    height: height,
  );
}

extension InvoiceTemplateThemePdfX on InvoiceTemplateTheme {
  PdfColor get pdfBackground => PdfColor.fromInt(background);
  PdfColor get pdfPrimary => PdfColor.fromInt(primary);
  PdfColor get pdfAccent => PdfColor.fromInt(accent);
  PdfColor get pdfTextMuted => PdfColor.fromInt(textMuted);
  PdfColor get pdfDivider => PdfColor.fromInt(divider);
  PdfColor get pdfSurfaceMuted => PdfColor.fromInt(surfaceMuted);
  PdfColor? get pdfGrandTotalCardBackground =>
      grandTotalCardBackground == null ? null : PdfColor.fromInt(grandTotalCardBackground!);
  PdfColor? get pdfGrandTotalCardForeground =>
      grandTotalCardForeground == null ? null : PdfColor.fromInt(grandTotalCardForeground!);
  pw.EdgeInsets get pdfPageMargin => pw.EdgeInsets.all(pageMargin);
}
