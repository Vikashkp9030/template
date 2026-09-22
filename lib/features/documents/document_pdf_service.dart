import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../../core/errors/app_exception.dart';
import '../../core/helpers/invoice_calculator.dart';
import '../../models/document/document_model.dart';
import '../../models/document/document_type.dart';
import 'document_fonts.dart';
import 'document_template.dart';
import 'document_template_registry.dart';

/// Renders a [DocumentModel] to PDF bytes using the template registered for
/// its type.
///
/// Fonts are loaded once and cached, since every document shares them and
/// parsing the Ubuntu TTFs on each call would dominate the render cost.
class DocumentPdfService {
  DocumentPdfService({
    InvoiceCalculator? calculator,
    DocumentFonts? fonts,
    Future<DocumentFonts> Function()? fontLoader,
  }) : _calculator = calculator ?? InvoiceCalculator(),
       _fonts = fonts,
       _fontLoader = fontLoader ?? DocumentFonts.load;

  final InvoiceCalculator _calculator;
  final Future<DocumentFonts> Function() _fontLoader;

  DocumentFonts? _fonts;

  Future<DocumentFonts> fonts() async => _fonts ??= await _fontLoader();

  Future<Uint8List> generate(DocumentModel document) async {
    if (document.invoice.items.isEmpty) {
      throw const InvoiceValidationException(
        'A document must contain at least one line item.',
      );
    }

    final template = DocumentTemplateRegistry.get(document.type);

    try {
      final totals = _calculator.calculate(document.invoice);
      final doc = pw.Document(
        title: '${document.type.title} ${document.number}',
      );
      doc.addPage(
        template.buildPage(
          DocumentRenderContext(
            document: document,
            totals: totals,
            fonts: await fonts(),
          ),
        ),
      );
      return await doc.save();
    } on AppException {
      // Validation and font failures already say what went wrong.
      rethrow;
    } catch (error, stack) {
      Error.throwWithStackTrace(
        PdfGenerationException(
          'Unable to render ${document.type.displayName} '
          '${document.number}.',
          cause: error,
        ),
        stack,
      );
    }
  }
}
