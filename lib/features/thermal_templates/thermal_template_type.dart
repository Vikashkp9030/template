enum ThermalTemplateType { classic, modern }

extension ThermalTemplateTypeX on ThermalTemplateType {
  String get title => switch (this) {
    ThermalTemplateType.classic => 'POS Classic',
    ThermalTemplateType.modern => 'POS Modern',
  };

  String get description => switch (this) {
    ThermalTemplateType.classic =>
      'Centered store header, dashed dividers, cash tender.',
    ThermalTemplateType.modern =>
      'Customer/order header, QR placeholder, boxed total.',
  };

  static ThermalTemplateType parse(String? raw) {
    return switch (raw?.toLowerCase()) {
      null || 'classic' || 'pos_classic' || '01' => ThermalTemplateType.classic,
      'modern' || 'pos_modern' || '02' => ThermalTemplateType.modern,
      _ => throw FormatException('Unknown thermal template: $raw'),
    };
  }
}
