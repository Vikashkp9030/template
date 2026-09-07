import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/errors/app_exception.dart';
import '../../core/extensions/context_ext.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/printer/paper_size.dart';
import '../../widgets/invoice_preview_container.dart';
import '../../widgets/template_selector.dart';
import '../invoice_templates/invoice_template_type.dart';
import '../invoice_templates/presentation/invoice_preview.dart';
import '../printing/pdf_service.dart';
import '../printing/print_service.dart';
import 'preview_controller.dart';

/// The authoritative on-screen preview is the actual generated PDF
/// ([_PreviewMode.pdf]) — byte-identical to what "Download PDF" produces,
/// so it can never disagree with it. [_PreviewMode.liveTemplate] shows the
/// fast Flutter-widget render (the same one other apps embed via the public
/// `InvoicePreview` API) side by side, for template-design QA.
enum _PreviewMode { pdf, liveTemplate }

class InvoicePreviewPage extends ConsumerStatefulWidget {
  const InvoicePreviewPage({
    super.key,
    this.initialTemplate,
    this.loadErp = false,
  });

  final InvoiceTemplateType? initialTemplate;
  final bool loadErp;

  @override
  ConsumerState<InvoicePreviewPage> createState() => _InvoicePreviewPageState();
}

class _InvoicePreviewPageState extends ConsumerState<InvoicePreviewPage> {
  _PreviewMode _mode = _PreviewMode.pdf;
  final _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(previewProvider.notifier);
      if (widget.loadErp) controller.loadErpInvoice();
      if (widget.initialTemplate != null) {
        controller.selectInvoiceTemplate(widget.initialTemplate!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(previewProvider);
    final controls = _Controls(
      template: state.invoiceTemplate,
      paperSize: state.paperSize,
      mode: _mode,
      onModeChanged: (mode) => setState(() => _mode = mode),
      onTemplate: (type) =>
          ref.read(previewProvider.notifier).selectInvoiceTemplate(type),
      onPaper: (size) => ref.read(previewProvider.notifier).setPaperSize(size),
      onPdf: () => _pdf(preview: false),
      onPreviewPdf: () => _pdf(preview: true),
      onPrint: () => _print(),
      onShare: () => _share(),
    );
    final preview = _mode == _PreviewMode.pdf
        ? _PdfPreviewPane(
            pdfService: _pdfService,
            invoice: state.invoice,
            template: state.invoiceTemplate,
            paperSize: state.paperSize,
          )
        : InvoicePreviewContainer(
            paperSize: state.paperSize,
            child: InvoicePreview(
              invoice: state.invoice,
              template: state.invoiceTemplate,
              paperSize: state.paperSize,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text('Template: ${state.invoiceTemplate.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          if (state.errorMessage != null)
            MaterialBanner(
              content: Text(state.errorMessage!),
              actions: [
                TextButton(
                  onPressed: () =>
                      ref.read(previewProvider.notifier).loadDummyInvoice(),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: context.isWide
                ? Row(
                    children: [
                      SizedBox(width: 320, child: controls),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: preview,
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      controls,
                      const SizedBox(height: 16),
                      SizedBox(height: 720, child: preview),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pdf({required bool preview}) async {
    final state = ref.read(previewProvider);
    try {
      final bytes = await InvoicePrintService().generatePdf(
        invoice: state.invoice,
        template: state.invoiceTemplate,
        paperSize: state.paperSize,
      );
      if (!mounted) return;
      if (preview) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('PDF preview')),
              body: PdfPreview(build: (_) async => Uint8List.fromList(bytes)),
            ),
          ),
        );
      } else {
        await Printing.sharePdf(
          bytes: Uint8List.fromList(bytes),
          filename: '${state.invoice.number}.pdf',
        );
      }
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _print() async {
    final state = ref.read(previewProvider);
    try {
      await InvoicePrintService.printInvoice(
        invoice: state.invoice,
        template: state.invoiceTemplate,
        paperSize: state.paperSize,
      );
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _share() => _pdf(preview: false);
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.template,
    required this.paperSize,
    required this.mode,
    required this.onModeChanged,
    required this.onTemplate,
    required this.onPaper,
    required this.onPdf,
    required this.onPreviewPdf,
    required this.onPrint,
    required this.onShare,
  });

  final InvoiceTemplateType template;
  final InvoicePaperSize paperSize;
  final _PreviewMode mode;
  final ValueChanged<_PreviewMode> onModeChanged;
  final ValueChanged<InvoiceTemplateType> onTemplate;
  final ValueChanged<InvoicePaperSize> onPaper;
  final VoidCallback onPdf;
  final VoidCallback onPreviewPdf;
  final VoidCallback onPrint;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
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
        const SizedBox(height: AppSpacing.md),
        TemplateSelector.invoice(value: template, onChanged: onTemplate),
        const SizedBox(height: AppSpacing.md),
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
        FilledButton.tonalIcon(
          onPressed: onPreviewPdf,
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Preview PDF'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPrint,
          icon: const Icon(Icons.print_outlined),
          label: const Text('Print PDF'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share'),
        ),
      ],
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
      useActions: false,
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
