import 'package:pdf/widgets.dart' as pw;

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

/// Sales return — `context/Sales_Return_Template1.pdf`.
///
/// A4, set in Times. Spreadsheet layout with a "Returned Qty" column, a two
/// line summary that does not itemise tax, and a reason at the foot.
class SalesReturnTemplate extends DocumentPdfTemplate {
  const SalesReturnTemplate();

  @override
  DocumentType get type => DocumentType.salesReturn;

  @override
  DocumentGeometry get geometry => DocumentGeometry.a4;

  static const double contentTop = 50.40;
  static const double contentBottom = 791.29;
  static const double inset = 0.75;

  /// Times body copy sits on a slightly tighter rhythm than the Ubuntu
  /// documents.
  static const double bodyStep = 10.05;

  @override
  pw.Page buildPage(DocumentRenderContext context) {
    final skin = DocumentSkin.serif(context.fonts);
    final document = context.document;
    final invoice = document.invoice;
    final textWidth = geometry.contentWidth - 2 * inset;

    return pw.MultiPage(
      pageTheme: DocumentPageTheme.build(
        geometry: geometry,
        skin: skin,
        contentTop: contentTop,
        contentBottom: contentBottom,
        footerRule: true,
        pageNumberBaseline: 807.60,
        pageNumberRight: 563.40,
      ),
      build: (_) => [
        AbsoluteRegion.build(
          minHeight: 180.12,
          [
            ...ModernSections.companyBlock(
              skin: skin,
              company: invoice.company,
              left: inset,
              nameBaseline: 16.13,
              addressBaseline: 26.40,
              step: bodyStep,
              width: textWidth,
            ),
            ...ModernSections.titleBlock(
              skin: skin,
              left: 0,
              right: textWidth + inset,
              title: document.title,
              number: '${document.type.numberLabel} ${document.number}',
              titleBaseline: 31.91,
              numberBaseline: 47.40,
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
              labelBaseline: 101.55,
              nameBaseline: 112.13,
              firstLineBaseline: 122.21,
              step: bodyStep,
              width: 250,
            ),
            PlacedBlock(
              left: 304.63,
              top: 145.51,
              width: 209.65,
              height: 19.05,
              child: ModernSections.infoRows(
                skin: skin,
                labelWidth: 110,
                valueWidth: 99.65,
                rows: [
                  InfoRow('Date :', DocumentFormat.date(invoice.date)),
                ],
              ),
            ),
          ],
        ),
        _itemsTable(context, skin),
        BaselineStack.column(_belowTable(context, skin)),
      ],
    );
  }

  pw.Widget _itemsTable(DocumentRenderContext context, DocumentSkin skin) {
    final items = context.document.invoice.items;
    return DocumentTable.modern(
      skin: skin,
      fontSize: ModernSections.bodySize,
      lineStep: bodyStep,
      headerPadding: 3.75,
      headerLineStep: bodyStep,
      rowPaddingTop: 7.52,
      rowPaddingBottom: 7.49,
      columns: const [
        DocumentColumn(
          header: '#',
          width: 25.73,
          align: ColumnAlign.center,
          paddingLeft: 11.27,
        ),
        DocumentColumn(
          header: 'Item & Description',
          width: 197.55,
          paddingLeft: 15.0,
          paddingRight: 1.0,
        ),
        DocumentColumn(
          header: 'HSN/SAC',
          width: 77.25,
          align: ColumnAlign.right,
        ),
        DocumentColumn(
          header: 'Returned Qty',
          width: 56.62,
          align: ColumnAlign.right,
        ),
        DocumentColumn(header: 'Rate', width: 56.63, align: ColumnAlign.right),
        DocumentColumn(
          header: 'Amount',
          width: 101.25,
          align: ColumnAlign.right,
        ),
      ],
      rows: [
        for (final (index, line) in context.totals.lines.indexed)
          [
            ItemCells.index(index + 1),
            ItemCells.item(line, index < items.length ? items[index] : null),
            ItemCells.hsn(line),
            ItemCells.returnedQuantity(
              line,
              index < items.length ? items[index] : null,
            ),
            ItemCells.money(line.unitPrice),
            ItemCells.money(line.discountedAmount),
          ],
      ],
    );
  }

  List<BaselineBlock> _belowTable(
    DocumentRenderContext context,
    DocumentSkin skin,
  ) {
    final document = context.document;
    final totals = context.totals;

    // The reference summarises a return with the net and the gross only; the
    // tax that makes up the difference is not broken out.
    final rows = <TotalRow>[
      TotalRow('Sub Total', DocumentFormat.amount(totals.subtotal)),
      TotalRow('Total', DocumentFormat.amount(totals.grandTotal), bold: true),
    ];

    return [
      BaselineBlock.box(
        top: 0,
        height: rows.length * 25.35,
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(left: 257.51),
          child: ModernSections.totals(
            skin: skin,
            rows: rows,
            labelWidth: 156.27,
            valueWidth: 101.25,
            rowHeight: 25.35,
            rowPaddingTop: 7.90,
          ),
        ),
      ),
      ...ModernSections.textSection(
          skin: skin,
          label: document.returnReasonLabel,
          body: document.returnReason ?? '',
          labelTop: 97.32,
          bodyTop: 111.91,
          bodyStep: 9.22,
          width: geometry.contentWidth,
        ),
    ];
  }
}
