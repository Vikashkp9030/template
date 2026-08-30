import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/errors/app_exception.dart';
import '../../core/extensions/context_ext.dart';
import '../../models/printer/thermal_paper_size.dart';
import '../../widgets/template_selector.dart';
import '../../widgets/thermal_preview_container.dart';
import '../printing/thermal_print_service.dart';
import '../thermal_templates/presentation/thermal_preview.dart';
import '../thermal_templates/thermal_template_type.dart';
import 'mock_print_sheet.dart';
import 'preview_controller.dart';

class ThermalPreviewPage extends ConsumerStatefulWidget {
  const ThermalPreviewPage({
    super.key,
    this.initialTemplate,
    this.loadPos = false,
  });

  final ThermalTemplateType? initialTemplate;
  final bool loadPos;

  @override
  ConsumerState<ThermalPreviewPage> createState() => _ThermalPreviewPageState();
}

class _ThermalPreviewPageState extends ConsumerState<ThermalPreviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(previewProvider.notifier);
      if (widget.loadPos) controller.loadPosOrder();
      if (widget.initialTemplate != null) {
        controller.selectThermalTemplate(widget.initialTemplate!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(previewProvider);
    final preview = ThermalPreviewContainer(
      paperSize: state.thermalPaperSize,
      child: ThermalPreview(
        invoice: state.invoice,
        template: state.thermalTemplate,
        paperSize: state.thermalPaperSize,
      ),
    );
    final controls = ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        TemplateSelector.thermal(
          value: state.thermalTemplate,
          onChanged: (type) =>
              ref.read(previewProvider.notifier).selectThermalTemplate(type),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Paper', style: Theme.of(context).textTheme.titleSmall),
        RadioGroup<ThermalPaperSize>(
          groupValue: state.thermalPaperSize,
          onChanged: (next) {
            if (next != null) {
              ref.read(previewProvider.notifier).setThermalPaperSize(next);
            }
          },
          child: Column(
            children: [
              for (final size in ThermalPaperSize.values)
                RadioListTile<ThermalPaperSize>(
                  title: Text(size.label),
                  value: size,
                ),
            ],
          ),
        ),
        const Divider(),
        FilledButton.icon(
          onPressed: _print,
          icon: const Icon(Icons.print_outlined),
          label: const Text('Print'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _escPos,
          icon: const Icon(Icons.terminal_outlined),
          label: const Text('Generate ESC/POS'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Thermal Template: ${state.thermalTemplate.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: context.isWide
          ? Row(
              children: [
                SizedBox(width: 320, child: controls),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: preview,
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                SizedBox(height: 420, child: controls),
                preview,
              ],
            ),
    );
  }

  Future<void> _print() async {
    final state = ref.read(previewProvider);
    try {
      final result = await ThermalPrintService.printReceipt(
        invoice: state.invoice,
        template: state.thermalTemplate,
        paperSize: state.thermalPaperSize,
        config: state.printerConfig,
      );
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        builder: (_) => MockPrintSheet(result: result),
      );
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _escPos() async {
    final state = ref.read(previewProvider);
    final result = ThermalPrintService().generate(
      invoice: state.invoice,
      template: state.thermalTemplate,
      paperSize: state.thermalPaperSize,
      config: state.printerConfig,
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ESC/POS generated'),
        content: Text(
          '${result.bytes.length} bytes · ${result.commands.length} commands',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
