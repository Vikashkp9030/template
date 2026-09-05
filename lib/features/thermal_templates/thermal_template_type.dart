enum ThermalTemplateType { thermal }

extension ThermalTemplateTypeX on ThermalTemplateType {
  String get title => switch (this) {
    ThermalTemplateType.thermal => 'Thermal Printer',
  };

  String get description => switch (this) {
    ThermalTemplateType.thermal =>
      'Compact POS receipt optimized for 80mm and 58mm thermal printers.',
  };

  static ThermalTemplateType parse(String? raw) {
    return ThermalTemplateType.thermal;
  }
}
