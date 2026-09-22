import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/dummy/dummy_document_data.dart';
import '../../../models/document/document_model.dart';
import '../../../models/document/document_type.dart';
import '../document_pdf_service.dart';

/// Previews the eight business documents, each rendered by the template that
/// reproduces its reference PDF.
///
/// With no [document] the page shows the bundled sample data; hosts that have
/// real data pass it in and switch types with [onTypeChanged].
class DocumentPreviewPage extends StatefulWidget {
  const DocumentPreviewPage({
    super.key,
    this.initialType = DocumentType.salesInvoiceTemplate1,
    this.document,
    this.onTypeChanged,
  });

  final DocumentType initialType;

  /// The document to render. Defaults to the sample for the selected type.
  final DocumentModel? document;

  final ValueChanged<DocumentType>? onTypeChanged;

  @override
  State<DocumentPreviewPage> createState() => _DocumentPreviewPageState();
}

class _DocumentPreviewPageState extends State<DocumentPreviewPage> {
  final _service = DocumentPdfService();
  late DocumentType _type;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  DocumentModel get _document =>
      widget.document ?? DummyDocumentData.document(_type);

  Future<Uint8List> _build() => _service.generate(_document);

  Future<void> _share() async {
    try {
      await Printing.sharePdf(
        bytes: await _build(),
        filename: '${_type.name}_${_document.number}.pdf',
      );
    } on AppException catch (error) {
      _report(error);
    }
  }

  Future<void> _print() async {
    try {
      final bytes = await _build();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } on AppException catch (error) {
      _report(error);
    }
  }

  void _report(AppException error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Documents — ${_type.displayName}')),
      body: Row(
        children: [
          Expanded(
            child: PdfPreview(
              // Keyed on the type so switching regenerates immediately.
              key: ValueKey(_type),
              build: (_) => _build(),
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              allowPrinting: false,
              allowSharing: false,
              onError: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error is AppException ? error.message : '$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 280,
            child: Material(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    Text(
                      'Document',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    RadioGroup<DocumentType>(
                      groupValue: _type,
                      onChanged: (next) {
                        if (next == null) return;
                        setState(() => _type = next);
                        widget.onTypeChanged?.call(next);
                      },
                      child: Column(
                        children: [
                          for (final type in DocumentType.values)
                            RadioListTile<DocumentType>(
                              title: Text(type.displayName),
                              value: type,
                              dense: true,
                            ),
                        ],
                      ),
                    ),
                    const Divider(),
                    FilledButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Download PDF'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _print,
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Print PDF'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
