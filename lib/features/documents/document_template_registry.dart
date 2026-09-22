import '../../models/document/document_type.dart';
import 'document_template.dart';
import 'templates/credit_note_template1.dart';
import 'templates/credit_note_template2.dart';
import 'templates/delivery_challan_template.dart';
import 'templates/packaging_slip_template.dart';
import 'templates/sales_invoice_template1.dart';
import 'templates/sales_invoice_template2.dart';
import 'templates/sales_order_template.dart';
import 'templates/sales_return_template.dart';

/// Maps each document type to the template that reproduces its reference PDF.
class DocumentTemplateRegistry {
  const DocumentTemplateRegistry._();

  static const Map<DocumentType, DocumentPdfTemplate> templates = {
    DocumentType.creditNoteTemplate1: CreditNoteTemplate1(),
    DocumentType.creditNoteTemplate2: CreditNoteTemplate2(),
    DocumentType.deliveryChallan: DeliveryChallanTemplate(),
    DocumentType.packagingSlip: PackagingSlipTemplate(),
    DocumentType.salesInvoiceTemplate1: SalesInvoiceTemplate1(),
    DocumentType.salesInvoiceTemplate2: SalesInvoiceTemplate2(),
    DocumentType.salesOrder: SalesOrderTemplate(),
    DocumentType.salesReturn: SalesReturnTemplate(),
  };

  static DocumentPdfTemplate get(DocumentType type) {
    final template = templates[type];
    if (template == null) {
      throw StateError('No template registered for ${type.displayName}.');
    }
    return template;
  }
}
