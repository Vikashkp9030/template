import 'templates/thermal_template_01.dart';
import 'templates/thermal_template_02.dart';
import 'thermal_template.dart';
import 'thermal_template_type.dart';

class ThermalTemplateRegistry {
  ThermalTemplateRegistry._();

  static final Map<ThermalTemplateType, ThermalTemplate> templates = {
    ThermalTemplateType.classic: ClassicThermalTemplate(),
    ThermalTemplateType.modern: ModernThermalTemplate(),
  };

  static ThermalTemplate get(ThermalTemplateType type) {
    final template = templates[type];
    if (template == null) {
      throw StateError('No thermal template registered for $type');
    }
    return template;
  }
}
