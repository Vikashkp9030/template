enum PrinterType { bluetooth, network, usb, mock }

enum PrintDensity { normal, high }

class PrinterConfig {
  const PrinterConfig({
    this.type = PrinterType.mock,
    this.paperSizeLabel = '80mm',
    this.characterSet = 'UTF-8',
    this.density = PrintDensity.normal,
    this.autoCut = true,
    this.openCashDrawer = false,
    this.host,
    this.port = 9100,
  });

  final PrinterType type;
  final String paperSizeLabel;
  final String characterSet;
  final PrintDensity density;
  final bool autoCut;
  final bool openCashDrawer;
  final String? host;
  final int port;

  PrinterConfig copyWith({
    PrinterType? type,
    String? paperSizeLabel,
    String? characterSet,
    PrintDensity? density,
    bool? autoCut,
    bool? openCashDrawer,
    String? host,
    int? port,
  }) {
    return PrinterConfig(
      type: type ?? this.type,
      paperSizeLabel: paperSizeLabel ?? this.paperSizeLabel,
      characterSet: characterSet ?? this.characterSet,
      density: density ?? this.density,
      autoCut: autoCut ?? this.autoCut,
      openCashDrawer: openCashDrawer ?? this.openCashDrawer,
      host: host ?? this.host,
      port: port ?? this.port,
    );
  }
}
