enum InvoicePaperSize { a4, a5, letter }

extension InvoicePaperSizeX on InvoicePaperSize {
  String get label => switch (this) {
    InvoicePaperSize.a4 => 'A4',
    InvoicePaperSize.a5 => 'A5',
    InvoicePaperSize.letter => 'Letter',
  };

  /// Logical pixel size at ~96 DPI.
  double get width => switch (this) {
    InvoicePaperSize.a4 => 794,
    InvoicePaperSize.a5 => 559,
    InvoicePaperSize.letter => 816,
  };

  double get height => switch (this) {
    InvoicePaperSize.a4 => 1123,
    InvoicePaperSize.a5 => 794,
    InvoicePaperSize.letter => 1056,
  };

  static InvoicePaperSize parse(String? raw) {
    return switch (raw?.toLowerCase()) {
      null || 'a4' => InvoicePaperSize.a4,
      'a5' => InvoicePaperSize.a5,
      'letter' => InvoicePaperSize.letter,
      _ => throw FormatException('Unsupported paper size: $raw'),
    };
  }
}
