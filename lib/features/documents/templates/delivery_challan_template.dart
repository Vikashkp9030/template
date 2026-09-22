import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/amount_in_words.dart';
import '../../../models/document/document_model.dart';
import '../../../models/document/document_type.dart';
import '../document_template.dart';
import '../theme/document_geometry.dart';
import '../theme/document_skin.dart';
import '../widgets/baseline_stack.dart';
import '../widgets/document_format.dart';
import '../widgets/document_page_theme.dart';
import '../widgets/document_table.dart';
import '../widgets/item_cells.dart';
import '../widgets/modern_sections.dart';
import '../widgets/tax_labels.dart';
import '../widgets/text_measure.dart';

/// Delivery challan — `context/DC_Template1.pdf`.
///
/// US Letter, spreadsheet layout. A single "Deliver To" block faces the
/// challan details, and the totals close on a pale bar followed by the amount
/// in words.
class DeliveryChallanTemplate extends DocumentPdfTemplate {
  const DeliveryChallanTemplate();

  @override
  DocumentType get type => DocumentType.deliveryChallan;

  @override
  DocumentGeometry get geometry => DocumentGeometry.letter;

  static const double contentTop = 50.40;
  static const double contentBottom = 741.60;
  static const double inset = 0.75;

  @override
  pw.Page buildPage(DocumentRenderContext context) {
    final skin = DocumentSkin.sans(context.fonts);
    final document = context.document;
    final invoice = document.invoice;
    final textWidth = geometry.contentWidth - 2 * inset;

    return pw.MultiPage(
      pageTheme: DocumentPageTheme.build(
        geometry: geometry,
        skin: skin,
        contentTop: contentTop,
        contentBottom: contentBottom,
      ),
      build: (pageContext) => [
        AbsoluteRegion.build(
          minHeight: 201.96,
          [
            ...ModernSections.companyBlock(
              skin: skin,
              company: invoice.company,
              left: inset,
              nameBaseline: 16.39,
              addressBaseline: 27.26,
              width: textWidth,
            ),
            ...ModernSections.titleBlock(
              skin: skin,
              left: textWidth + inset - ModernSections.titleWidth(textWidth),
              right: textWidth + inset,
              title: document.title,
              number: document.numberLine,
              titleBaseline: 33.71,
              numberBaseline: 81.20,
              titleStep: 32.04,
            ),
            // A challan is a delivery note, so it prints the delivery address
            // without the customer's GSTIN.
            ...ModernSections.partyBlock(
              skin: skin,
              left: inset,
              label: 'Deliver To',
              name: invoice.customer.name,
              lines: ModernSections.partyLines(
                invoice.customer.shippingAddress ??
                    invoice.customer.billingAddress,
                null,
              ),
              labelBaseline: 132.31,
              nameBaseline: 142.88,
              firstLineBaseline: 153.53,
              width: 250,
            ),
            PlacedBlock(
              left: 295.43,
              top: 129.51,
              width: 219.70,
              height: 60,
              child: ModernSections.infoRows(
                skin: skin,
                labelWidth: 110,
                valueWidth: 109.70,
                rows: _infoRows(document),
              ),
            ),
          ],
        ),
        _itemsTable(context, skin),
        BaselineStack.column(
          _belowTable(context, skin, TextMeasure(pageContext)),
        ),
      ],
    );
  }

  List<InfoRow> _infoRows(DocumentModel document) => [
    InfoRow('Challan Date :', DocumentFormat.date(document.invoice.date)),
    if ((document.referenceNumber ?? '').isNotEmpty)
      InfoRow('Ref# :', document.referenceNumber!),
    if ((document.challanType ?? '').isNotEmpty)
      InfoRow('Challan Type :', document.challanType!),
  ];

