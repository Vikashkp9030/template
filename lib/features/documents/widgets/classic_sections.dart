import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../theme/document_palette.dart';
import '../theme/document_skin.dart';
import 'baseline_stack.dart';
import 'document_table.dart';

/// A label/value pair in the boxed detail table of the bordered templates,
/// printed as `Invoice Date        : 21 Sep 2026`.
class MetaRow {
  const MetaRow(this.label, this.value);

  final String label;
  final String value;
}

/// Sections unique to the two bordered reference documents — sales invoice 1
/// and credit note 1 — which frame the whole page and rule the header into
/// boxes instead of letting it breathe.
class ClassicSections {
  const ClassicSections._();

  static const double bodySize = 7.99;
  static const double bodyStep = 9.225;
  static const double addressStep = 11.25;
  static const double companyNameSize = 12;
  static const double customerNameSize = 9;
  static const double titleSize = 22.01;
  static const double metaStep = 10.95;
  static const double ruleWidth = 0.75;

  /// A hairline in the header grid.
  static PlacedBlock rule({
    required double left,
    required double top,
    required double width,
    double height = ruleWidth,
    PdfColor color = DocumentPalette.frame,
  }) => PlacedBlock(
    left: left,
    top: top,
    height: height,
    child: pw.Container(width: width, height: height, color: color),
  );

  /// The shaded strip the party labels sit on.
  static PlacedBlock band({
    required double left,
    required double top,
    required double width,
    required double height,
  }) => PlacedBlock(
    left: left,
    top: top,
    height: height,
    child: pw.Container(
      width: width,
      height: height,
      color: DocumentPalette.band,
    ),
  );

  /// Document details as a label column and a colon-prefixed value column.
  static List<PlacedBlock> metaRows({
    required DocumentSkin skin,
    required List<MetaRow> rows,
    required double labelLeft,
    required double valueLeft,
    required double firstBaseline,
    double step = metaStep,
    double size = bodySize,
  }) => [
    for (final (index, row) in rows.indexed) ...[
      PlacedBlock.text(
        skin: skin,
        left: labelLeft,
        baseline: firstBaseline + index * step,
        size: size,
        child: pw.Text(row.label, style: skin.style(size: size)),
      ),
      PlacedBlock.text(
        skin: skin,
        left: valueLeft,
        baseline: firstBaseline + index * step,
        size: size,
        bold: true,
        child: pw.Text(
          ': ${row.value}',
          style: skin.style(
            size: size,
            bold: true,
            color: DocumentPalette.strong,
          ),
        ),
      ),
    ],
  ];

  /// Header row of a bordered item table: bold headings on the shaded fill.
  static pw.TableRow tableHeader({
    required DocumentSkin skin,
    required List<DocumentColumn> columns,
    double size = bodySize,
    double paddingTop = 4.74,
    double paddingBottom = 1.76,
    double paddingLeft = 6.00,
    double paddingRight = 5.25,
    double? lineStep,
    List<pw.Widget>? cells,
  }) {
    return pw.TableRow(
      repeat: true,
      decoration: const pw.BoxDecoration(color: DocumentPalette.band),
      children:
          cells ??
          [
            for (final column in columns)
              pw.Padding(
                padding: pw.EdgeInsets.fromLTRB(
                  paddingLeft,
                  paddingTop,
                  paddingRight,
                  paddingBottom,
                ),
                child: pw.Text(
                  column.header,
                  textAlign: switch (column.align) {
                    ColumnAlign.left => pw.TextAlign.left,
                    ColumnAlign.center => pw.TextAlign.center,
                    ColumnAlign.right => pw.TextAlign.right,
                  },
                  style: skin.style(
                    size: size,
                    bold: true,
                    color: DocumentPalette.strong,
                    lineStep: lineStep,
                  ),
                ),
              ),
          ],
    );
  }
}
