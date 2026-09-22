import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../theme/document_palette.dart';
import '../theme/document_skin.dart';

enum ColumnAlign { left, center, right }

/// One column of an item table: its heading, its exact width in points, and
/// how its cells are aligned.
class DocumentColumn {
  const DocumentColumn({
    required this.header,
    required this.width,
    this.align = ColumnAlign.left,
    this.paddingLeft,
    this.paddingRight,
  });

  final String header;
  final double width;
  final ColumnAlign align;

  /// Inner gutters, when this column does not use the table's default. The
  /// reference item tables give the item column a wide left gutter and the
  /// row-number column an off-centre one.
  final double? paddingLeft;
  final double? paddingRight;
}

/// A stack of text lines inside one cell, e.g. an item name above its grey
/// description, or a quantity above its unit.
class CellLine {
  const CellLine(
    this.text, {
    this.color = DocumentPalette.strong,
    this.bold = false,
  });

  final String text;
  final PdfColor color;
  final bool bold;
}

/// Builders for the two item-table styles the references use.
class DocumentTable {
  const DocumentTable._();

  /// Dark-header, rule-separated table: credit note 2, sales invoice 2,
  /// delivery challan, sales order, packaging slip and sales return.
  static pw.Widget modern({
    required DocumentSkin skin,
    required List<DocumentColumn> columns,
    required List<List<List<CellLine>>> rows,
    required double fontSize,
    required double lineStep,
    /// Vertical padding inside the header cells. The bar's height is this
    /// twice over plus the tallest heading, so a heading that wraps makes the
    /// bar taller — pass the value the reference bar measures.
    double headerPadding = 6.96,
    double? headerLineStep,
    double rowPaddingTop = 7.77,
    double rowPaddingBottom = 7.52,
    double edgePadding = 7.52,
    double ruleWidth = 0.75,
    // The reference rule sits between two rows rather than inside either, so
    // its thickness is part of the row pitch.
  }) {
    // Header cells are centred in the bar, which is what lets a heading that
    // wraps ("Discount" over two lines) straddle the single-line ones.

    pw.EdgeInsets padding(int index, double top, double bottom) {
      final column = columns[index];
      return pw.EdgeInsets.fromLTRB(
        column.paddingLeft ?? edgePadding,
        top,
        column.paddingRight ?? edgePadding,
        bottom,
      );
    }

    return pw.Table(
      columnWidths: {
        for (var i = 0; i < columns.length; i++)
          i: pw.FixedColumnWidth(columns[i].width),
      },
      children: [
        pw.TableRow(
          repeat: true,
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          decoration: const pw.BoxDecoration(
            color: DocumentPalette.tableHeader,
          ),
          children: [
            for (var i = 0; i < columns.length; i++)
              pw.Padding(
                padding: padding(i, headerPadding, headerPadding),
                child: pw.Text(
                  columns[i].header,
                  textAlign: _textAlign(columns[i].align),
                  style: skin.style(
                    size: fontSize,
                    color: DocumentPalette.onTableHeader,
                    lineStep: headerLineStep,
                  ),
                ),
              ),
          ],
        ),
        for (final row in rows)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: DocumentPalette.rule,
                  width: ruleWidth,
                ),
              ),
            ),
            children: [
              for (var i = 0; i < columns.length; i++)
                pw.Padding(
                  padding: padding(i, rowPaddingTop, rowPaddingBottom + ruleWidth),
                  child: _cell(
                    skin: skin,
                    lines: i < row.length ? row[i] : const <CellLine>[],
                    fontSize: fontSize,
                    lineStep: lineStep,
                    align: columns[i].align,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// Fully bordered table: sales invoice 1 and credit note 1.
  ///
  /// [customCells] replaces the cell in a given column with a widget the
  /// caller builds, which is how the tax columns of sales invoice 1 carry
  /// their own rate/amount split.
  static pw.Widget bordered({
    required DocumentSkin skin,
    required List<DocumentColumn> columns,
    required List<List<List<CellLine>>> rows,
    required double fontSize,
    required double lineStep,
    required pw.TableRow header,
    double rowPaddingTop = 4.2,
    double rowPaddingBottom = 4.2,
    double cellPaddingLeft = 4.50,
    double cellPaddingRight = 3.77,
    double borderWidth = 0.75,
    Map<int, pw.Widget Function(int rowIndex)> customCells = const {},
  }) {
    pw.EdgeInsets padding(int index) => pw.EdgeInsets.fromLTRB(
      columns[index].paddingLeft ?? cellPaddingLeft,
      rowPaddingTop,
      columns[index].paddingRight ?? cellPaddingRight,
      rowPaddingBottom,
    );

    return pw.Table(
      border: pw.TableBorder.all(
        color: DocumentPalette.frame,
        width: borderWidth,
      ),
      columnWidths: {
        for (var i = 0; i < columns.length; i++)
          i: pw.FixedColumnWidth(columns[i].width),
      },
      children: [
        header,
        for (final (rowIndex, row) in rows.indexed)
          pw.TableRow(
            // Cells are given the row's height so a custom cell can rule
            // itself from top to bottom.
            verticalAlignment: customCells.isEmpty
                ? null
                : pw.TableCellVerticalAlignment.full,
            children: [
              for (var i = 0; i < columns.length; i++)
                // A custom cell brings its own padding, because it draws its
                // own internal grid.
                if (customCells.containsKey(i))
                  customCells[i]!(rowIndex)
                else
                  pw.Padding(
                    padding: padding(i),
                    child: _cell(
                      skin: skin,
                      lines: i < row.length ? row[i] : const <CellLine>[],
                      fontSize: fontSize,
                      lineStep: lineStep,
                      align: columns[i].align,
                    ),
                  ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _cell({
    required DocumentSkin skin,
    required List<CellLine> lines,
    required double fontSize,
    required double lineStep,
    required ColumnAlign align,
  }) {
    if (lines.isEmpty) return pw.SizedBox();

    final textAlign = _textAlign(align);

    // A single style renders as one paragraph, so a long value wraps on the
    // exact same leading as the reference instead of stacking fixed boxes.
    final uniform = lines.every(
      (line) => line.color == lines.first.color && line.bold == lines.first.bold,
    );
    if (uniform) {
      return pw.Text(
        lines.map((line) => line.text).join('\n'),
        textAlign: textAlign,
        style: skin.style(
          size: fontSize,
          bold: lines.first.bold,
          color: lines.first.color,
          lineStep: lineStep,
        ),
      );
    }

    return pw.RichText(
      textAlign: textAlign,
      text: pw.TextSpan(
        children: [
          for (var i = 0; i < lines.length; i++)
            pw.TextSpan(
              text: i == 0 ? lines[i].text : '\n${lines[i].text}',
              style: skin.style(
                size: fontSize,
                bold: lines[i].bold,
                color: lines[i].color,
                lineStep: lineStep,
              ),
            ),
        ],
      ),
    );
  }

  static pw.TextAlign _textAlign(ColumnAlign align) => switch (align) {
    ColumnAlign.left => pw.TextAlign.left,
    ColumnAlign.center => pw.TextAlign.center,
    ColumnAlign.right => pw.TextAlign.right,
  };
}
