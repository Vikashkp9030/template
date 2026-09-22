import 'dart:io';
import 'dart:typed_data';

import 'package:invoice_template_preview/features/documents/document_fonts.dart';
import 'package:invoice_template_preview/features/documents/document_pdf_service.dart';

/// Loads the bundled fonts straight off disk, so the document tests run
/// without an asset bundle.
Future<DocumentFonts> testFonts() => DocumentFonts.load(
  loader: (key) async => File(key).readAsBytesSync().buffer.asByteData(),
);

DocumentPdfService testService() => DocumentPdfService(fontLoader: testFonts);

/// Page sizes declared in a PDF, in points, one entry per page.
List<({double width, double height})> pageSizes(Uint8List bytes) {
  final text = String.fromCharCodes(bytes);
  return [
    for (final match in RegExp(
      r'/MediaBox\s*\[\s*([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)\s*\]',
    ).allMatches(text))
      (
        width: double.parse(match.group(3)!) - double.parse(match.group(1)!),
        height: double.parse(match.group(4)!) - double.parse(match.group(2)!),
      ),
  ];
}

int pageCount(Uint8List bytes) => pageSizes(bytes).length;
