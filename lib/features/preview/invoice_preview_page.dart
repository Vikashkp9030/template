import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../data/dummy/dummy_invoice_data.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/printer/paper_size.dart';
import '../invoice_templates/invoice_template_type.dart';
import '../invoice_templates/presentation/invoice_preview.dart';
import '../printing/pdf_service.dart';

/// The authoritative on-screen preview is the actual generated PDF
/// ([_PreviewMode.pdf]) — byte-identical to what "Download PDF" produces,
/// so it can never disagree with it, and it's the default view. Switching to
/// [_PreviewMode.liveTemplate] shows the fast Flutter-widget render instead,
/// for template-design QA.
enum _PreviewMode { pdf, liveTemplate }

class InvoicePreviewPage extends StatefulWidget {
  const InvoicePreviewPage({super.key, this.initialTemplate});

  final InvoiceTemplateType? initialTemplate;

  @override
  State<InvoicePreviewPage> createState() => _InvoicePreviewPageState();
}

class _InvoicePreviewPageState extends State<InvoicePreviewPage> {
  _PreviewMode _mode = _PreviewMode.pdf;
  final _pdfService = PdfService();
  late InvoiceModel _invoice;
  late InvoiceTemplateType _template;
  InvoicePaperSize _paperSize = InvoicePaperSize.a4;

  @override
  void initState() {
    super.initState();
    _invoice = DummyInvoiceData.invoice();
    _template = widget.initialTemplate ?? InvoiceTemplateType.standard;
  }

  Future<void> _downloadPdf() async {
    final bytes = Uint8List.fromList(
      await _pdfService.generateInvoice(
        invoice: _invoice,
        template: _template,
        paperSize: _paperSize,
      ),
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice_${_invoice.number}.pdf',
    );
  }

  Future<void> _printPdf() async {
    await Printing.layoutPdf(
      onLayout: (_) async => Uint8List.fromList(
        await _pdfService.generateInvoice(
          invoice: _invoice,
          template: _template,
          paperSize: _paperSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Preview — ${_template.shortLabel}'),
      ),
      body: Row(
        children: [
          Expanded(
            child: switch (_mode) {
              _PreviewMode.pdf => _PdfPreviewPane(
                pdfService: _pdfService,
                invoice: _invoice,
                template: _template,
                paperSize: _paperSize,
              ),
              // `constrained: false` lets the page column take its natural
              // size and be panned, instead of being squeezed into the
              // viewport height.
              _PreviewMode.liveTemplate => InteractiveViewer(
                constrained: false,
                minScale: 0.3,
                maxScale: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: InvoicePreview(
                    invoice: _invoice,
                    template: _template,
                    paperSize: _paperSize,
                  ),
                ),
              ),
            },
          ),
          SizedBox(
            width: 260,
            child: _ControlPanel(
              mode: _mode,
              onModeChanged: (next) => setState(() => _mode = next),
              template: _template,
              onTemplate: (next) => setState(() => _template = next),
              paperSize: _paperSize,
              onPaper: (next) => setState(() => _paperSize = next),
              onPdf: _downloadPdf,
              onPrint: _printPdf,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.mode,
    required this.onModeChanged,
    required this.template,
    required this.onTemplate,
    required this.paperSize,
    required this.onPaper,
    required this.onPdf,
    required this.onPrint,
  });

  final _PreviewMode mode;
  final ValueChanged<_PreviewMode> onModeChanged;
  final InvoiceTemplateType template;
  final ValueChanged<InvoiceTemplateType> onTemplate;
  final InvoicePaperSize paperSize;
  final ValueChanged<InvoicePaperSize> onPaper;
  final VoidCallback onPdf;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Preview', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<_PreviewMode>(
              segments: const [
                ButtonSegment(
                  value: _PreviewMode.pdf,
                  label: Text('PDF Preview'),
                  icon: Icon(Icons.picture_as_pdf_outlined),
                ),
                ButtonSegment(
                  value: _PreviewMode.liveTemplate,
                  label: Text('Live Template'),
                  icon: Icon(Icons.dashboard_customize_outlined),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (next) => onModeChanged(next.first),
            ),
            const SizedBox(height: 16),
            Text('Template', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            RadioGroup<InvoiceTemplateType>(
              groupValue: template,
              onChanged: (next) {
                if (next != null) onTemplate(next);
              },
              child: Column(
                children: [
                  for (final type in InvoiceTemplateType.values)
                    RadioListTile<InvoiceTemplateType>(
                      title: Text(type.shortLabel),
                      subtitle: Text(
                        type.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: type,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Paper Size', style: Theme.of(context).textTheme.titleSmall),
            RadioGroup<InvoicePaperSize>(
              groupValue: paperSize,
              onChanged: (next) {
                if (next != null) onPaper(next);
              },
              child: Column(
                children: [
                  for (final size in InvoicePaperSize.values)
                    RadioListTile<InvoicePaperSize>(
                      title: Text(size.label),
                      value: size,
                    ),
                ],
              ),
            ),
            const Divider(),
            FilledButton.icon(
              onPressed: onPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Download PDF'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onPrint,
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline, live-updating render of the exact PDF `PdfService` produces.
/// Rebuilding with a new `build` closure (which happens on every widget
/// rebuild, since it captures `invoice`/`template`/`paperSize`) makes
/// `PdfPreview` regenerate automatically — see its `didUpdateWidget`.
class _PdfPreviewPane extends StatelessWidget {
  const _PdfPreviewPane({
    required this.pdfService,
    required this.invoice,
    required this.template,
    required this.paperSize,
  });

  final PdfService pdfService;
  final InvoiceModel invoice;
  final InvoiceTemplateType template;
  final InvoicePaperSize paperSize;

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      build: (_) async => Uint8List.fromList(
        await pdfService.generateInvoice(
          invoice: invoice,
          template: template,
          paperSize: paperSize,
        ),
      ),
    );
  }
}
