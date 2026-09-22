import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/invoice/address_model.dart';
import '../../../models/invoice/company_model.dart';
import '../theme/document_palette.dart';
import '../theme/document_skin.dart';
import 'baseline_stack.dart';
import 'text_measure.dart';

/// A right-aligned label/value pair, as printed down the right of the
/// spreadsheet-style documents ("Credit Date :   21 Sep 2026").
class InfoRow {
  const InfoRow(this.label, this.value);

  final String label;
  final String value;
}

/// A line of the totals block.
class TotalRow {
  const TotalRow(
    this.label,
    this.value, {
    this.bold = false,
    this.highlighted = false,
    this.valueColor,
    this.underlineLabel = false,
  });

  final String label;
  final String value;

  /// Grand totals and balances are set in bold.
  final bool bold;

  /// Sits on the pale bar the references put behind the closing amount.
  final bool highlighted;

  /// Deductions print in red.
  final PdfColor? valueColor;

  /// "Payment Retention" is underlined in the reference invoices.
  final bool underlineLabel;
}

/// Sections shared by the six spreadsheet-style reference documents
/// (credit note 2, sales invoice 2, delivery challan, sales order, packaging
/// slip and sales return).
class ModernSections {
  const ModernSections._();

  static const double companyNameSize = 10.01;
  static const double bodySize = 9;
  static const double bodyStep = 10.39;
  static const double titleSize = 28.01;
  static const double numberSize = 10.01;
  static const double labelSize = 10.01;
  static const double smallSize = 7.99;
  static const double smallStep = 9.22;

  /// Company name over its address block, at the top left.
  static List<PlacedBlock> companyBlock({
    required DocumentSkin skin,
    required CompanyModel company,
    required double left,
    required double nameBaseline,
    required double addressBaseline,
    double nameSize = companyNameSize,
    double size = bodySize,
    double step = bodyStep,
    bool boldName = true,
    double? width,
  }) {
    final lines = companyLines(company);
    return [
      PlacedBlock.text(
        skin: skin,
        left: left,
        baseline: nameBaseline,
        size: nameSize,
        bold: boldName,
        width: width,
        child: pw.Text(
          company.name,
          style: skin.style(size: nameSize, bold: boldName),
        ),
      ),
      if (lines.isNotEmpty)
        PlacedBlock.text(
          skin: skin,
          left: left,
          baseline: addressBaseline,
          size: size,
          step: step,
          lineCount: lines.length,
          width: width,
          child: skin.block(lines, size: size, step: step),
        ),
    ];
  }

  /// Address, phone, email and GSTIN of the issuing company, in the order the
  /// references print them. Blank fields are dropped rather than left as gaps.
  static List<String> companyLines(CompanyModel company) => [
    ...addressLines(company.address),
    if ((company.gstin ?? '').isNotEmpty) 'GSTIN ${company.gstin}',
    if (company.phone.isNotEmpty) company.phone,
    if (company.email.isNotEmpty) company.email,
    if ((company.website ?? '').isNotEmpty) company.website!,
  ];

  /// Address lines of a customer, followed by their GSTIN.
  static List<String> partyLines(AddressModel? address, String? gstin) => [
    if (address != null) ...addressLines(address),
    if ((gstin ?? '').isNotEmpty) 'GSTIN $gstin',
  ];

  /// Postal layout the references use: street, city, then postcode and state
  /// on one line, then country. This differs from [AddressModel.lines], which
  /// packs city, state and postcode together for the on-screen templates.
  static List<String> addressLines(AddressModel address) {
    final region = [
      if (address.pincode.isNotEmpty) address.pincode,
      if (address.state.isNotEmpty) address.state,
    ].join(' ');

    return [
      address.line1,
      if ((address.line2 ?? '').isNotEmpty) address.line2!,
      if (address.city.isNotEmpty) address.city,
      if (region.isNotEmpty) region,
      if (address.country.isNotEmpty) address.country,
    ].where((line) => line.trim().isNotEmpty).toList();
  }

  /// Width of the title column.
  ///
  /// The references set the title in a narrow right-hand column rather than
  /// across the page, which is why "DELIVERY CHALLAN" breaks over two lines
  /// while "SALES ORDER" does not.
  static double titleWidth(double contentWidth) => contentWidth * 0.4;

