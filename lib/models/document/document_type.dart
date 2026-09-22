/// The eight business documents this package renders to PDF.
///
/// Each value maps to exactly one reference layout under `context/`; the two
/// "template 1 / template 2" pairs are genuinely different Zoho layouts for
/// the same business document, not styling variants of one template.
enum DocumentType {
  creditNoteTemplate1,
  creditNoteTemplate2,
  deliveryChallan,
  packagingSlip,
  salesInvoiceTemplate1,
  salesInvoiceTemplate2,
  salesReturn,
  salesOrder,
}

extension DocumentTypeX on DocumentType {
  String get id => name;

  /// Heading printed at the top-right of the document.
  String get title => switch (this) {
    DocumentType.creditNoteTemplate1 ||
    DocumentType.creditNoteTemplate2 => 'CREDIT NOTE',
    DocumentType.deliveryChallan => 'DELIVERY CHALLAN',
    DocumentType.packagingSlip => 'PACKAGE',
    DocumentType.salesInvoiceTemplate1 ||
    DocumentType.salesInvoiceTemplate2 => 'TAX INVOICE',
    DocumentType.salesReturn => 'SALES RETURN',
    DocumentType.salesOrder => 'SALES ORDER',
  };

  /// Label that prefixes the document number, e.g. `Package# PKG-17`.
  String get numberLabel => switch (this) {
    DocumentType.creditNoteTemplate1 ||
    DocumentType.creditNoteTemplate2 ||
    DocumentType.salesInvoiceTemplate1 ||
    DocumentType.salesInvoiceTemplate2 => '#',
    DocumentType.deliveryChallan => 'Delivery Challan#',
    DocumentType.packagingSlip => 'Package#',
    DocumentType.salesReturn => 'RMA#',
    DocumentType.salesOrder => 'Sales Order#',
  };

  /// Name of the settings page quoted in the default terms text.
  String get preferencesPageName => switch (this) {
    DocumentType.creditNoteTemplate1 ||
    DocumentType.creditNoteTemplate2 => 'Credit notes',
    DocumentType.deliveryChallan => 'DeliveryChallan',
    DocumentType.packagingSlip => 'Package',
    DocumentType.salesInvoiceTemplate1 ||
    DocumentType.salesInvoiceTemplate2 => 'Invoice',
    DocumentType.salesReturn => 'SalesReturn',
    DocumentType.salesOrder => 'SalesOrder',
  };

  String get displayName => switch (this) {
    DocumentType.creditNoteTemplate1 => 'Credit Note (Template 1)',
    DocumentType.creditNoteTemplate2 => 'Credit Note (Template 2)',
    DocumentType.deliveryChallan => 'Delivery Challan',
    DocumentType.packagingSlip => 'Packaging Slip',
    DocumentType.salesInvoiceTemplate1 => 'Sales Invoice (Template 1)',
    DocumentType.salesInvoiceTemplate2 => 'Sales Invoice (Template 2)',
    DocumentType.salesReturn => 'Sales Return',
    DocumentType.salesOrder => 'Sales Order',
  };

  static DocumentType parse(String? raw) {
    final key = raw?.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    return switch (key) {
      'creditnote' || 'creditnote1' || 'creditnotetemplate1' =>
        DocumentType.creditNoteTemplate1,
      'creditnote2' || 'creditnotetemplate2' =>
        DocumentType.creditNoteTemplate2,
      'deliverychallan' || 'dc' => DocumentType.deliveryChallan,
      'packagingslip' || 'packingslip' || 'package' =>
        DocumentType.packagingSlip,
      'salesinvoice' || 'salesinvoice1' || 'salesinvoicetemplate1' ||
      'taxinvoice' => DocumentType.salesInvoiceTemplate1,
      'salesinvoice2' || 'salesinvoicetemplate2' =>
        DocumentType.salesInvoiceTemplate2,
      'salesreturn' || 'rma' => DocumentType.salesReturn,
      'salesorder' || 'so' => DocumentType.salesOrder,
      _ => throw FormatException('Unknown document type: $raw'),
    };
  }
}
