import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../data/dummy/dummy_erp_data.dart';
import '../../data/dummy/dummy_invoice_data.dart';
import '../../data/dummy/dummy_pos_data.dart';
import '../../data/yaml/yaml_loader.dart';
import '../../data/yaml/yaml_parser.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/printer/paper_size.dart';
import '../../models/printer/printer_config.dart';
import '../../models/printer/thermal_paper_size.dart';
import '../invoice_templates/invoice_template_type.dart';
import '../thermal_templates/thermal_template_type.dart';

class PreviewState {
  const PreviewState({
    required this.invoice,
    required this.invoiceTemplate,
    required this.thermalTemplate,
    required this.paperSize,
    required this.thermalPaperSize,
    required this.printerConfig,
    this.errorMessage,
    this.sourceLabel = 'Dummy invoice',
  });

  final InvoiceModel invoice;
  final InvoiceTemplateType invoiceTemplate;
  final ThermalTemplateType thermalTemplate;
  final InvoicePaperSize paperSize;
  final ThermalPaperSize thermalPaperSize;
  final PrinterConfig printerConfig;
  final String? errorMessage;
  final String sourceLabel;

  PreviewState copyWith({
    InvoiceModel? invoice,
    InvoiceTemplateType? invoiceTemplate,
    ThermalTemplateType? thermalTemplate,
    InvoicePaperSize? paperSize,
    ThermalPaperSize? thermalPaperSize,
    PrinterConfig? printerConfig,
    String? errorMessage,
    bool clearError = false,
    String? sourceLabel,
  }) {
    return PreviewState(
      invoice: invoice ?? this.invoice,
      invoiceTemplate: invoiceTemplate ?? this.invoiceTemplate,
      thermalTemplate: thermalTemplate ?? this.thermalTemplate,
      paperSize: paperSize ?? this.paperSize,
      thermalPaperSize: thermalPaperSize ?? this.thermalPaperSize,
      printerConfig: printerConfig ?? this.printerConfig,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sourceLabel: sourceLabel ?? this.sourceLabel,
    );
  }
}

class PreviewController extends Notifier<PreviewState> {
  @override
  PreviewState build() {
    return PreviewState(
      invoice: DummyInvoiceData.invoice(),
      invoiceTemplate: InvoiceTemplateType.basic,
      thermalTemplate: ThermalTemplateType.thermal,
      paperSize: InvoicePaperSize.a4,
      thermalPaperSize: ThermalPaperSize.mm80,
      printerConfig: const PrinterConfig(),
    );
  }

  void selectInvoiceTemplate(InvoiceTemplateType type) {
    state = state.copyWith(invoiceTemplate: type, clearError: true);
  }

  void selectThermalTemplate(ThermalTemplateType type) {
    state = state.copyWith(thermalTemplate: type, clearError: true);
  }

  void setPaperSize(InvoicePaperSize size) {
    state = state.copyWith(paperSize: size);
  }

  void setThermalPaperSize(ThermalPaperSize size) {
    state = state.copyWith(thermalPaperSize: size);
  }

  void updatePrinter(PrinterConfig config) {
    state = state.copyWith(printerConfig: config);
  }

  void loadDummyInvoice() {
    state = state.copyWith(
      invoice: DummyInvoiceData.invoice(),
      sourceLabel: 'Dummy invoice',
      clearError: true,
    );
  }

  void loadPosOrder() {
    state = state.copyWith(
      invoice: DummyPosData.order(),
      sourceLabel: 'Dummy POS order',
      clearError: true,
    );
  }

  void loadErpInvoice() {
    state = state.copyWith(
      invoice: DummyErpData.invoice(),
      invoiceTemplate: InvoiceTemplateType.standard,
      sourceLabel: 'Dummy ERP invoice',
      clearError: true,
    );
  }

  Future<void> loadAssetYaml(String asset) async {
    try {
      final raw = await const YamlLoader().fromAsset(asset);
      applyYaml(raw, sourceLabel: asset);
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } catch (error) {
      state = state.copyWith(errorMessage: 'Unable to load YAML: $error');
    }
  }

  void applyYaml(String raw, {String sourceLabel = 'YAML import'}) {
    try {
      final parsed = const YamlParser().parse(raw);
      var template = state.invoiceTemplate;
      var paper = state.paperSize;
      var thermalPaper = state.thermalPaperSize;
      try {
        if (parsed.templateKey != null) {
          template = InvoiceTemplateTypeX.parse(parsed.templateKey);
        }
      } catch (_) {}
      try {
        if (parsed.paperSizeKey != null) {
          final key = parsed.paperSizeKey!.toLowerCase();
          if (key.contains('58') || key.contains('80')) {
            thermalPaper = ThermalPaperSizeX.parse(parsed.paperSizeKey);
          } else {
            paper = InvoicePaperSizeX.parse(parsed.paperSizeKey);
          }
        }
      } catch (error) {
        throw UnsupportedPaperSizeException('$error');
      }
      state = state.copyWith(
        invoice: parsed.invoice,
        invoiceTemplate: template,
        paperSize: paper,
        thermalPaperSize: thermalPaper,
        sourceLabel: sourceLabel,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      rethrow;
    }
  }

  Future<void> loadSampleInvoiceAsset() =>
      loadAssetYaml(AppConstants.sampleInvoiceAsset);
}

final previewProvider = NotifierProvider<PreviewController, PreviewState>(
  PreviewController.new,
);
