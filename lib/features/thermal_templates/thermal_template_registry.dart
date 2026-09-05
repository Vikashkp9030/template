import 'templates/thermal_template.dart';
import 'thermal_template.dart';
import 'thermal_template_type.dart';

class ThermalTemplateRegistry {
  ThermalTemplateRegistry._();

  static final Map<ThermalTemplateType, ThermalTemplate> templates = {
    ThermalTemplateType.thermal: ThermalPrinterTemplate(),
  };

  static ThermalTemplate get(ThermalTemplateType type) {
    return templates[ThermalTemplateType.thermal]!;
  }
}
