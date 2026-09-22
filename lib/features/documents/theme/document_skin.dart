import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../document_fonts.dart';
import 'document_palette.dart';

/// A typeface family plus the metrics needed to place text on an exact
/// baseline.
///
/// The PDF renderer puts the first baseline of a text box `ascent * fontSize`
/// below the box's top edge, and advances `(ascent - descent) * fontSize +
/// lineSpacing` per line. Every vertical measurement taken off the reference
/// PDFs is a baseline, so these two identities are what let the templates
/// reproduce them instead of approximating.
class DocumentSkin {
  const DocumentSkin({
    required this.regular,
    required this.bold,
    required this.boldItalic,
    required this.ascent,
    required this.boldAscent,
    required this.descent,
  });

  /// Ubuntu — used by six of the eight reference documents.
  factory DocumentSkin.sans(DocumentFonts fonts) => DocumentSkin(
    regular: fonts.sansRegular,
    bold: fonts.sansBold,
    boldItalic: fonts.sansBoldItalic,
    ascent: DocumentFonts.sansAscent,
    boldAscent: DocumentFonts.sansAscent,
    descent: DocumentFonts.sansDescent,
  );

  /// Times — used by the packaging slip and the sales return.
  factory DocumentSkin.serif(DocumentFonts fonts) => DocumentSkin(
    regular: fonts.serifRegular,
    bold: fonts.serifBold,
    boldItalic: fonts.serifBold,
    ascent: DocumentFonts.serifAscent,
    boldAscent: DocumentFonts.serifBoldAscent,
    descent: DocumentFonts.serifDescent,
  );

  final pw.Font regular;
  final pw.Font bold;
  final pw.Font boldItalic;
  final double ascent;
  final double boldAscent;
  final double descent;

  double ascentOf({bool bold = false}) => bold ? boldAscent : ascent;

  /// Distance from the top of a text box down to its first baseline.
  double baselineOffset(double fontSize, {bool bold = false}) =>
      ascentOf(bold: bold) * fontSize;

  /// Height of a single-line text box.
  double lineHeight(double fontSize, {bool bold = false}) =>
      (ascentOf(bold: bold) - descent) * fontSize;

  /// Extra leading needed for consecutive baselines to sit [step] apart.
  double lineSpacingFor(double fontSize, double step, {bool bold = false}) =>
      step - lineHeight(fontSize, bold: bold);

  pw.TextStyle style({
    required double size,
    bool bold = false,
    bool italic = false,
    PdfColor color = DocumentPalette.text,
    double? lineStep,
  }) {
    return pw.TextStyle(
      font: italic ? boldItalic : (bold ? this.bold : regular),
      fontSize: size,
      color: color,
      lineSpacing: lineStep == null
          ? 0
          : lineSpacingFor(size, lineStep, bold: bold || italic),
    );
  }

  /// Baseline offset inside a line box of height [lineBox], following the
  /// CSS half-leading rule the reference documents were laid out with: the
  /// spare leading is split evenly above and below the glyphs. This is what
  /// makes two different font sizes in one row sit on almost-but-not-quite
  /// the same baseline.
  double halfLeading(double lineBox, double fontSize, {bool bold = false}) =>
      (lineBox - lineHeight(fontSize, bold: bold)) / 2;

  /// Text set in a line box of height [lineBox], with the half-leading
  /// applied above it so its baseline lands where the reference puts it.
  pw.Widget lineBoxText(
    String text, {
    required double size,
    required double lineBox,
    bool bold = false,
    bool italic = false,
    PdfColor color = DocumentPalette.text,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    final lead = halfLeading(lineBox, size, bold: bold || italic);
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: lead > 0 ? lead : 0),
      child: pw.Text(
        text,
        textAlign: align,
        style: style(
          size: size,
          bold: bold,
          italic: italic,
          color: color,
          lineStep: lineBox,
        ),
      ),
    );
  }

  /// A run of lines that advance by a fixed [step], the way the reference
  /// address and note blocks are set. Rendered as one paragraph so the step
  /// is exact regardless of how many lines there are.
  pw.Widget block(
    Iterable<String> lines, {
    required double size,
    required double step,
    bool bold = false,
    PdfColor color = DocumentPalette.text,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    final text = lines.join('\n');
    return pw.Text(
      text,
      textAlign: align,
      style: style(size: size, bold: bold, color: color, lineStep: step),
    );
  }
}
