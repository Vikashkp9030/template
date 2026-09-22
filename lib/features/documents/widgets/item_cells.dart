import '../../../models/invoice/invoice_item_model.dart';
import '../../../models/invoice/invoice_totals.dart';
import '../theme/document_palette.dart';
import 'document_format.dart';
import 'document_table.dart';

/// Cells shared by the item tables. Every reference prints the item name over
/// a grey description and the quantity over a grey unit, so those two shapes
/// are built once here.
class ItemCells {
  const ItemCells._();

  static List<CellLine> index(int position) => [
    CellLine('$position'),
  ];

  static List<CellLine> item(LineTotal line, InvoiceItemModel? source) => [
    CellLine(line.name),
    if ((source?.description ?? '').isNotEmpty)
      CellLine(source!.description!, color: DocumentPalette.muted),
  ];

  static List<CellLine> hsn(LineTotal line) => [
    CellLine(line.hsnSac ?? ''),
  ];

  static List<CellLine> quantity(LineTotal line, InvoiceItemModel? source) => [
    CellLine(DocumentFormat.quantity(line.quantity)),
    if ((source?.unit ?? '').isNotEmpty)
      CellLine(source!.unit, color: DocumentPalette.muted),
  ];

  /// Quantity coming back on a return, over its grey unit.
  static List<CellLine> returnedQuantity(
    LineTotal line,
    InvoiceItemModel? source,
  ) => [
    CellLine(
      DocumentFormat.quantity(source?.returnedQuantity ?? line.quantity),
    ),
    if ((source?.unit ?? '').isNotEmpty)
      CellLine(source!.unit, color: DocumentPalette.muted),
  ];

  static List<CellLine> money(num value) => [
    CellLine(DocumentFormat.amount(value)),
  ];

  static List<CellLine> text(String value) => [CellLine(value)];

  /// One half of an Indian GST split, as the invoice templates print it: the
  /// amount over the grey rate the item was taxed at.
  static List<CellLine> gstHalf(LineTotal line) => [
    CellLine(DocumentFormat.amount(line.taxAmount / 2)),
    CellLine(
      '${_trimRate(line.taxRate)}%',
      color: DocumentPalette.muted,
    ),
  ];

  static String _trimRate(double rate) {
    final rounded = rate.toStringAsFixed(2);
    return rounded.endsWith('.00')
        ? rounded.substring(0, rounded.length - 3)
        : rounded;
  }
}
