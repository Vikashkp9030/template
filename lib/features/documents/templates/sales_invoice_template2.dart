import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/amount_in_words.dart';
import '../../../models/document/document_model.dart';
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

/// Tax invoice, spreadsheet layout — `context/Sales Invoice2.pdf`.
///
/// US Letter. The widest of the item tables: it breaks the GST out into CGST
/// and SGST columns, and the closing figure is the balance due after
/// retention and payments. The reference runs to a second page, so the notes,
/// terms and signature are a separate flow group that moves as a unit.
class SalesInvoiceTemplate2 extends DocumentPdfTemplate {
  const SalesInvoiceTemplate2();

  @override
  DocumentType get type => DocumentType.salesInvoiceTemplate2;

  @override
  DocumentGeometry get geometry => DocumentGeometry.letter;

  static const double contentTop = 50.40;
  static const double contentBottom = 770.00;
  static const double inset = 0.75;


  @override
  pw.Page buildPage(DocumentRenderContext context) {
    final skin = DocumentSkin.sans(context.fonts);
    final document = context.document;
    final invoice = document.invoice;
    final totals = context.totals;
    final textWidth = geometry.contentWidth - 2 * inset;

    // The reference lists payment retention for information and takes only
    // the payment made off the balance, so the printed balance is reproduced
    // the same way.
    final balance = totals.grandTotal - document.paymentMade;

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
      ),
      build: (pageContext) => [
        AbsoluteRegion.build(
          minHeight: 316.08,
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
              numberBaseline: 48.64,
              titleStep: 32.04,
              highlightLabel: 'Balance Due',
              highlightValue: DocumentFormat.currency(
                balance,
                invoice.currency,
              ),
              highlightLabelBaseline: 74.68,
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
              labelBaseline: 124.75,
              nameBaseline: 135.32,
              firstLineBaseline: 145.61,
              width: 250,
            ),
            if (shipping.isNotEmpty)
              ...ModernSections.partyBlock(
                skin: skin,
                left: inset,
                label: 'Ship To',
                name: '',
                lines: shipping,
                labelBaseline: 214.03,
                nameBaseline: 214.03,
                firstLineBaseline: 224.45,
                width: 250,
              ),
            PlacedBlock(
              left: 295.43,
              top: 181.71,
              width: 219.70,
              height: 80,
              child: ModernSections.infoRows(
                skin: skin,
                labelWidth: 110,
                valueWidth: 109.70,
                rows: _infoRows(document),
              ),
            ),
            PlacedBlock.text(
              skin: skin,
              left: 0,
              baseline: 281.97,
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
                baseline: 298.17,
                size: ModernSections.bodySize,
                width: textWidth,
                child: pw.Text(
                  document.description!,
                  style: skin.style(size: ModernSections.bodySize),
                ),
              ),
          ],
        ),
        _itemsTable(context, skin),
        BaselineStack.column(
          _totalsGroup(context, skin, TextMeasure(pageContext), balance),
        ),
        BaselineStack.column(_closingGroup(context, skin)),
      ],
    );
  }

  List<InfoRow> _infoRows(DocumentModel document) => [
    InfoRow('Invoice Date :', DocumentFormat.date(document.invoice.date)),
    if ((document.paymentTerms ?? '').isNotEmpty)
      InfoRow('Terms :', document.paymentTerms!),
    if (document.invoice.dueDate != null)
      InfoRow('Due Date :', DocumentFormat.date(document.invoice.dueDate!)),
    if ((document.referenceNumber ?? '').isNotEmpty)
      InfoRow('P.O.# :', document.referenceNumber!),
  ];

  pw.Widget _itemsTable(DocumentRenderContext context, DocumentSkin skin) {
    final items = context.document.invoice.items;
    final interState = context.document.invoice.interState;
    return DocumentTable.modern(
      skin: skin,
      fontSize: ModernSections.bodySize,
      lineStep: ModernSections.bodyStep,
      headerPadding: 3.98,
      rowPaddingTop: 7.90,
      rowPaddingBottom: 7.35,
      ruleWidth: 0.84,
      columns: [
        const DocumentColumn(
          header: '#',
          width: 21.48,
          align: ColumnAlign.center,
          paddingLeft: 5.0,
          paddingRight: 1.64,
        ),
        const DocumentColumn(
          header: 'Item & Description',
          width: 129.00,
          paddingLeft: 15.0,
          paddingRight: 3.5,
        ),
        const DocumentColumn(
          header: 'HSN/SAC',
          width: 64.44,
          align: ColumnAlign.right,
        ),
        const DocumentColumn(
          header: 'Qty',
          width: 47.28,
          align: ColumnAlign.right,
        ),
        const DocumentColumn(
          header: 'Rate',
          width: 47.28,
          align: ColumnAlign.right,
        ),
        const DocumentColumn(
          header: 'Discount',
          width: 47.40,
          align: ColumnAlign.right,
        ),
        DocumentColumn(
          header: interState ? 'IGST' : 'CGST',
          width: 47.16,
          align: ColumnAlign.right,
        ),
        DocumentColumn(
          header: interState ? 'CESS' : 'SGST',
          width: 47.28,
          align: ColumnAlign.right,
        ),
        const DocumentColumn(
          header: 'Amount',
          width: 64.56,
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
            ItemCells.gstHalf(line),
            ItemCells.gstHalf(line),
            ItemCells.money(line.discountedAmount),
          ],
      ],
    );
  }

  List<BaselineBlock> _totalsGroup(
    DocumentRenderContext context,
    DocumentSkin skin,
    TextMeasure measure,
    double balance,
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
      TotalRow(
        'Balance Due',
        DocumentFormat.currency(balance, invoice.currency),
        bold: true,
        highlighted: true,
      ),
    ];

    return [
      BaselineBlock.box(
        top: 0,
        height: rows.fold<double>(
          0,
          (sum, row) => sum + (row.highlighted ? 30 : 25.50),
        ),
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(left: 257.88),
          child: ModernSections.totals(
            skin: skin,
            rows: rows,
            labelWidth: 156.32,
            valueWidth: 101.68,
            rowHeight: 25.50,
            rowPaddingTop: 8.14,
            highlightPaddingTop: 10.30,
          ),
        ),
      ),
      BaselineBlock.box(
          visible: document.showAmountInWords,
          top: 199.41 - skin.baselineOffset(ModernSections.bodySize),
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
    ];
  }

  List<BaselineBlock> _closingGroup(
    DocumentRenderContext context,
    DocumentSkin skin,
  ) {
    final document = context.document;
    final invoice = document.invoice;

    return [
      ...ModernSections.textSection(
          skin: skin,
          label: 'Notes',
          body: invoice.notes ?? '',
          labelTop: 24.96,
          bodyTop: 39.88,
          width: geometry.contentWidth,
        ),
      BaselineBlock.text(
          skin: skin,
          visible: document.showPaymentOptions,
          baseline: 66.72,
          size: ModernSections.labelSize,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(
                width: 79.20,
                child: pw.Text(
                  'Payment Options',
                  style: skin.style(size: ModernSections.labelSize),
                ),
              ),
              if (document.paymentOptionsLogo != null)
                pw.Image(
                  pw.MemoryImage(document.paymentOptionsLogo!),
                  width: 70.92,
                  height: 13.32,
                ),
            ],
          ),
        ),
      ...ModernSections.textSection(
          skin: skin,
          label: 'Terms & Conditions',
          body: invoice.terms ?? '',
          labelTop: 101.28,
          bodyTop: 116.20,
          width: geometry.contentWidth,
        ),
      BaselineBlock.text(
          skin: skin,
          visible: document.showSignature,
          baseline: 150.00,
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
