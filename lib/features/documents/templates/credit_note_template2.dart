import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/amount_in_words.dart';
import '../../../models/document/document_type.dart';
import '../document_template.dart';
import '../theme/document_geometry.dart';
import '../theme/document_palette.dart';
import '../theme/document_skin.dart';
import '../widgets/baseline_stack.dart';
import '../widgets/document_format.dart';
import '../widgets/document_page_theme.dart';
import '../widgets/document_table.dart';
import '../widgets/item_cells.dart';
import '../widgets/modern_sections.dart';
import '../widgets/tax_labels.dart';
import '../widgets/text_measure.dart';

/// Credit note, spreadsheet layout — `context/Credit_Note_Template2.pdf`.
///
/// A4, no page frame: the company block and the title sit at the top, the
/// customer and the credit details face each other, and the dark-header item
/// table is followed by right-aligned totals closing on a pale bar.
class CreditNoteTemplate2 extends DocumentPdfTemplate {
  const CreditNoteTemplate2();

  @override
  DocumentType get type => DocumentType.creditNoteTemplate2;

  @override
  DocumentGeometry get geometry => DocumentGeometry.a4;

  /// Top of the content box; every measured baseline below is relative to it.
  static const double contentTop = 50.40;
  static const double contentBottom = 791.29;

  /// The header text is inset from the content box by the frame width the
  /// reference HTML reserves.
  static const double inset = 0.75;

