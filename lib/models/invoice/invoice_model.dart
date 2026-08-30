import 'company_model.dart';
import 'customer_model.dart';
import 'invoice_item_model.dart';
import 'payment_model.dart';

enum TaxRegime { gstIndia, vat, none }

class InvoiceModel {
  const InvoiceModel({
    required this.number,
    required this.date,
    required this.currency,
    required this.company,
    required this.customer,
    required this.items,
    required this.payment,
    this.documentTitle = 'TAX INVOICE',
    this.numberLabel = 'Invoice #',
    this.dueDate,
    this.orderNumber,
    this.salesperson,
    this.warehouse,
    this.branch,
    this.cashier,
    this.placeOfSupply,
    this.reverseCharge = false,
    this.taxRegime = TaxRegime.gstIndia,
    this.interState = false,
    this.taxInclusive = false,
    this.otherCharges = 0,
    this.roundOff = 0,
    this.headerDiscount = 0,
    this.terms,
    this.notes,
    this.customerNotes,
    this.bank,
  });

  /// Printed heading — e.g. TAX INVOICE, QUOTATION, SALES ORDER, DELIVERY CHALLAN.
  final String documentTitle;
  final String numberLabel;
  final String number;
  final DateTime date;
  final DateTime? dueDate;
  final String currency;
  final CompanyModel company;
  final CustomerModel customer;
  final List<InvoiceItemModel> items;
  final PaymentInfo payment;
  final String? orderNumber;
  final String? salesperson;
  final String? warehouse;
  final String? branch;
  final String? cashier;
  final String? placeOfSupply;
  final bool reverseCharge;
  final TaxRegime taxRegime;
  final bool interState;
  final bool taxInclusive;
  final double otherCharges;
  final double roundOff;
  final double headerDiscount;
  final String? terms;
  final String? notes;
  final String? customerNotes;
  final BankDetails? bank;

  InvoiceModel copyWith({
    String? documentTitle,
    String? numberLabel,
    String? number,
    DateTime? date,
    DateTime? dueDate,
    String? currency,
    CompanyModel? company,
    CustomerModel? customer,
    List<InvoiceItemModel>? items,
    PaymentInfo? payment,
    String? orderNumber,
    String? salesperson,
    String? warehouse,
    String? branch,
    String? cashier,
    String? placeOfSupply,
    bool? reverseCharge,
    TaxRegime? taxRegime,
    bool? interState,
    bool? taxInclusive,
    double? otherCharges,
    double? roundOff,
    double? headerDiscount,
    String? terms,
    String? notes,
    String? customerNotes,
    BankDetails? bank,
  }) {
    return InvoiceModel(
      documentTitle: documentTitle ?? this.documentTitle,
      numberLabel: numberLabel ?? this.numberLabel,
      number: number ?? this.number,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      currency: currency ?? this.currency,
      company: company ?? this.company,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      payment: payment ?? this.payment,
      orderNumber: orderNumber ?? this.orderNumber,
      salesperson: salesperson ?? this.salesperson,
      warehouse: warehouse ?? this.warehouse,
      branch: branch ?? this.branch,
      cashier: cashier ?? this.cashier,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      taxRegime: taxRegime ?? this.taxRegime,
      interState: interState ?? this.interState,
      taxInclusive: taxInclusive ?? this.taxInclusive,
      otherCharges: otherCharges ?? this.otherCharges,
      roundOff: roundOff ?? this.roundOff,
      headerDiscount: headerDiscount ?? this.headerDiscount,
      terms: terms ?? this.terms,
      notes: notes ?? this.notes,
      customerNotes: customerNotes ?? this.customerNotes,
      bank: bank ?? this.bank,
    );
  }
}
