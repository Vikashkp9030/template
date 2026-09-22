import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/amount_in_words.dart';
import '../../../models/document/document_model.dart';
import '../../../models/document/document_type.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../document_template.dart';
import '../theme/document_geometry.dart';
import '../theme/document_palette.dart';
import '../theme/document_skin.dart';
import '../widgets/baseline_stack.dart';
import '../widgets/classic_sections.dart';
import '../widgets/document_format.dart';
import '../widgets/document_page_theme.dart';
import '../widgets/document_table.dart';
import '../widgets/item_cells.dart';
import '../widgets/modern_sections.dart';
import '../widgets/tax_labels.dart';
import '../widgets/text_measure.dart';

/// Tax invoice, bordered layout — `context/Sales Invoice1.pdf`.
///
/// A4 inside a ruled frame. The densest of the eight: the item table carries
/// a two-level heading that splits CGST and SGST each into a rate and an
/// amount column, and the closing section pairs free text on the left with a
/// ruled totals column that ends in a signature box.
class SalesInvoiceTemplate1 extends DocumentPdfTemplate {
  const SalesInvoiceTemplate1();

  @override
  DocumentType get type => DocumentType.salesInvoiceTemplate1;

  @override
  DocumentGeometry get geometry => DocumentGeometry.a4Bordered;

  static const double contentTop = 50.40;
  static const double contentBottom = 791.29;

  static const double _totalsLeft = 296.78;
  static const double _totalsWidth = 229.50;

  /// Item table columns. The two tax columns are groups: each holds a rate
  /// and an amount sub-column.
  static const double _wIndex = 19.39;
  static const double _wItem = 110.66;
  static const double _wHsn = 39.53;
  static const double _wQty = 43.46;
  static const double _wRate = 43.46;
  static const double _wDiscount = 43.46;
  static const double _wTaxGroup = 86.93;
  static const double _wTaxRate = 43.46;
  static const double _wAmount = 51.72;

  static const double _headerTopRow = 15.46;
  static const double _headerSubRow = 10.94;

