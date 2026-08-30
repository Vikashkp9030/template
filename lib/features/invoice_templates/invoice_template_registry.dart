import 'invoice_template.dart';
import 'invoice_template_type.dart';
import 'templates/invoice_template_01.dart';
import 'templates/invoice_template_02.dart';
import 'templates/invoice_template_03.dart';
import 'templates/invoice_template_04.dart';
import 'templates/invoice_template_05.dart';
import 'templates/invoice_template_06.dart';

class InvoiceTemplateRegistry {
  InvoiceTemplateRegistry._();

  static final Map<InvoiceTemplateType, InvoiceTemplate> templates = {
    InvoiceTemplateType.professional: ProfessionalInvoiceTemplate(),
    InvoiceTemplateType.modern: ModernInvoiceTemplate(),
    InvoiceTemplateType.gst: GstInvoiceTemplate(),
    InvoiceTemplateType.retail: RetailInvoiceTemplate(),
    InvoiceTemplateType.premium: PremiumInvoiceTemplate(),
    InvoiceTemplateType.compact: CompactInvoiceTemplate(),
  };

  static InvoiceTemplate get(InvoiceTemplateType type) {
    final template = templates[type];
    if (template == null) {
      throw StateError('No invoice template registered for $type');
    }
    return template;
  }
}