  /// Document title, number and optional headline amount, right-aligned to
  /// the content edge.
  static List<PlacedBlock> titleBlock({
    required DocumentSkin skin,
    required double right,
    required double left,
    required String title,
    required String number,
    required double titleBaseline,
    required double numberBaseline,
    double size = titleSize,
    double? titleStep,
    String? highlightLabel,
    String? highlightValue,
    double? highlightLabelBaseline,
    double? highlightValueBaseline,
    double highlightLabelSize = smallSize,
    double highlightValueSize = 12,
  }) {
    final width = right - left;
    return [
      PlacedBlock.text(
        skin: skin,
        left: left,
        baseline: titleBaseline,
        size: size,
        step: titleStep,
        width: width,
        child: pw.Text(
          title,
          textAlign: pw.TextAlign.right,
          style: skin.style(
            size: size,
            color: DocumentPalette.strong,
            lineStep: titleStep,
          ),
        ),
      ),
      if (number.isNotEmpty)
        PlacedBlock.text(
          skin: skin,
          left: left,
          baseline: numberBaseline,
          size: numberSize,
          bold: true,
          width: width,
          child: pw.Text(
            number,
            textAlign: pw.TextAlign.right,
            style: skin.style(size: numberSize, bold: true),
          ),
        ),
      if (highlightLabel != null && highlightLabelBaseline != null)
        PlacedBlock.text(
          skin: skin,
          left: left,
          baseline: highlightLabelBaseline,
          size: highlightLabelSize,
          bold: true,
          width: width,
          child: pw.Text(
            highlightLabel,
            textAlign: pw.TextAlign.right,
            style: skin.style(size: highlightLabelSize, bold: true),
          ),
        ),
      if (highlightValue != null && highlightValueBaseline != null)
        PlacedBlock.text(
          skin: skin,
          left: left,
          baseline: highlightValueBaseline,
          size: highlightValueSize,
          bold: true,
          width: width,
          child: pw.Text(
            highlightValue,
            textAlign: pw.TextAlign.right,
            style: skin.style(size: highlightValueSize, bold: true),
          ),
        ),
    ];
  }

  /// "Bill To" / "Ship To" / "Deliver To" block.
  static List<PlacedBlock> partyBlock({
    required DocumentSkin skin,
    required double left,
    required String label,
    required String name,
    required List<String> lines,
    required double labelBaseline,
    required double nameBaseline,
    required double firstLineBaseline,
    double? width,
    double size = bodySize,
    double step = bodyStep,
    double labelSize = ModernSections.labelSize,
    bool boldName = true,
  }) {
    return [
      PlacedBlock.text(
        skin: skin,
        left: left,
        baseline: labelBaseline,
        size: labelSize,
        width: width,
        child: pw.Text(label, style: skin.style(size: labelSize)),
      ),
      if (name.isNotEmpty)
        PlacedBlock.text(
          skin: skin,
          left: left,
          baseline: nameBaseline,
          size: size,
          bold: boldName,
          width: width,
          child: pw.Text(name, style: skin.style(size: size, bold: boldName)),
        ),
      if (lines.isNotEmpty)
        PlacedBlock.text(
          skin: skin,
          left: left,
          baseline: firstLineBaseline,
          size: size,
          step: step,
          lineCount: lines.length,
          width: width,
          child: skin.block(lines, size: size, step: step),
        ),
    ];
  }

