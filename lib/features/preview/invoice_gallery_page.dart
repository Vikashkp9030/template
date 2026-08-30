import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../invoice_templates/invoice_template_type.dart';
import '../../widgets/template_card.dart';
import 'preview_controller.dart';

class InvoiceGalleryPage extends ConsumerWidget {
  const InvoiceGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Templates'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(AppSpacing.lg),
        crossAxisCount: MediaQuery.sizeOf(context).width > 900 ? 3 : 1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          for (final type in InvoiceTemplateType.values)
            TemplateCard(
              title: type.title,
              subtitle: type.description,
              onPreview: () {
                ref.read(previewProvider.notifier).selectInvoiceTemplate(type);
                context.go('/invoices/preview?template=${type.name}');
              },
            ),
        ],
      ),
    );
  }
}
