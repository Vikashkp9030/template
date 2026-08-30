enum InvoiceTemplateType { professional, modern, gst, retail, premium, compact }

extension InvoiceTemplateTypeX on InvoiceTemplateType {
  String get id => name;

  String get title => switch (this) {
    InvoiceTemplateType.professional => 'Professional Corporate',
    InvoiceTemplateType.modern => 'Modern Minimal',
    InvoiceTemplateType.gst => 'GST India Invoice',
    InvoiceTemplateType.retail => 'Retail ERP',
    InvoiceTemplateType.premium => 'Premium Business',
    InvoiceTemplateType.compact => 'Compact Business',
  };

  String get shortLabel => switch (this) {
    InvoiceTemplateType.professional => 'Professional',
    InvoiceTemplateType.modern => 'Modern',
    InvoiceTemplateType.gst => 'GST',
    InvoiceTemplateType.retail => 'Retail',
    InvoiceTemplateType.premium => 'Premium',
    InvoiceTemplateType.compact => 'Compact',
  };

  String get description => switch (this) {
    InvoiceTemplateType.professional =>
      'Corporate invoice with logo, GST, signature and terms.',
    InvoiceTemplateType.modern =>
      'Minimal layout with large totals and payment status.',
    InvoiceTemplateType.gst =>
      'Indian GST invoice with HSN, CGST/SGST/IGST breakup.',
    InvoiceTemplateType.retail =>
      'Retail ERP bill with SKU, warehouse and salesperson.',
    InvoiceTemplateType.premium =>
      'Premium branded invoice with summary card and bank details.',
    InvoiceTemplateType.compact =>
      'Dense A4-friendly invoice for high-volume printing.',
  };

  static InvoiceTemplateType parse(String? raw) {
    return switch (raw?.toLowerCase()) {
      null ||
      'professional' ||
      '01' ||
      'template_01' => InvoiceTemplateType.professional,
      'modern' || '02' || 'template_02' => InvoiceTemplateType.modern,
      'gst' || 'gst_india' || '03' || 'template_03' => InvoiceTemplateType.gst,
      'retail' || '04' || 'template_04' => InvoiceTemplateType.retail,
      'premium' || '05' || 'template_05' => InvoiceTemplateType.premium,
      'compact' || '06' || 'template_06' => InvoiceTemplateType.compact,
      _ => throw FormatException('Unknown invoice template: $raw'),
    };
  }
}
