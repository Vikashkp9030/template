import 'package:pdf/widgets.dart' as pw;

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

/// Packaging slip — `context/Packging_Slip.pdf`.
///
/// A4, set in Times. A packing document, so it carries no prices: a ruled
/// strip of package details with the total quantity boxed off at its right,
/// the two addresses side by side, and an item table of quantities only.
class PackagingSlipTemplate extends DocumentPdfTemplate {
  const PackagingSlipTemplate();

  @override
  DocumentType get type => DocumentType.packagingSlip;

  @override
  DocumentGeometry get geometry => DocumentGeometry.a4;

  static const double contentTop = 50.40;
  static const double contentBottom = 791.29;
  static const double inset = 0.75;
  static const double bodyStep = 10.05;

  /// The strip is four equal cells plus the boxed total-quantity cell.
  static const double _stripCell = 103.01;
  static const double _stripTop = 98.55;
  static const double _stripBottom = 139.73;

  @override
  pw.Page buildPage(DocumentRenderContext context) {
    final skin = DocumentSkin.serif(context.fonts);
    final document = context.document;
    final invoice = document.invoice;
    final textWidth = geometry.contentWidth - 2 * inset;

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
        footerRule: true,
        pageNumberBaseline: 807.60,
        pageNumberRight: 563.40,
      ),
      build: (_) => [
        AbsoluteRegion.build(
          minHeight: 274.88,
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
            ..._detailStrip(skin, document),
            ...ModernSections.partyBlock(
              skin: skin,
              left: inset,
              label: 'Bill To',
              name: invoice.customer.name,
              lines: ModernSections.partyLines(
                invoice.customer.billingAddress,
                invoice.customer.gstin,
              ),
              labelBaseline: 181.09,
              labelSize: 10.99,
              nameBaseline: 191.89,
              firstLineBaseline: 201.98,
              step: bodyStep,
              width: 160,
            ),
            if (shipping.isNotEmpty)
              ...ModernSections.partyBlock(
                skin: skin,
                left: 168.15,
                label: 'Ship To',
                name: '',
                lines: shipping,
                labelBaseline: 181.09,
                labelSize: 10.99,
                nameBaseline: 181.09,
                firstLineBaseline: 191.59,
                step: bodyStep,
                width: 160,
              ),
          ],
        ),
        _itemsTable(context, skin),
      ],
    );
  }

  /// Package, order and shipment identifiers between two pale rules, with the
  /// total quantity in a shaded cell at the right.
  List<PlacedBlock> _detailStrip(DocumentSkin skin, DocumentModel document) {
    final cells = <(String, String)>[
      (document.type.numberLabel, document.number),
      (
        'Order Date',
        DocumentFormat.date(document.orderDate ?? document.invoice.date),
      ),
      (
        'Package Date',
        DocumentFormat.date(document.packageDate ?? document.invoice.date),
      ),
      if ((document.salesOrderNumber ?? '').isNotEmpty)
        ('Sales Order#', document.salesOrderNumber!),
    ];

    final quantity = document.invoice.items.fold<double>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return [
      for (final top in [_stripTop, _stripBottom])
        PlacedBlock(
          left: 0,
          top: top,
          height: 1.50,
          child: pw.Container(
            width: geometry.contentWidth,
            height: 1.50,
            color: DocumentPalette.stripRule,
          ),
        ),
      PlacedBlock(
        left: 4 * _stripCell,
        top: 106.05,
        height: 27.68,
        child: pw.Container(
          width: 95.48,
          height: 27.68,
          color: DocumentPalette.stripFill,
        ),
      ),
      for (final (index, cell) in cells.indexed) ...[
        PlacedBlock.text(
          skin: skin,
          left: index * _stripCell,
          baseline: 117.68,
          size: 10.99,
          bold: true,
          width: _stripCell,
          child: pw.Text(
            cell.$1,
            style: skin.style(size: 10.99, bold: true),
          ),
        ),
        PlacedBlock.text(
          skin: skin,
          left: index * _stripCell,
          baseline: 129.94,
          size: 10.99,
          width: _stripCell,
          child: pw.Text(cell.$2, style: skin.style(size: 10.99)),
        ),
      ],
      PlacedBlock.text(
        skin: skin,
        left: 4 * _stripCell,
        baseline: 117.26,
        size: 12,
        bold: true,
        width: 95.48,
        child: pw.Text(
          'Total Qty',
          textAlign: pw.TextAlign.center,
          style: skin.style(size: 12, bold: true),
        ),
      ),
      PlacedBlock.text(
        skin: skin,
        left: 4 * _stripCell,
        baseline: 131.10,
        size: 12,
        bold: true,
        width: 95.48,
        child: pw.Text(
          DocumentFormat.quantity(quantity),
          textAlign: pw.TextAlign.center,
          style: skin.style(size: 12, bold: true),
        ),
      ),
    ];
  }

  pw.Widget _itemsTable(DocumentRenderContext context, DocumentSkin skin) {
    final items = context.document.invoice.items;
    return DocumentTable.modern(
      skin: skin,
      fontSize: ModernSections.bodySize,
      lineStep: bodyStep,
      headerPadding: 6.98,
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
          width: 376.05,
          paddingLeft: 22.5,
        ),
        DocumentColumn(
          header: 'HSN/SAC',
          width: 56.62,
          align: ColumnAlign.right,
        ),
        DocumentColumn(header: 'Qty', width: 56.63, align: ColumnAlign.right),
      ],
      rows: [
        for (final (index, line) in context.totals.lines.indexed)
          [
            ItemCells.index(index + 1),
            ItemCells.item(line, index < items.length ? items[index] : null),
            ItemCells.hsn(line),
            ItemCells.quantity(line, index < items.length ? items[index] : null),
          ],
      ],
    );
  }
}
