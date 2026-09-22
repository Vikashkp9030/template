import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/amount_in_words.dart';
import '../../../models/document/document_model.dart';
import '../../../models/document/document_type.dart';
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

/// Credit note, bordered layout — `context/Credit_Note_Template1.pdf`.
///
/// A4 inside a ruled frame. The header is divided into boxes, the item table
/// is fully gridded, and the closing section splits into free text on the
/// left and a ruled totals column on the right that ends in a signature box.
class CreditNoteTemplate1 extends DocumentPdfTemplate {
  const CreditNoteTemplate1();

  @override
  DocumentType get type => DocumentType.creditNoteTemplate1;

  @override
  DocumentGeometry get geometry => DocumentGeometry.a4Bordered;

  static const double contentTop = 50.40;
  static const double contentBottom = 791.29;

  /// Left edge of the totals column, measured from the content box.
  static const double _totalsLeft = 296.78;
  static const double _totalsWidth = 229.50;

  @override
  pw.Page buildPage(DocumentRenderContext context) {
    final skin = DocumentSkin.sans(context.fonts);
    final document = context.document;
    final invoice = document.invoice;
    const width = 525.53;

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
            // Company block and title.
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

            // Header grid.
            ClassicSections.rule(left: 0.75, top: 68.63, width: width),
            PlacedBlock(
              left: 263.14,
              top: 68.63,
              height: 63.00,
              child: pw.Container(
                width: ClassicSections.ruleWidth,
                height: 63.00,
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

            PlacedBlock.text(
              skin: skin,
              left: 4.50,
              baseline: 140.44,
              size: ClassicSections.bodySize,
              bold: true,
              child: pw.Text(
                'Bill To',
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
    MetaRow(document.numberLabel ?? document.type.numberLabel, document.number),
    MetaRow('Credit Date', DocumentFormat.date(document.invoice.date)),
    if ((document.referenceNumber ?? '').isNotEmpty)
      MetaRow('Ref#', document.referenceNumber!),
    if ((document.linkedInvoiceNumber ?? '').isNotEmpty)
      MetaRow('Invoice#', document.linkedInvoiceNumber!),
    if (document.linkedInvoiceDate != null)
      MetaRow(
        'Invoice Date',
        DocumentFormat.shortDate(document.linkedInvoiceDate!),
      ),
  ];

  static const List<DocumentColumn> _columns = [
    DocumentColumn(header: '#', width: 25.87, align: ColumnAlign.center),
    DocumentColumn(header: 'Item & Description', width: 262.88),
    DocumentColumn(header: 'HSN/SAC', width: 52.54),
    DocumentColumn(header: 'Qty', width: 57.79, align: ColumnAlign.right),
    DocumentColumn(header: 'Rate', width: 57.78, align: ColumnAlign.right),
    DocumentColumn(header: 'Amount', width: 68.67, align: ColumnAlign.right),
  ];

  pw.Widget _itemsTable(DocumentRenderContext context, DocumentSkin skin) {
    final items = context.document.invoice.items;
    return DocumentTable.bordered(
      skin: skin,
      columns: _columns,
      fontSize: ClassicSections.bodySize,
      lineStep: ClassicSections.bodyStep,
      rowPaddingTop: 1.73,
      rowPaddingBottom: 0.77,
      header: ClassicSections.tableHeader(skin: skin, columns: _columns),
      rows: [
        for (final (index, line) in context.totals.lines.indexed)
          [
            ItemCells.index(index + 1),
            ItemCells.item(line, index < items.length ? items[index] : null),
            ItemCells.hsn(line),
            ItemCells.quantity(line, index < items.length ? items[index] : null),
            ItemCells.money(line.unitPrice),
            ItemCells.money(line.discountedAmount),
          ],
      ],
    );
  }

  /// Free text on the left, the ruled totals column on the right.
  pw.Widget _closing(
    DocumentRenderContext context,
    DocumentSkin skin,
    TextMeasure measure,
  ) {
    final document = context.document;
    final invoice = document.invoice;
    final totals = context.totals;
    final remaining = totals.grandTotal - document.creditsUsed;

    final rows = <TotalRow>[
      TotalRow('Sub Total', DocumentFormat.amount(totals.subtotal)),
      ...TaxLabels.rows(totals.taxLines),
      TotalRow(
        'Total',
        DocumentFormat.currency(totals.grandTotal, invoice.currency),
        bold: true,
      ),
      if (document.creditsUsed > 0)
        TotalRow(
          'Credits Used',
          DocumentFormat.deduction(document.creditsUsed),
          valueColor: DocumentPalette.negative,
        ),
    ];

    // The reference height, unless the notes or terms run longer than the
    // reference's, in which case the block grows rather than overflowing.
    final height = _closingHeight(context, skin, measure);

    return pw.SizedBox(
      height: height,
      child: pw.Stack(
        children: [
          // The totals column is ruled off from the free text beside it and
          // closed under the signature.
          pw.Positioned(
            left: _totalsLeft,
            top: 0.38,
            child: pw.Container(
              width: ClassicSections.ruleWidth,
              height: height - 0.38,
              color: DocumentPalette.frame,
            ),
          ),
          // Rule closing the totals, and the one under the signature box.
          pw.Positioned(
            left: _totalsLeft,
            top: 79.19,
            child: pw.Container(
              width: _totalsWidth,
              height: ClassicSections.ruleWidth,
              color: DocumentPalette.frame,
            ),
          ),
          pw.Positioned(
            left: _totalsLeft,
            top: height - ClassicSections.ruleWidth,
            child: pw.Container(
              width: _totalsWidth,
              height: ClassicSections.ruleWidth,
              color: DocumentPalette.frame,
            ),
          ),
          pw.Positioned(
            left: _totalsLeft + ClassicSections.ruleWidth,
            top: 1.19,
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
            top: 62.15,
            child: ModernSections.totals(
              skin: skin,
              rows: [
                TotalRow(
                  'Credits Remaining',
                  DocumentFormat.currency(remaining, invoice.currency),
                  bold: true,
                ),
              ],
              labelWidth: 135.74,
              valueWidth: 93.01,
              rowHeight: 13.66,
              rowPaddingTop: 3.28,
              size: ClassicSections.customerNameSize,
              labelPadding: 5.25,
              valuePadding: 5.25,
            ),
          ),
          pw.Positioned(
            left: _totalsLeft + ClassicSections.ruleWidth,
            top: height - 8.93,
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

  /// Reference height of the closing block, extended if the free text on the
  /// left needs more room than the reference's did.
  double _closingHeight(
    DocumentRenderContext context,
    DocumentSkin skin,
    TextMeasure measure,
  ) {
    const reference = 152.10;
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
  static const double _termsBodyBaseline = 91.97;

  /// Clearance the reference leaves under the last line of the terms.
  static const double _closingBottomMargin = 12.0;

  List<pw.Widget> _leftColumn(
    DocumentRenderContext context,
    DocumentSkin skin,
  ) {
    final invoice = context.document.invoice;
    final totals = context.totals;

    pw.Widget at(double baseline, double size, pw.Widget child) =>
        pw.Positioned(
          left: 6.00,
          top: baseline - skin.baselineOffset(size),
          child: child,
        );

    return [
      if (context.document.showAmountInWords) ...[
        at(
          19.37,
          ClassicSections.bodySize,
          pw.Text(
            'Total In Words',
            style: skin.style(
              size: ClassicSections.bodySize,
              color: DocumentPalette.strong,
            ),
          ),
        ),
        at(
          28.60,
          ClassicSections.bodySize,
          pw.SizedBox(
            width: _leftColumnWidth,
            child: pw.Text(
              AmountInWords.convert(
                totals.grandTotal,
                currency: invoice.currency,
              ),
              style: skin.style(
                size: ClassicSections.bodySize,
                italic: true,
                color: DocumentPalette.strong,
                lineStep: ClassicSections.bodyStep,
              ),
            ),
          ),
        ),
      ],
      if ((invoice.notes ?? '').isNotEmpty) ...[
        at(
          49.30,
          ClassicSections.bodySize,
          pw.Text('Notes', style: skin.style(size: ClassicSections.bodySize)),
        ),
        at(
          58.52,
          ClassicSections.bodySize,
          pw.SizedBox(
            width: _leftColumnWidth,
            child: skin.block(
              invoice.notes!.split('\n'),
              size: ClassicSections.bodySize,
              step: ClassicSections.bodyStep,
              color: DocumentPalette.strong,
            ),
          ),
        ),
      ],
      if ((invoice.terms ?? '').isNotEmpty) ...[
        at(
          82.75,
          ClassicSections.bodySize,
          pw.Text(
            'Terms & Conditions',
            style: skin.style(size: ClassicSections.bodySize),
          ),
        ),
        at(
          91.97,
          ClassicSections.bodySize,
          pw.SizedBox(
            width: _leftColumnWidth,
            child: skin.block(
              invoice.terms!.split('\n'),
              size: ClassicSections.bodySize,
              step: ClassicSections.bodyStep,
              color: DocumentPalette.strong,
            ),
          ),
        ),
      ],
    ];
  }
}
