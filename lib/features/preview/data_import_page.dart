import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/errors/app_exception.dart';
import '../../core/helpers/invoice_calculator.dart';
import '../../core/utils/money_formatter.dart';
import 'preview_controller.dart';

class DataImportPage extends ConsumerStatefulWidget {
  const DataImportPage({super.key});

  @override
  ConsumerState<DataImportPage> createState() => _DataImportPageState();
}

class _DataImportPageState extends ConsumerState<DataImportPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(previewProvider);
    final totals = InvoiceCalculator().calculate(state.invoice);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Dummy Data', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () =>
                    ref.read(previewProvider.notifier).loadDummyInvoice(),
                child: const Text('Load dummy invoice'),
              ),
              FilledButton.tonal(
                onPressed: () =>
                    ref.read(previewProvider.notifier).loadPosOrder(),
                child: const Text('Load POS order'),
              ),
              OutlinedButton(
                onPressed: () =>
                    ref.read(previewProvider.notifier).loadErpInvoice(),
                child: const Text('Load ERP invoice'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('YAML Import', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => ref
                    .read(previewProvider.notifier)
                    .loadAssetYaml(AppConstants.sampleInvoiceAsset),
                child: const Text('Load sample_invoice.yaml'),
              ),
              OutlinedButton(
                onPressed: () => ref
                    .read(previewProvider.notifier)
                    .loadAssetYaml(AppConstants.samplePosAsset),
                child: const Text('Load sample_pos.yaml'),
              ),
              OutlinedButton(
                onPressed: () => ref
                    .read(previewProvider.notifier)
                    .loadAssetYaml(AppConstants.sampleErpAsset),
                child: const Text('Load sample_erp.yaml'),
              ),
              OutlinedButton(
                onPressed: _pickFile,
                child: const Text('Import YAML file'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 12,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste YAML invoice document here',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                try {
                  ref
                      .read(previewProvider.notifier)
                      .applyYaml(_controller.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('YAML imported')),
                  );
                } on AppException catch (error) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error.message)));
                }
              },
              child: const Text('Parse YAML'),
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Active document: ${state.sourceLabel}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text('${state.invoice.number} · ${state.invoice.customer.name}'),
          Text('Items: ${state.invoice.items.length}'),
          Text(
            'Grand total: ${MoneyFormatter.format(totals.grandTotal, currency: state.invoice.currency)}',
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['yaml', 'yml'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;
    _controller.text = String.fromCharCodes(bytes);
  }
}