  @override
  pw.Page buildPage(DocumentRenderContext context) {
    final skin = DocumentSkin.sans(context.fonts);
    final document = context.document;
    final invoice = document.invoice;
    final totals = context.totals;
    final width = geometry.contentWidth;
    final textWidth = width - 2 * inset;

    final remaining = totals.grandTotal - document.creditsUsed;

    return pw.MultiPage(
      pageTheme: DocumentPageTheme.build(
        geometry: geometry,
        skin: skin,
        contentTop: contentTop,
        contentBottom: contentBottom,
        footerRule: true,
        pageNumberBaseline: 807.98,
        pageNumberRight: 562.85,
      ),
      build: (pageContext) => [
        AbsoluteRegion.build(
          minHeight: 249.57,
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
              left: 0,
              right: textWidth + inset,
              title: document.title,
              number: '${document.type.numberLabel} ${document.number}',
              titleBaseline: 33.71,
              numberBaseline: 48.64,
              highlightLabel: 'Credits Remaining',
              highlightValue: DocumentFormat.currency(
                remaining,
                invoice.currency,
              ),
              highlightLabelBaseline: 74.51,
              highlightValueBaseline: 87.83,
            ),
            ...ModernSections.partyBlock(
              skin: skin,
              left: inset,
              label: 'Bill To',
              name: invoice.customer.name,
              lines: ModernSections.partyLines(
                invoice.customer.billingAddress,
                invoice.customer.gstin,
              ),
              labelBaseline: 126.19,
              nameBaseline: 136.76,
              firstLineBaseline: 147.41,
              width: 250,
            ),
            PlacedBlock(
              left: 294.46,
              top: 114.64,
              width: 219.82,
              height: 76.2,
              child: ModernSections.infoRows(
                skin: skin,
                labelWidth: 110,
                valueWidth: 109.82,
                rows: _infoRows(context),
              ),
            ),
            if ((document.subject ?? '').isNotEmpty ||
                (document.description ?? '').isNotEmpty) ...[
              PlacedBlock.text(
                skin: skin,
                left: 0,
                baseline: 215.10,
                size: ModernSections.bodySize,
                child: pw.Text(
                  'Subject :${(document.subject ?? '').isEmpty ? '' : ' ${document.subject}'}',
                  style: skin.style(size: ModernSections.bodySize),
                ),
              ),
              if ((document.description ?? '').isNotEmpty)
                PlacedBlock.text(
                  skin: skin,
                  left: 0,
                  baseline: 231.04,
                  size: ModernSections.bodySize,
                  width: textWidth,
                  child: pw.Text(
                    document.description!,
                    style: skin.style(size: ModernSections.bodySize),
                  ),
                ),
            ],
          ],
        ),
        _itemsTable(context, skin),
        BaselineStack.column(
          _belowTable(context, skin, remaining, TextMeasure(pageContext)),
        ),
      ],
    );
  }

  List<InfoRow> _infoRows(DocumentRenderContext context) {
    final document = context.document;
    return [
      InfoRow('Credit Date :', DocumentFormat.date(document.invoice.date)),
      if ((document.referenceNumber ?? '').isNotEmpty)
        InfoRow('Ref# :', document.referenceNumber!),
      if ((document.linkedInvoiceNumber ?? '').isNotEmpty)
        InfoRow('Invoice# :', document.linkedInvoiceNumber!),
      if (document.linkedInvoiceDate != null)
        InfoRow(
          'Invoice Date :',
          DocumentFormat.shortDate(document.linkedInvoiceDate!),
        ),
    ];
  }

  pw.Widget _itemsTable(DocumentRenderContext context, DocumentSkin skin) {
    final items = context.document.invoice.items;
    return DocumentTable.modern(
      skin: skin,
      fontSize: ModernSections.bodySize,
      lineStep: ModernSections.bodyStep,
      columns: const [
        DocumentColumn(
          header: '#',
          width: 25.73,
          align: ColumnAlign.center,
          paddingLeft: 11.27,
        ),
        DocumentColumn(
          header: 'Item & Description',
          width: 221.55,
          paddingLeft: 15.0,
          paddingRight: 3.5,
        ),
        DocumentColumn(
          header: 'HSN/SAC',
          width: 77.25,
          align: ColumnAlign.right,
        ),
        DocumentColumn(header: 'Qty', width: 56.62, align: ColumnAlign.right),
        DocumentColumn(header: 'Rate', width: 56.63, align: ColumnAlign.right),
        DocumentColumn(
          header: 'Amount',
          width: 77.25,
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
            ItemCells.money(line.discountedAmount),
          ],
      ],
    );
  }

  List<BaselineBlock> _belowTable(
    DocumentRenderContext context,
    DocumentSkin skin,
    double remaining,
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
      ),
      if (document.creditsUsed > 0)
        TotalRow(
          'Credits Used',
          DocumentFormat.deduction(document.creditsUsed),
          valueColor: DocumentPalette.negative,
        ),
      TotalRow(
        'Credits Remaining',
        DocumentFormat.currency(remaining, invoice.currency),
        bold: true,
        highlighted: true,
      ),
    ];

    return [
      BaselineBlock.box(
        top: 0,
        height: rows.fold<double>(
          0,
          (sum, row) => sum + (row.highlighted ? 30 : 25.45),
        ),
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(left: 257.51),
          child: ModernSections.totals(
            skin: skin,
            rows: rows,
            labelWidth: 156.27,
            valueWidth: 101.25,
          ),
        ),
      ),
      BaselineBlock.box(
          visible: document.showAmountInWords,
          top: 173.74 - skin.baselineOffset(ModernSections.bodySize),
          height: ModernSections.wordsHeight(
            skin: skin,
            measure: measure,
            words: words,
            valueWidth: 127.50,
          ),
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 257.51),
            child: ModernSections.amountInWords(
              skin: skin,
              words: words,
              labelWidth: 120.99,
              valueWidth: 127.50,
              gap: 8.28,
            ),
          ),
        ),
      ...ModernSections.textSection(
          skin: skin,
          label: 'Notes',
          body: invoice.notes ?? '',
          labelTop: 235.01,
          bodyTop: 249.86,
          width: geometry.contentWidth,
        ),
      ...ModernSections.textSection(
          skin: skin,
          label: 'Terms & Conditions',
          body: invoice.terms ?? '',
          labelTop: 283.54,
          bodyTop: 298.39,
          width: geometry.contentWidth,
        ),
      BaselineBlock.text(
          skin: skin,
          baseline: 332.06,
          size: ModernSections.labelSize,
          visible: document.showSignature,
          child: ModernSections.signature(
            skin: skin,
            lineLeft: 100.61,
            lineWidth: 150.0,
            lineTop: 8.42,
            width: geometry.contentWidth,
          ),
        ),
    ];
  }

}
