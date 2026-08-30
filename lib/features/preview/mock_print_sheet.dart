import 'package:flutter/material.dart';

import '../printing/thermal_print_service.dart';

class MockPrintSheet extends StatelessWidget {
  const MockPrintSheet({super.key, required this.result});

  final ThermalPrintResult result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Printing...', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final step in result.steps)
            ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(
                step.startsWith('Template') ? 'Template rendered' : step,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Print completed successfully.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
