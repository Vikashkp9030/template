import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../models/printer/printer_config.dart';
import '../../preview/preview_controller.dart';

class PrinterSettingsPage extends ConsumerWidget {
  const PrinterSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(previewProvider.select((s) => s.printerConfig));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer configuration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Printer Type', style: Theme.of(context).textTheme.titleMedium),
          RadioGroup<PrinterType>(
            groupValue: config.type,
            onChanged: (next) => ref
                .read(previewProvider.notifier)
                .updatePrinter(config.copyWith(type: next)),
            child: Column(
              children: [
                for (final type in PrinterType.values)
                  RadioListTile<PrinterType>(
                    title: Text(type.name),
                    value: type,
                  ),
              ],
            ),
          ),
          const Divider(),
          Text('Paper Size', style: Theme.of(context).textTheme.titleMedium),
          RadioGroup<String>(
            groupValue: config.paperSizeLabel,
            onChanged: (next) => ref
                .read(previewProvider.notifier)
                .updatePrinter(config.copyWith(paperSizeLabel: next)),
            child: Column(
              children: [
                for (final size in const ['58mm', '80mm'])
                  RadioListTile<String>(title: Text(size), value: size),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Character Set'),
            subtitle: Text(config.characterSet),
          ),
          Text('Density', style: Theme.of(context).textTheme.titleMedium),
          RadioGroup<PrintDensity>(
            groupValue: config.density,
            onChanged: (next) => ref
                .read(previewProvider.notifier)
                .updatePrinter(config.copyWith(density: next)),
            child: Column(
              children: [
                for (final density in PrintDensity.values)
                  RadioListTile<PrintDensity>(
                    title: Text(density.name),
                    value: density,
                  ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Auto Cut'),
            value: config.autoCut,
            onChanged: (value) => ref
                .read(previewProvider.notifier)
                .updatePrinter(config.copyWith(autoCut: value)),
          ),
          SwitchListTile(
            title: const Text('Open Cash Drawer'),
            value: config.openCashDrawer,
            onChanged: (value) => ref
                .read(previewProvider.notifier)
                .updatePrinter(config.copyWith(openCashDrawer: value)),
          ),
          const SizedBox(height: 12),
          Text(
            config.type == PrinterType.mock
                ? 'Mock printer is active. Print actions simulate ESC/POS without hardware.'
                : 'A ${config.type.name} adapter can be plugged into ThermalPrinter later.',
          ),
        ],
      ),
    );
  }
}
