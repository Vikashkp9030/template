import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../widgets/template_card.dart';
import '../thermal_templates/thermal_template_type.dart';
import 'preview_controller.dart';

class ThermalGalleryPage extends ConsumerWidget {
  const ThermalGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Templates'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          for (final type in ThermalTemplateType.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 140,
                child: TemplateCard(
                  title: type.title,
                  subtitle: type.description,
                  icon: Icons.receipt_long,
                  onPreview: () {
                    ref
                        .read(previewProvider.notifier)
                        .selectThermalTemplate(type);
                    context.go('/thermal/preview?template=${type.name}');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
