import 'package:pdf/widgets.dart' as pw;

import '../../models/document/document_model.dart';
import '../../models/document/document_type.dart';
import '../../models/invoice/invoice_totals.dart';
import 'document_fonts.dart';
import 'theme/document_geometry.dart';

/// Everything a template needs to render one document.
class DocumentRenderContext {
  const DocumentRenderContext({
    required this.document,
    required this.totals,
    required this.fonts,
  });

  final DocumentModel document;

  /// Line, tax and grand totals from the shared [InvoiceCalculator].
  final InvoiceTotals totals;

  final DocumentFonts fonts;
}

/// One reference layout, reproduced as PDF widgets.
///
/// Implementations own only their own arrangement; the header, party block,
/// item table, totals, notes and signature components they compose are shared
/// so the eight templates do not re-implement them.
abstract class DocumentPdfTemplate {
  const DocumentPdfTemplate();

  DocumentType get type;

  /// Page size and content box of this template's reference PDF.
  DocumentGeometry get geometry;

  /// The page — always a `MultiPage`, so long item lists paginate with the
  /// table header repeated.
  pw.Page buildPage(DocumentRenderContext context);
}
