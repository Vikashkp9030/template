import '../../../models/invoice/invoice_model.dart';

abstract class ThermalPrinter {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> printReceipt(InvoiceModel invoice);
}

class MockThermalPrinter implements ThermalPrinter {
  MockThermalPrinter({this.onLog});

  final void Function(String message)? onLog;
  bool connected = false;
  List<int> lastBytes = const [];

  @override
  Future<void> connect() async {
    connected = true;
    onLog?.call('Mock printer connected');
  }

  @override
  Future<void> disconnect() async {
    connected = false;
    onLog?.call('Mock printer disconnected');
  }

  @override
  Future<void> printReceipt(InvoiceModel invoice) async {
    if (!connected) {
      await connect();
    }
    onLog?.call('Mock print for ${invoice.number}');
  }

  void storeBytes(List<int> bytes) => lastBytes = bytes;
}
