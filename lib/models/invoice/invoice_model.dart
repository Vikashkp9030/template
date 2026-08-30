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
    this.dueDate,
    this.orderNumber,
    this.salesperson,
    this.warehouse,
    this.cashier,
    this.placeOfSupply,
    this.reverseCharge = false,
    this.taxRegime = TaxRegime.gstIndia,
    this.interState = false,
    this.terms,
    this.notes,
    this.bank,
  });

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
  final String? cashier;
  final String? placeOfSupply;
  final bool reverseCharge;
  final TaxRegime taxRegime;
  final bool interState;
  final String? terms;
  final String? notes;
  final BankDetails? bank;

  InvoiceModel copyWith({
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
    String? cashier,
    String? placeOfSupply,
    bool? reverseCharge,
    TaxRegime? taxRegime,
    bool? interState,
    String? terms,
    String? notes,
    BankDetails? bank,
  }) {
    return InvoiceModel(
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
      cashier: cashier ?? this.cashier,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      taxRegime: taxRegime ?? this.taxRegime,
      interState: interState ?? this.interState,
      terms: terms ?? this.terms,
      notes: notes ?? this.notes,
      bank: bank ?? this.bank,
    );
  }
}
