import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../features/invoice_templates/invoice_template_type.dart';
import '../../../features/preview/preview_controller.dart';
import '../../../features/thermal_templates/thermal_template_type.dart';
import '../../../widgets/template_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Printer settings',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.print_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Invoice & Thermal Template Studio',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Preview invoice and POS designs with dummy or YAML data before integrating them into your ERP.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          _sectionHeader(
            context,
            'Invoice Templates',
            '${AppConstants.invoiceTemplateCount} Available',
          ),
          const SizedBox(height: AppSpacing.sm),
          _grid(context, [
            for (final type in InvoiceTemplateType.values)
              TemplateCard(
                title: type.shortLabel,
                subtitle: type.title,
                onPreview: () {
                  ref
                      .read(previewProvider.notifier)
                      .selectInvoiceTemplate(type);
                  context.go('/invoices/preview?template=${type.name}');
                },
              ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          _sectionHeader(
            context,
            'Thermal Templates',
            '${AppConstants.thermalTemplateCount} Available',
          ),
          const SizedBox(height: AppSpacing.sm),
          _grid(context, [
            for (final type in ThermalTemplateType.values)
              TemplateCard(
                title: type.title,
                subtitle: type.description,
                icon: Icons.receipt_long_outlined,
                onPreview: () {
                  ref
                      .read(previewProvider.notifier)
                      .selectThermalTemplate(type);
                  context.go('/thermal/preview?template=${type.name}');
                },
              ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          _sectionHeader(context, 'Demo Data', 'Load sample documents'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () {
                  ref.read(previewProvider.notifier).loadDummyInvoice();
                  context.go('/invoices/preview');
                },
                icon: const Icon(Icons.description_outlined),
                label: const Text('Load Dummy Invoice'),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  ref.read(previewProvider.notifier).loadPosOrder();
                  context.go('/thermal/preview');
                },
                icon: const Icon(Icons.point_of_sale_outlined),
                label: const Text('Load POS Order'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(previewProvider.notifier).loadErpInvoice();
                  context.go('/erp');
                },
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('ERP Invoice Preview'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/pos'),
                icon: const Icon(Icons.receipt_outlined),
                label: const Text('POS Bill Preview'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/data'),
                icon: const Icon(Icons.data_object_outlined),
                label: const Text('Dummy Data / YAML Import'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Paper Size / Printer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String count) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 12),
        Chip(label: Text(count)),
      ],
    );
  }

  Widget _grid(BuildContext context, List<Widget> children) {
    final width = MediaQuery.sizeOf(context).width;
    final cross = context.isWide ? 3 : (width > 600 ? 2 : 1);
    return GridView.count(
      crossAxisCount: cross,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: children,
    );
  }
}
