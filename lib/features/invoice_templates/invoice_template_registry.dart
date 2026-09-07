import 'invoice_template.dart';
import 'invoice_template_type.dart';
import 'templates/invoice_template_basic.dart';
import 'templates/invoice_template_enterprise.dart';
import 'templates/invoice_template_premium.dart';

class InvoiceTemplateRegistry {
  InvoiceTemplateRegistry._();

  static final Map<InvoiceTemplateType, InvoiceTemplate> templates = {
    InvoiceTemplateType.basic: BasicInvoiceTemplate(),
    InvoiceTemplateType.standard: EnterpriseInvoiceTemplate(),
    InvoiceTemplateType.premium: PremiumInvoiceTemplate(),
  };

  static InvoiceTemplate get(InvoiceTemplateType type) {
    final template = templates[type];
    if (template == null) {
      // Fallback to basic if not found
      return templates[InvoiceTemplateType.basic]!;
    }
    return template;
  }
}