  /// Right-hand column of label/value rows.
  ///
  /// The rows flow rather than sit at fixed offsets, so a label that wraps
  /// pushes the rows below it down exactly as the reference sales order does.
  static pw.Widget infoRows({
    required DocumentSkin skin,
    required List<InfoRow> rows,
    required double labelWidth,
    required double valueWidth,
    double gap = 0,
    double rowHeight = 19.05,
    double lineBox = 11.55,
    double size = labelSize,
    double valueSize = bodySize,
  }) {
    final padding = (rowHeight - lineBox) / 2;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        for (final row in rows)
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(
              vertical: padding > 0 ? padding : 0,
            ),
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              // The value is centred against its label, which is what makes
              // it sit between the two lines of a label that has wrapped.
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(
                  width: labelWidth,
                  child: skin.lineBoxText(
                    row.label,
                    size: size,
                    lineBox: lineBox,
                    align: pw.TextAlign.right,
                  ),
                ),
                if (gap > 0) pw.SizedBox(width: gap),
                pw.SizedBox(
                  width: valueWidth,
                  child: skin.lineBoxText(
                    row.value,
                    size: valueSize,
                    lineBox: lineBox,
                    align: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Totals block: right-aligned label/value rows, the closing one on a pale
  /// bar spanning the whole block.
  static pw.Widget totals({
    required DocumentSkin skin,
    required List<TotalRow> rows,
    required double labelWidth,
    required double valueWidth,
    double rowHeight = 25.45,
    double highlightRowHeight = 30,
    double lineBox = 11.55,
    double size = bodySize,
    double labelPadding = 7.52,
    double valuePadding = 7.52,
    double rowPaddingTop = 8.15,
    double highlightPaddingTop = 10.27,
  }) {
    pw.Widget line(TotalRow row) {
      final height = row.highlighted ? highlightRowHeight : rowHeight;
      final padding = row.highlighted ? highlightPaddingTop : rowPaddingTop;
      return pw.Container(
        height: height,
        color: row.highlighted ? DocumentPalette.highlight : null,
        // Without an explicit alignment the box centres its child in the
        // leftover space, which would undo the measured top padding.
        alignment: pw.Alignment.topLeft,
        padding: pw.EdgeInsets.only(top: padding > 0 ? padding : 0),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: labelWidth,
              child: pw.Padding(
                padding: pw.EdgeInsets.only(right: labelPadding),
                child: pw.Text(
                  row.label,
                  textAlign: pw.TextAlign.right,
                  style: skin
                      .style(
                        size: size,
                        bold: row.bold,
                        color: DocumentPalette.strong,
                        lineStep: lineBox,
                      )
                      .copyWith(
                        decoration: row.underlineLabel
                            ? pw.TextDecoration.underline
                            : null,
                      ),
                ),
              ),
            ),
            pw.SizedBox(
              width: valueWidth,
              child: pw.Padding(
                padding: pw.EdgeInsets.only(right: valuePadding),
                child: pw.Text(
                  row.value,
                  textAlign: pw.TextAlign.right,
                  style: skin.style(
                    size: size,
                    bold: row.bold,
                    color: row.valueColor ?? DocumentPalette.strong,
                    lineStep: lineBox,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [for (final row in rows) line(row)],
    );
  }

  /// "Total In Words:" and its bold-italic value, right of the page.
  static pw.Widget amountInWords({
    required DocumentSkin skin,
    required String words,
    required double labelWidth,
    required double valueWidth,
    String label = 'Total In Words:',
    double size = bodySize,
    double step = 10.65,
    double gap = 0,
    double valueOffset = 0.75,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: labelWidth,
          child: pw.Text(
            label,
            textAlign: pw.TextAlign.right,
            style: skin.style(size: size),
          ),
        ),
        if (gap > 0) pw.SizedBox(width: gap),
        pw.SizedBox(
          width: valueWidth,
          child: pw.Padding(
            // The value sits a fraction lower than its label in the reference.
            padding: pw.EdgeInsets.only(top: valueOffset),
            child: pw.Text(
              words,
              textAlign: pw.TextAlign.left,
              style: skin.style(size: size, italic: true, lineStep: step),
            ),
          ),
        ),
      ],
    );
  }

  /// Height of the [amountInWords] row, including the offset its value sits
  /// at and however many lines the value wraps onto.
  static double wordsHeight({
    required DocumentSkin skin,
    required TextMeasure measure,
    required String words,
    required double valueWidth,
    double size = bodySize,
    double step = 10.65,
    double valueOffset = 0.75,
  }) {
    final lines = measure.lineCount(
      words,
      skin.style(size: size, italic: true, lineStep: step),
      valueWidth,
    );
    return valueOffset +
        skin.lineHeight(size, bold: true) +
        (lines - 1) * step;
  }

  /// A titled block of body copy — "Notes", "Terms & Conditions", "Reason".
  static List<BaselineBlock> textSection({
    required DocumentSkin skin,
    required String label,
    required String body,
    required double labelTop,
    required double bodyTop,
    double labelSize = labelSize,
    double bodySize = smallSize,
    double bodyStep = smallStep,
    required double width,
    bool visible = true,
  }) {
    final lines = body.split('\n');
    final present = visible && body.isNotEmpty;
    return [
      BaselineBlock.text(
        skin: skin,
        baseline: labelTop,
        size: labelSize,
        visible: present,
        child: pw.Text(label, style: skin.style(size: labelSize)),
      ),
      BaselineBlock.text(
        skin: skin,
        baseline: bodyTop,
        size: bodySize,
        step: bodyStep,
        lineCount: lines.length,
        visible: present,
        child: pw.SizedBox(
          width: width,
          child: skin.block(lines, size: bodySize, step: bodyStep),
        ),
      ),
    ];
  }

  /// "Authorized Signature" with the rule the references draw beside it.
  ///
  /// [width] has to cover the rule as well as the label, since a stack is only
  /// as wide as its unpositioned children and would otherwise clip it.
  static pw.Widget signature({
    required DocumentSkin skin,
    required double lineLeft,
    required double lineWidth,
    required double lineTop,
    required double width,
    double size = labelSize,
    String label = 'Authorized Signature',
    double ruleWidth = 0.75,
  }) {
    return pw.SizedBox(
      width: width,
      child: pw.Stack(
        children: [
          pw.Text(label, style: skin.style(size: size)),
          pw.Positioned(
            left: lineLeft,
            top: lineTop,
            child: pw.Container(
              width: lineWidth,
              height: ruleWidth,
              color: DocumentPalette.strong,
            ),
          ),
        ],
      ),
    );
  }
}
