import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../features/invoice_templates/invoice_template_type.dart';
import '../features/thermal_templates/thermal_template_type.dart';

class TemplateSelector extends StatelessWidget {
  const TemplateSelector.invoice({
    super.key,
    required this.value,
    required this.onChanged,
  }) : thermalValue = null,
       onThermalChanged = null,
       _mode = _SelectorMode.invoice;

  const TemplateSelector.thermal({
    super.key,
    required ThermalTemplateType value,
    required ValueChanged<ThermalTemplateType> onChanged,
  }) : thermalValue = value,
       onThermalChanged = onChanged,
       value = InvoiceTemplateType.professional,
       onChanged = _noop,
       _mode = _SelectorMode.thermal;

  final InvoiceTemplateType value;
  final ValueChanged<InvoiceTemplateType> onChanged;
  final ThermalTemplateType? thermalValue;
  final ValueChanged<ThermalTemplateType>? onThermalChanged;
  final _SelectorMode _mode;

  static void _noop(InvoiceTemplateType value) {}

  @override
  Widget build(BuildContext context) {
    if (_mode == _SelectorMode.thermal) {
      return DropdownButtonFormField<ThermalTemplateType>(
        key: ValueKey(thermalValue),
        initialValue: thermalValue,
        decoration: const InputDecoration(
          labelText: 'Thermal template',
          border: OutlineInputBorder(),
        ),
        items: [
          for (final type in ThermalTemplateType.values)
            DropdownMenuItem(value: type, child: Text(type.title)),
        ],
        onChanged: (next) {
          if (next != null) onThermalChanged?.call(next);
        },
      );
    }
    return DropdownButtonFormField<InvoiceTemplateType>(
      key: ValueKey(value),
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Invoice template',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final type in InvoiceTemplateType.values)
          DropdownMenuItem(
            value: type,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Text(type.title),
            ),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}

enum _SelectorMode { invoice, thermal }