  @override
  pw.Page buildPage(DocumentRenderContext context) {
    final skin = DocumentSkin.sans(context.fonts);
    final document = context.document;
    final invoice = document.invoice;
    const width = 525.53;

    final shipping = ModernSections.partyLines(
      invoice.customer.shippingAddress ?? invoice.customer.billingAddress,
      null,
    );

    return pw.MultiPage(
      pageTheme: DocumentPageTheme.build(
        geometry: geometry,
        skin: skin,
        contentTop: contentTop,
        contentBottom: contentBottom,
        frame: true,
        pageNumberBaseline: 807.23,
        pageNumberRight: 561.25,
      ),
      build: (pageContext) => [
        AbsoluteRegion.build(
          minHeight: 265.16,
          [
            PlacedBlock.text(
              skin: skin,
              left: 8.25,
              baseline: 13.80,
              size: ClassicSections.companyNameSize,
              bold: true,
              child: pw.Text(
                invoice.company.name,
                style: skin.style(
                  size: ClassicSections.companyNameSize,
                  bold: true,
                  color: DocumentPalette.strong,
                ),
              ),
            ),
            PlacedBlock.text(
              skin: skin,
              left: 8.25,
              baseline: 27.19,
              size: ClassicSections.bodySize,
              step: ClassicSections.bodyStep,
              lineCount: ModernSections.companyLines(invoice.company).length,
              child: skin.block(
                ModernSections.companyLines(invoice.company),
                size: ClassicSections.bodySize,
                step: ClassicSections.bodyStep,
                color: DocumentPalette.strong,
              ),
            ),
            PlacedBlock.text(
              skin: skin,
              left: 0.75,
              baseline: 59.21,
              size: ClassicSections.titleSize,
              width: 521.72,
              child: pw.Text(
                document.title,
                textAlign: pw.TextAlign.right,
                style: skin.style(
                  size: ClassicSections.titleSize,
                  color: DocumentPalette.strong,
                ),
              ),
            ),

            ClassicSections.rule(left: 0.75, top: 68.63, width: width),
            // One rule divides the details from the blank box beside them and
            // then the two party blocks below.
            PlacedBlock(
              left: 263.14,
              top: 68.63,
              height: 154.20,
              child: pw.Container(
                width: ClassicSections.ruleWidth,
                height: 154.20,
                color: DocumentPalette.frame,
              ),
            ),
            ClassicSections.rule(left: 0.75, top: 131.25, width: width),
            ClassicSections.band(
              left: 0.75,
              top: 131.63,
              width: width,
              height: 11.70,
            ),
            ClassicSections.rule(left: 0.75, top: 142.95, width: width),
            ClassicSections.rule(left: 0.75, top: 222.83, width: width),

            ...ClassicSections.metaRows(
              skin: skin,
              rows: _metaRows(document),
              labelLeft: 4.50,
              valueLeft: 131.96,
              firstBaseline: 77.82,
            ),

            for (final (left, label) in [
              (4.50, 'Bill To'),
              (267.64, 'Ship To'),
            ])
              PlacedBlock.text(
                skin: skin,
                left: left,
                baseline: 140.44,
                size: ClassicSections.bodySize,
                bold: true,
                child: pw.Text(
                  label,
                  style: skin.style(size: ClassicSections.bodySize, bold: true),
                ),
              ),

            PlacedBlock.text(
              skin: skin,
              left: 4.50,
              baseline: 156.41,
              size: ClassicSections.customerNameSize,
              bold: true,
              child: pw.Text(
                invoice.customer.name,
                style: skin.style(
                  size: ClassicSections.customerNameSize,
                  bold: true,
                  color: DocumentPalette.strong,
                ),
              ),
            ),
            PlacedBlock.text(
              skin: skin,
              left: 4.50,
              baseline: 167.78,
              size: ClassicSections.bodySize,
              step: ClassicSections.addressStep,
              lineCount: _billLines(context).length,
              child: skin.block(
                _billLines(context),
                size: ClassicSections.bodySize,
                step: ClassicSections.addressStep,
                color: DocumentPalette.strong,
              ),
            ),
            if (shipping.isNotEmpty)
              PlacedBlock.text(
                skin: skin,
                left: 267.64,
                baseline: 156.15,
                size: ClassicSections.bodySize,
                step: ClassicSections.addressStep,
                lineCount: shipping.length,
                child: skin.block(
                  shipping,
                  size: ClassicSections.bodySize,
                  step: ClassicSections.addressStep,
                  color: DocumentPalette.strong,
                ),
              ),

            PlacedBlock.text(
              skin: skin,
              left: 8.25,
              baseline: 238.77,
              size: ClassicSections.bodySize,
              child: pw.Text(
                'Subject :${(document.subject ?? '').isEmpty ? '' : ' ${document.subject}'}',
                style: skin.style(size: ClassicSections.bodySize),
              ),
            ),
            if ((document.description ?? '').isNotEmpty)
              PlacedBlock.text(
                skin: skin,
                left: 8.25,
                baseline: 254.14,
                size: ClassicSections.bodySize,
                child: pw.Text(
                  document.description!,
                  style: skin.style(
                    size: ClassicSections.bodySize,
                    color: DocumentPalette.strong,
                  ),
                ),
              ),
          ],
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 0.75),
          child: _itemsTable(context, skin),
        ),
        _closing(context, skin, TextMeasure(pageContext)),
      ],
    );
  }

  List<String> _billLines(DocumentRenderContext context) =>
      ModernSections.partyLines(
        context.document.invoice.customer.billingAddress,
        context.document.invoice.customer.gstin,
      );

  List<MetaRow> _metaRows(DocumentModel document) => [
    MetaRow(document.type.numberLabel, document.number),
    MetaRow('Invoice Date', DocumentFormat.date(document.invoice.date)),
    if ((document.paymentTerms ?? '').isNotEmpty)
      MetaRow('Terms', document.paymentTerms!),
    if (document.invoice.dueDate != null)
      MetaRow('Due Date', DocumentFormat.date(document.invoice.dueDate!)),
    if ((document.referenceNumber ?? '').isNotEmpty)
      MetaRow('P.O.#', document.referenceNumber!),
  ];

  static const List<DocumentColumn> _columns = [
    DocumentColumn(header: '#', width: _wIndex, align: ColumnAlign.center),
    DocumentColumn(header: 'Item & Description', width: _wItem),
    // The column is too narrow for "HSN/SAC" on one line. The reference's
    // HTML engine breaks it after the slash; the PDF renderer only breaks at
    // spaces, so the break is written out.
    DocumentColumn(
      header: 'HSN\n/SAC',
      width: _wHsn,
      paddingRight: 5.25,
    ),
    DocumentColumn(header: 'Qty', width: _wQty, align: ColumnAlign.right),
    DocumentColumn(header: 'Rate', width: _wRate, align: ColumnAlign.right),
    DocumentColumn(
      header: 'Discount',
      width: _wDiscount,
      align: ColumnAlign.right,
    ),
    DocumentColumn(header: 'CGST', width: _wTaxGroup),
    DocumentColumn(header: 'SGST', width: _wTaxGroup),
    DocumentColumn(header: 'Amount', width: _wAmount, align: ColumnAlign.right),
  ];

  pw.Widget _itemsTable(DocumentRenderContext context, DocumentSkin skin) {
    final items = context.document.invoice.items;
    final interState = context.document.invoice.interState;
    final taxHeadings = interState
        ? const ['IGST', 'CESS']
        : const ['CGST', 'SGST'];

    return DocumentTable.bordered(
      skin: skin,
      columns: _columns,
      fontSize: ClassicSections.bodySize,
      lineStep: ClassicSections.bodyStep,
      rowPaddingTop: 1.73,
      rowPaddingBottom: 0.77,
      header: _tableHeader(skin, taxHeadings),
      customCells: {
        6: (row) => _taxGroupCell(skin, context.totals.lines[row]),
        7: (row) => _taxGroupCell(skin, context.totals.lines[row]),
      },
      rows: [
        for (final (index, line) in context.totals.lines.indexed)
          [
            ItemCells.index(index + 1),
            ItemCells.item(line, index < items.length ? items[index] : null),
            ItemCells.hsn(line),
            ItemCells.quantity(line, index < items.length ? items[index] : null),
            ItemCells.money(line.unitPrice),
            ItemCells.money(line.discount),
            const <CellLine>[],
            const <CellLine>[],
            ItemCells.money(line.discountedAmount),
          ],
      ],
    );
  }

  /// Two-level heading: the plain columns run the full height, and each tax
  /// column carries its name over a rate and an amount sub-heading.
  pw.TableRow _tableHeader(DocumentSkin skin, List<String> taxHeadings) {
    pw.Widget plain(DocumentColumn column) => pw.Container(
      height: _headerTopRow + ClassicSections.ruleWidth + _headerSubRow,
      alignment: switch (column.align) {
        ColumnAlign.left => pw.Alignment.bottomLeft,
        ColumnAlign.center => pw.Alignment.bottomCenter,
        ColumnAlign.right => pw.Alignment.bottomRight,
      },
      padding: const pw.EdgeInsets.fromLTRB(6.00, 0, 5.25, 1.75),
      child: pw.Text(
        column.header,
        textAlign: switch (column.align) {
          ColumnAlign.left => pw.TextAlign.left,
          ColumnAlign.center => pw.TextAlign.center,
          ColumnAlign.right => pw.TextAlign.right,
        },
        style: skin.style(
          size: ClassicSections.bodySize,
          bold: true,
          color: DocumentPalette.strong,
          lineStep: 9.45,
        ),
      ),
    );

    pw.Widget group(String heading) => pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          height: _headerTopRow,
          alignment: pw.Alignment.bottomCenter,
          padding: const pw.EdgeInsets.only(bottom: 1.76),
          child: pw.Text(
            heading,
            style: skin.style(
              size: ClassicSections.bodySize,
              bold: true,
              color: DocumentPalette.strong,
            ),
          ),
        ),
        pw.Container(
          width: _wTaxGroup,
          height: ClassicSections.ruleWidth,
          color: DocumentPalette.frame,
        ),
        pw.Row(
          children: [
            _subHeading(skin, '%', _wTaxRate),
            pw.Container(
              width: ClassicSections.ruleWidth,
              height: _headerSubRow,
              color: DocumentPalette.frame,
            ),
            _subHeading(
              skin,
              'Amt',
              _wTaxGroup - _wTaxRate - ClassicSections.ruleWidth,
            ),
          ],
        ),
      ],
    );

    return pw.TableRow(
      repeat: true,
      decoration: const pw.BoxDecoration(color: DocumentPalette.band),
      children: [
        for (final (index, column) in _columns.indexed)
          if (index == 6 || index == 7)
            group(taxHeadings[index - 6])
          else
            plain(column),
      ],
    );
  }

  pw.Widget _subHeading(DocumentSkin skin, String text, double width) {
    return pw.Container(
      width: width,
      height: _headerSubRow,
      alignment: pw.Alignment.bottomRight,
      padding: const pw.EdgeInsets.only(right: 3.77, bottom: 1.00),
      child: pw.Text(
        text,
        style: skin.style(
          size: ClassicSections.bodySize,
          bold: true,
          color: DocumentPalette.strong,
        ),
      ),
    );
  }

  /// One half of the GST split: the rate beside the amount, ruled apart.
  ///
  /// The rule between them runs the height of the row, which the row only
  /// knows once its tallest cell has been measured — hence the stacked
  /// divider and the row's `full` vertical alignment.
  pw.Widget _taxGroupCell(DocumentSkin skin, LineTotal line) {
    final rate = line.taxRate;
    final trimmed = rate.toStringAsFixed(2).endsWith('.00')
        ? rate.toStringAsFixed(0)
        : rate.toStringAsFixed(2);

    pw.Widget half(String text, double width) => pw.Container(
      width: width,
      alignment: pw.Alignment.topRight,
      padding: const pw.EdgeInsets.fromLTRB(4.50, 1.73, 3.77, 0.77),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        style: skin.style(
          size: ClassicSections.bodySize,
          color: DocumentPalette.strong,
          lineStep: ClassicSections.bodyStep,
        ),
      ),
    );

    return pw.Stack(
      children: [
        pw.Row(
          children: [
            half('$trimmed%', _wTaxRate),
            pw.SizedBox(width: ClassicSections.ruleWidth),
            half(
              DocumentFormat.amount(line.taxAmount / 2),
              _wTaxGroup - _wTaxRate - ClassicSections.ruleWidth,
            ),
          ],
        ),
        pw.Positioned(
          left: _wTaxRate,
          top: 0,
          bottom: 0,
          child: pw.Container(
            width: ClassicSections.ruleWidth,
            color: DocumentPalette.frame,
          ),
        ),
      ],
    );
  }

  pw.Widget _closing(
    DocumentRenderContext context,
    DocumentSkin skin,
    TextMeasure measure,
  ) {
    final document = context.document;
    final invoice = document.invoice;
    final totals = context.totals;
    final balance = totals.grandTotal - document.paymentMade;

    final rows = <TotalRow>[
      TotalRow('Sub Total', DocumentFormat.amount(totals.subtotal)),
      ...TaxLabels.rows(totals.taxLines),
      TotalRow(
        'Total',
        DocumentFormat.currency(totals.grandTotal, invoice.currency),
        bold: true,
      ),
      if (document.paymentRetention > 0)
        TotalRow(
          'Payment Retention',
          DocumentFormat.deduction(document.paymentRetention),
          valueColor: DocumentPalette.negative,
          underlineLabel: true,
        ),
      if (document.paymentMade > 0)
        TotalRow(
          'Payment Made',
          DocumentFormat.deduction(document.paymentMade),
          valueColor: DocumentPalette.negative,
        ),
    ];

    // The reference height, unless the free text on the left runs longer than
    // the reference's, in which case the block grows rather than overflowing.
    final height = _closingHeight(context, skin, measure);

    return pw.SizedBox(
      height: height,
      child: pw.Stack(
        children: [
          pw.Positioned(
            left: _totalsLeft,
            top: 0.38,
            child: pw.Container(
              width: ClassicSections.ruleWidth,
              height: height - 0.38,
              color: DocumentPalette.frame,
            ),
          ),
          for (final top in [91.35, height - ClassicSections.ruleWidth])
            pw.Positioned(
              left: _totalsLeft,
              top: top,
              child: pw.Container(
                width: _totalsWidth,
                height: ClassicSections.ruleWidth,
                color: DocumentPalette.frame,
              ),
            ),
          pw.Positioned(
            left: _totalsLeft + ClassicSections.ruleWidth,
            top: 1.13,
            child: ModernSections.totals(
              skin: skin,
              rows: rows,
              labelWidth: 135.74,
              valueWidth: 93.01,
              rowHeight: 12.225,
              rowPaddingTop: 3.23,
              size: ClassicSections.bodySize,
              labelPadding: 5.25,
              valuePadding: 5.25,
            ),
          ),
          pw.Positioned(
            left: _totalsLeft + ClassicSections.ruleWidth,
            top: 74.48,
            child: ModernSections.totals(
              skin: skin,
              rows: [
                TotalRow(
                  'Balance Due',
                  DocumentFormat.currency(balance, invoice.currency),
                  bold: true,
                ),
              ],
              labelWidth: 135.74,
              valueWidth: 93.01,
              rowHeight: 13.20,
              rowPaddingTop: 3.28,
              size: ClassicSections.customerNameSize,
              labelPadding: 5.25,
              valuePadding: 5.25,
            ),
          ),
          pw.Positioned(
            left: _totalsLeft + ClassicSections.ruleWidth,
            top: height - 8.99,
            child: pw.SizedBox(
              width: _totalsWidth - ClassicSections.ruleWidth,
              child: pw.Text(
                'Authorized Signature',
                textAlign: pw.TextAlign.center,
                style: skin.style(size: ClassicSections.bodySize),
              ),
            ),
          ),
          ..._leftColumn(context, skin),
        ],
      ),
    );
  }

  /// Reference height of the closing block, extended if the terms need more
  /// room than the reference's did.
  double _closingHeight(
    DocumentRenderContext context,
    DocumentSkin skin,
    TextMeasure measure,
  ) {
    const reference = 164.33;
    final terms = context.document.invoice.terms ?? '';
    if (terms.isEmpty) return reference;

    final lines = measure.lineCount(
      terms,
      skin.style(
        size: ClassicSections.bodySize,
        lineStep: ClassicSections.bodyStep,
      ),
      _leftColumnWidth,
    );
    final bottom = _termsBodyBaseline -
        skin.baselineOffset(ClassicSections.bodySize) +
        skin.lineHeight(ClassicSections.bodySize) +
        (lines - 1) * ClassicSections.bodyStep +
        _closingBottomMargin;

    return bottom > reference ? bottom : reference;
  }

  static const double _leftColumnWidth = 257.0;
  static const double _termsBodyBaseline = 119.66;
  static const double _closingBottomMargin = 12.0;

  List<pw.Widget> _leftColumn(
    DocumentRenderContext context,
    DocumentSkin skin,
  ) {
    final document = context.document;
    final invoice = document.invoice;
    final totals = context.totals;

    pw.Widget at(double baseline, pw.Widget child) => pw.Positioned(
      left: 6.00,
      top: baseline - skin.baselineOffset(ClassicSections.bodySize),
      child: child,
    );

    pw.Widget label(String text) => pw.Text(
      text,
      style: skin.style(size: ClassicSections.bodySize),
    );

    pw.Widget body(String text, {bool italic = false}) => pw.SizedBox(
      width: _leftColumnWidth,
      child: pw.Text(
        text,
        style: skin.style(
          size: ClassicSections.bodySize,
          italic: italic,
          color: DocumentPalette.strong,
          lineStep: ClassicSections.bodyStep,
        ),
      ),
    );

    return [
      if (document.showAmountInWords) ...[
        at(
          19.31,
          pw.Text(
            'Total In Words',
            style: skin.style(
              size: ClassicSections.bodySize,
              color: DocumentPalette.strong,
            ),
          ),
        ),
        at(
          28.54,
          body(
            AmountInWords.convert(
              totals.grandTotal,
              currency: invoice.currency,
            ),
            italic: true,
          ),
        ),
      ],
      if ((invoice.notes ?? '').isNotEmpty) ...[
        at(49.24, label('Notes')),
        at(58.46, body(invoice.notes!)),
      ],
      if (document.showPaymentOptions) at(84.45, label('Payment Options')),
      if ((invoice.terms ?? '').isNotEmpty) ...[
        at(110.44, label('Terms & Conditions')),
        at(119.66, body(invoice.terms!)),
      ],
    ];
  }
}
