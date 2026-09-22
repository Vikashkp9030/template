import 'package:pdf/widgets.dart' as pw;

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

/// Sales order — `context/SO_Template.pdf`.
///
/// US Letter, spreadsheet layout. Bill-to sits above ship-to on the left with
/// the order details facing them, and the totals close on a pale bar with no
/// amount in words.
class SalesOrderTemplate extends DocumentPdfTemplate {
  const SalesOrderTemplate();

  @override
  DocumentType get type => DocumentType.salesOrder;

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
    final width = geometry.contentWidth;
    final textWidth = width - 2 * inset;

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
      build: (_) => [
        AbsoluteRegion.build(
          minHeight: 252.72,
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
              number: document.numberLine,
              titleBaseline: 33.71,
              numberBaseline: 48.64,
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
              labelBaseline: 104.23,
              nameBaseline: 114.80,
              firstLineBaseline: 125.45,
              width: 250,
            ),
            if (shipping.isNotEmpty)
              ...ModernSections.partyBlock(
                skin: skin,
                left: inset,
                label: 'Ship To',
                name: '',
                lines: shipping,
                labelBaseline: 193.87,
                nameBaseline: 193.87,
                firstLineBaseline: 204.29,
                width: 250,
              ),
            PlacedBlock(
              left: 295.43,
              top: 149.67,
              width: 219.70,
              height: 80,
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
        BaselineStack.column(_belowTable(context, skin)),
      ],
    );
  }

  List<InfoRow> _infoRows(DocumentModel document) {
    return [
      InfoRow(
        'Order Date :',
        DocumentFormat.date(document.orderDate ?? document.invoice.date),
      ),
      if (document.expectedShipmentDate != null)
        InfoRow(
          'Expected Shipment Date :',
          DocumentFormat.date(document.expectedShipmentDate!),
        ),
      if ((document.referenceNumber ?? '').isNotEmpty)
        InfoRow('Ref# :', document.referenceNumber!),
      if ((document.deliveryMethod ?? '').isNotEmpty)
        InfoRow('Delivery Method :', document.deliveryMethod!),
    ];
  }

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
          width: 165.24,
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
          width: 77.40,
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
  ) {
    final invoice = context.document.invoice;
    final totals = context.totals;

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
            rowPaddingTop: 8.05,
            highlightPaddingTop: 9.99,
          ),
        ),
      ),
      ...ModernSections.textSection(
          skin: skin,
          label: 'Notes',
          body: invoice.notes ?? '',
          labelTop: 153.84,
          bodyTop: 168.74,
          width: geometry.contentWidth,
        ),
      ...ModernSections.textSection(
          skin: skin,
          label: 'Terms & Conditions',
          body: invoice.terms ?? '',
          labelTop: 202.44,
          bodyTop: 217.34,
          width: geometry.contentWidth,
        ),
      BaselineBlock.text(
          skin: skin,
          visible: context.document.showSignature,
          baseline: 251.14,
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
