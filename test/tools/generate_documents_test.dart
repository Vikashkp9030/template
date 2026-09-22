@Tags(['tool'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/data/dummy/dummy_document_data.dart';
import 'package:invoice_template_preview/features/documents/document_fonts.dart';
import 'package:invoice_template_preview/features/documents/document_pdf_service.dart';
import 'package:invoice_template_preview/features/documents/document_template_registry.dart';
import 'package:invoice_template_preview/models/document/document_type.dart';

/// Writes one PDF per registered template so the output can be compared
/// against the reference files under `context/`. Not part of the normal test
/// run — it is a tool, tagged accordingly.
void main() {
  test('generate reference documents', () async {
    final outDir = Directory(
      Platform.environment['DOC_OUT'] ?? 'build/documents',
    )..createSync(recursive: true);

    final service = DocumentPdfService(
      fontLoader: () => DocumentFonts.load(
        loader: (key) async =>
            File(key).readAsBytesSync().buffer.asByteData(),
      ),
    );

    for (final type in DocumentType.values) {
      if (!DocumentTemplateRegistry.templates.containsKey(type)) continue;
      final bytes = await service.generate(DummyDocumentData.document(type));
      File('${outDir.path}/${type.name}.pdf').writeAsBytesSync(bytes);
    }
  });
}
