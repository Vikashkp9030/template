import 'package:yaml/yaml.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/map_reader.dart';
import '../../models/invoice/address_model.dart';
import '../../models/invoice/company_model.dart';
import '../../models/invoice/customer_model.dart';
import '../../models/invoice/invoice_item_model.dart';
import '../../models/invoice/invoice_model.dart';
import '../../models/invoice/payment_model.dart';

class ParsedInvoiceDocument {
  const ParsedInvoiceDocument({
    required this.invoice,
    this.templateKey,
    this.paperSizeKey,
  });

  final InvoiceModel invoice;
  final String? templateKey;
  final String? paperSizeKey;
}

class YamlParser {
  const YamlParser();

  ParsedInvoiceDocument parse(String raw) {
    if (raw.trim().isEmpty) {
      throw const YamlParseException('YAML content is empty.');
    }
    late final dynamic decoded;
    try {
      decoded = loadYaml(raw);
    } catch (error) {
      throw YamlParseException('Invalid YAML.', cause: error);
    }
    if (decoded is! YamlMap && decoded is! Map) {
      throw const YamlParseException('YAML root must be a map.');
    }
    try {
      return _parseMap(Map<dynamic, dynamic>.from(decoded as Map));
    } on FormatException catch (error) {
      throw YamlParseException(error.message, cause: error);
    }
  }

  ParsedInvoiceDocument _parseMap(Map<dynamic, dynamic> root) {
    final reader = MapReader(root);
    final company = _company(reader.requireMap('company'));
    final customer = _customer(reader.requireMap('customer'));
    final invoiceNode = reader.requireMap('invoice');
    final invoiceReader = MapReader(invoiceNode);
    final items = reader.optionalList('items');
    if (items.isEmpty) {
      throw const InvoiceValidationException('Product list cannot be empty.');
    }

    DateTime date;
    DateTime? due;
    try {
      date = DateFormatter.parse(invoiceReader.requireString('date'));
      final dueRaw = invoiceReader.optionalString('dueDate');
      due = dueRaw == null ? null : DateFormatter.parse(dueRaw);
    } on FormatException catch (error) {
      throw InvoiceValidationException(error.message, cause: error);
    }

    return ParsedInvoiceDocument(
      templateKey: reader.optionalString('template'),
      paperSizeKey: reader.optionalString('paperSize'),
        invoice: InvoiceModel(
        documentTitle:
            invoiceReader.optionalString('documentTitle') ?? 'TAX INVOICE',
        numberLabel: invoiceReader.optionalString('numberLabel') ?? 'Invoice #',
        number: invoiceReader.requireString('number'),
        date: date,
        dueDate: due,
        currency: invoiceReader.optionalString('currency') ?? 'INR',
        company: company,
        customer: customer,
        items: [for (final item in items) _item(item)],
        payment: _payment(reader.optionalMap('payment')),
        orderNumber: invoiceReader.optionalString('orderNumber'),
        salesperson: invoiceReader.optionalString('salesperson'),
        warehouse: invoiceReader.optionalString('warehouse'),
        branch: invoiceReader.optionalString('branch'),
        cashier: invoiceReader.optionalString('cashier'),
        placeOfSupply: invoiceReader.optionalString('placeOfSupply'),
        reverseCharge: invoiceReader.optionalBool('reverseCharge'),
        taxInclusive: invoiceReader.optionalBool('taxInclusive'),
        otherCharges:
            invoiceReader.optionalNum('otherCharges')?.toDouble() ?? 0,
        roundOff: invoiceReader.optionalNum('roundOff')?.toDouble() ?? 0,
        headerDiscount:
            invoiceReader.optionalNum('headerDiscount')?.toDouble() ?? 0,
        taxRegime: _regime(reader.optionalString('taxRegime')),
        interState: reader.optionalBool('interState'),
        terms: invoiceReader.optionalString('terms'),
        notes: invoiceReader.optionalString('notes'),
        customerNotes: invoiceReader.optionalString('customerNotes'),
        bank: _bank(reader.optionalMap('bank')),
      ),
    );
  }

  CompanyModel _company(Map<dynamic, dynamic> map) {
    final reader = MapReader(map);
    return CompanyModel(
      name: reader.requireString('name'),
      phone: reader.requireString('phone'),
      email: reader.requireString('email'),
      gstin: reader.optionalString('gstin'),
      vatNumber: reader.optionalString('vatNumber'),
      website: reader.optionalString('website'),
      logoLabel: reader.optionalString('logoLabel'),
      address: _address(reader.requireMap('address')),
    );
  }

  CustomerModel _customer(Map<dynamic, dynamic> map) {
    final reader = MapReader(map);
    return CustomerModel(
      name: reader.requireString('name'),
      phone: reader.optionalString('phone'),
      email: reader.optionalString('email'),
      gstin: reader.optionalString('gstin'),
      billingAddress: _optionalAddress(reader.optionalMap('billingAddress')),
      shippingAddress: _optionalAddress(reader.optionalMap('shippingAddress')),
    );
  }

  AddressModel? _optionalAddress(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    return _address(map);
  }

  AddressModel _address(Map<dynamic, dynamic> map) {
    final reader = MapReader(map);
    return AddressModel(
      line1: reader.requireString('line1'),
      line2: reader.optionalString('line2'),
      city: reader.optionalString('city') ?? '',
      state: reader.optionalString('state') ?? '',
      country: reader.optionalString('country') ?? 'India',
      pincode: reader.optionalString('pincode') ?? '',
    );
  }

  InvoiceItemModel _item(dynamic raw) {
    if (raw is! Map) {
      throw const FormatException('Each item must be a map.');
    }
    final reader = MapReader(Map<dynamic, dynamic>.from(raw));
    return InvoiceItemModel(
      sku: reader.requireString('sku'),
      name: reader.requireString('name'),
      hsnSac: reader.optionalString('hsnSac'),
      quantity: reader.requireNum('quantity').toDouble(),
      unit: reader.optionalString('unit') ?? 'NOS',
      unitPrice: reader.requireNum('unitPrice').toDouble(),
      discount: reader.optionalNum('discount')?.toDouble() ?? 0,
      discountType: reader.optionalString('discountType') ?? 'AMOUNT',
      taxRate: reader.optionalNum('taxRate')?.toDouble() ?? 0,
      freeQuantity: reader.optionalNum('freeQuantity')?.toDouble() ?? 0,
      description: reader.optionalString('description'),
    );
  }

  PaymentInfo _payment(Map<dynamic, dynamic>? map) {
    if (map == null) return const PaymentInfo(method: 'UNPAID');
    final reader = MapReader(map);
    return PaymentInfo(
      method: reader.optionalString('method') ?? 'UNPAID',
      status: reader.optionalString('status') ?? 'unpaid',
      paidAmount: reader.optionalNum('paidAmount')?.toDouble() ?? 0,
      changeAmount: reader.optionalNum('changeAmount')?.toDouble() ?? 0,
    );
  }

  BankDetails? _bank(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    final reader = MapReader(map);
    return BankDetails(
      bankName: reader.requireString('bankName'),
      accountName: reader.requireString('accountName'),
      accountNumber: reader.requireString('accountNumber'),
      ifsc: reader.requireString('ifsc'),
      upi: reader.optionalString('upi'),
    );
  }

  TaxRegime _regime(String? raw) {
    return switch (raw?.toLowerCase()) {
      null || 'gst_india' || 'gst' => TaxRegime.gstIndia,
      'vat' => TaxRegime.vat,
      'none' || 'no_tax' => TaxRegime.none,
      _ => throw FormatException('Unsupported taxRegime: $raw'),
    };
  }
}
