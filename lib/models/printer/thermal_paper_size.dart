enum ThermalPaperSize { mm58, mm80 }

extension ThermalPaperSizeX on ThermalPaperSize {
  String get label => switch (this) {
    ThermalPaperSize.mm58 => '58mm',
    ThermalPaperSize.mm80 => '80mm',
  };

  int get millimeters => switch (this) {
    ThermalPaperSize.mm58 => 58,
    ThermalPaperSize.mm80 => 80,
  };

  /// Typical preview width in logical pixels.
  double get previewWidth => switch (this) {
    ThermalPaperSize.mm58 => 280,
    ThermalPaperSize.mm80 => 384,
  };

  int get charactersPerLine => switch (this) {
    ThermalPaperSize.mm58 => 32,
    ThermalPaperSize.mm80 => 48,
  };

  static ThermalPaperSize parse(String? raw) {
    return switch (raw?.toLowerCase()) {
      null || 'mm80' || '80mm' || '80' => ThermalPaperSize.mm80,
      'mm58' || '58mm' || '58' => ThermalPaperSize.mm58,
      _ => throw FormatException('Unsupported thermal paper size: $raw'),
    };
  }
}
