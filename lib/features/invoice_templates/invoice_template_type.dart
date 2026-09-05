enum InvoiceTemplateType { basic, standard, premium }

extension InvoiceTemplateTypeX on InvoiceTemplateType {
  String get id => name;

  String get title => switch (this) {
    InvoiceTemplateType.basic => 'Basic Format',
    InvoiceTemplateType.standard => 'Standard Format',
    InvoiceTemplateType.premium => 'Premium Format',
  };

  String get shortLabel => switch (this) {
    InvoiceTemplateType.basic => 'Basic',
    InvoiceTemplateType.standard => 'Standard',
    InvoiceTemplateType.premium => 'Premium',
  };

  String get description => switch (this) {
    InvoiceTemplateType.basic =>
      'Clean and simple layout for everyday business needs.',
    InvoiceTemplateType.standard =>
      'Professional business invoice with logo and signature support.',
    InvoiceTemplateType.premium =>
      'Branded invoice with summary cards and high-quality styling.',
  };

  static InvoiceTemplateType parse(String? raw) {
    return switch (raw?.toLowerCase()) {
      null || 'basic' || '01' => InvoiceTemplateType.basic,
      'standard' || '02' => InvoiceTemplateType.standard,
      'premium' || '03' => InvoiceTemplateType.premium,
      _ => InvoiceTemplateType.basic, // Fallback to basic
    };
  }
}
