import 'package:flutter/material.dart';

import '../core/constants/app_radius.dart';
import '../core/constants/app_spacing.dart';

class TemplateCard extends StatelessWidget {
  const TemplateCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPreview,
    this.selected = false,
    this.icon = Icons.description_outlined,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPreview;
  final bool selected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      elevation: selected ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onPreview,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onPreview,
                  child: const Text('Preview'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