  pw.Widget _itemsTable(DocumentRenderContext context, DocumentSkin skin) {
    final items = context.document.invoice.items;
    return DocumentTable.modern(
      skin: skin,
      fontSize: ModernSections.bodySize,
      lineStep: ModernSections.bodyStep,
      headerPadding: 7.02,
      rowPaddingTop: 8.26,
      rowPaddingBottom: 7.14,
      ruleWidth: 0.84,
      columns: const [
        DocumentColumn(
          header: '#',
          width: 25.68,
          align: ColumnAlign.center,
          paddingLeft: 11.27,
        ),
        DocumentColumn(
          header: 'Item & Description',
          width: 141.24,
          paddingLeft: 15.0,
          paddingRight: 3.5,
        ),
        DocumentColumn(
          header: 'HSN/SAC',
          width: 77.28,
          align: ColumnAlign.right,
        ),
        DocumentColumn(header: 'Qty', width: 56.76, align: ColumnAlign.right),
        DocumentColumn(header: 'Rate', width: 56.76, align: ColumnAlign.right),
        DocumentColumn(
          header: 'Discount',
          width: 56.76,
          align: ColumnAlign.right,
        ),
        DocumentColumn(
          header: 'Amount',
          width: 101.40,
          align: ColumnAlign.right,
        ),
      ],
      rows: [
        for (final (index, line) in context.totals.lines.indexed)
          [
            ItemCells.index(index + 1),
            ItemCells.item(line, index < items.length ? items[index] : null),
            ItemCells.hsn(line),
            ItemCells.quantity(line, index < items.length ? items[index] : null),
            ItemCells.money(line.unitPrice),
            ItemCells.money(line.discount),
            ItemCells.money(line.discountedAmount),
          ],
      ],
    );
  }

  List<BaselineBlock> _belowTable(
    DocumentRenderContext context,
    DocumentSkin skin,
    TextMeasure measure,
  ) {
    final document = context.document;
    final invoice = document.invoice;
    final totals = context.totals;

    final words = AmountInWords.convert(
      totals.grandTotal,
      currency: invoice.currency,
    );

    final rows = <TotalRow>[
      TotalRow('Sub Total', DocumentFormat.amount(totals.subtotal)),
      ...TaxLabels.rows(totals.taxLines),
      TotalRow(
        'Total',
        DocumentFormat.currency(totals.grandTotal, invoice.currency),
        bold: true,
        highlighted: true,
      ),
    ];

    return [
      BaselineBlock.box(
        top: 0,
        height: rows.fold<double>(
          0,
          (sum, row) => sum + (row.highlighted ? 30 : 25.52),
        ),
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(left: 257.88),
          child: ModernSections.totals(
            skin: skin,
            rows: rows,
            labelWidth: 156.32,
            valueWidth: 101.68,
            rowHeight: 25.52,
            rowPaddingTop: 8.14,
            highlightPaddingTop: 10.06,
          ),
        ),
      ),
      BaselineBlock.box(
          visible: document.showAmountInWords,
          top: 123.09 - skin.baselineOffset(ModernSections.bodySize),
          height: ModernSections.wordsHeight(
            skin: skin,
            measure: measure,
            words: words,
            valueWidth: 127.80,
          ),
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 257.88),
            child: ModernSections.amountInWords(
              skin: skin,
              words: words,
              labelWidth: 121.92,
              valueWidth: 127.80,
              gap: 8.28,
            ),
          ),
        ),
      ...ModernSections.textSection(
          skin: skin,
          label: 'Notes',
          body: invoice.notes ?? '',
          labelTop: 183.96,
          bodyTop: 198.86,
          width: geometry.contentWidth,
        ),
      ...ModernSections.textSection(
          skin: skin,
          label: 'Terms & Conditions',
          body: invoice.terms ?? '',
          labelTop: 232.56,
          bodyTop: 247.46,
          width: geometry.contentWidth,
        ),
      BaselineBlock.text(
          skin: skin,
          visible: document.showSignature,
          baseline: 281.26,
          size: ModernSections.labelSize,
          child: ModernSections.signature(
            skin: skin,
            lineLeft: 100.68,
            lineWidth: 150.24,
            lineTop: 8.51,
            ruleWidth: 0.84,
            width: geometry.contentWidth,
          ),
        ),
    ];
  }
}
