import 'dart:typed_data';

import '../invoice/invoice_model.dart';
import 'document_type.dart';

/// A business document to be printed.
///
/// The parts every document shares — company, customer, line items, dates,
/// tax regime, notes, terms — stay in [invoice], so there is exactly one
/// source of truth for them and [InvoiceCalculator] keeps working unchanged.
/// Only the fields that a specific reference layout prints and an invoice has
/// no concept of (an RMA number, a challan type, credits used…) live here.
class DocumentModel {
  const DocumentModel({
    required this.type,
    required this.invoice,
    this.referenceNumber,
    this.linkedInvoiceNumber,
    this.linkedInvoiceDate,
    this.salesOrderNumber,
    this.packageNumber,
    this.packageDate,
    this.orderDate,
    this.expectedShipmentDate,
    this.returnNumber,
    this.challanType,
    this.deliveryMethod,
    this.paymentTerms,
    this.subject,
    this.description,
    this.creditsUsed = 0,
    this.paymentRetention = 0,
    this.paymentMade = 0,
    this.returnReason,
    this.returnReasonLabel = 'Reason',
    this.showPaymentOptions = false,
    this.paymentOptionsLogo,
    this.showAmountInWords = true,
    this.showSignature = true,
  });

  final DocumentType type;
  final InvoiceModel invoice;

  /// `Ref#` on credit notes, challans and sales orders; `P.O.#` on invoices.
  final String? referenceNumber;

  /// Credit notes point back at the invoice they credit.
  final String? linkedInvoiceNumber;
  final DateTime? linkedInvoiceDate;

  final String? salesOrderNumber;
  final String? packageNumber;
  final DateTime? packageDate;
  final DateTime? orderDate;
  final DateTime? expectedShipmentDate;
  final String? returnNumber;

  /// Delivery challan only, e.g. `Supply on Approval`.
  final String? challanType;

  /// Sales order only, e.g. `UPS`.
  final String? deliveryMethod;

  /// Free text payment terms, e.g. `Due on Receipt`.
  final String? paymentTerms;

  final String? subject;
  final String? description;

  /// Credit note: amount of the credit already consumed.
  final double creditsUsed;

  /// Invoice: amount withheld and amount already paid.
  final double paymentRetention;
  final double paymentMade;

  final String? returnReason;
  final String returnReasonLabel;

  final bool showPaymentOptions;

  /// Badge printed beside "Payment Options" — in the reference invoices a
  /// payment provider's mark. It is a third-party asset, so the host app
  /// supplies the bytes rather than this package bundling them.
  final Uint8List? paymentOptionsLogo;
  final bool showAmountInWords;
  final bool showSignature;

  /// Number printed next to the document title.
  String get number => switch (type) {
    DocumentType.packagingSlip => packageNumber ?? invoice.number,
    DocumentType.salesReturn => returnNumber ?? invoice.number,
    DocumentType.salesOrder => salesOrderNumber ?? invoice.number,
    _ => invoice.number,
  };

  String get title => invoice.documentTitle.isEmpty
      ? type.title
      : invoice.documentTitle;

  DocumentModel copyWith({
    DocumentType? type,
    InvoiceModel? invoice,
    String? referenceNumber,
    String? linkedInvoiceNumber,
    DateTime? linkedInvoiceDate,
    String? salesOrderNumber,
    String? packageNumber,
    DateTime? packageDate,
    DateTime? orderDate,
    DateTime? expectedShipmentDate,
    String? returnNumber,
    String? challanType,
    String? deliveryMethod,
    String? paymentTerms,
    String? subject,
    String? description,
    double? creditsUsed,
    double? paymentRetention,
    double? paymentMade,
    String? returnReason,
    String? returnReasonLabel,
    bool? showPaymentOptions,
    Uint8List? paymentOptionsLogo,
    bool? showAmountInWords,
    bool? showSignature,
  }) {
    return DocumentModel(
      type: type ?? this.type,
      invoice: invoice ?? this.invoice,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      linkedInvoiceNumber: linkedInvoiceNumber ?? this.linkedInvoiceNumber,
      linkedInvoiceDate: linkedInvoiceDate ?? this.linkedInvoiceDate,
      salesOrderNumber: salesOrderNumber ?? this.salesOrderNumber,
      packageNumber: packageNumber ?? this.packageNumber,
      packageDate: packageDate ?? this.packageDate,
      orderDate: orderDate ?? this.orderDate,
      expectedShipmentDate: expectedShipmentDate ?? this.expectedShipmentDate,
      returnNumber: returnNumber ?? this.returnNumber,
      challanType: challanType ?? this.challanType,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      paymentRetention: paymentRetention ?? this.paymentRetention,
      paymentMade: paymentMade ?? this.paymentMade,
      returnReason: returnReason ?? this.returnReason,
      returnReasonLabel: returnReasonLabel ?? this.returnReasonLabel,
      showPaymentOptions: showPaymentOptions ?? this.showPaymentOptions,
      paymentOptionsLogo: paymentOptionsLogo ?? this.paymentOptionsLogo,
      showAmountInWords: showAmountInWords ?? this.showAmountInWords,
      showSignature: showSignature ?? this.showSignature,
    );
  }
}
