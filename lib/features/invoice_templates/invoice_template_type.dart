/// `standard` is the stable data-contract identifier (YAML `template:
/// standard`, the `parse` key `'standard'`/`'02'`, and this package's public
/// exports) — it is presented to users as "Enterprise" via [title] /
/// [shortLabel] / [description] below, but is never renamed itself so
/// existing stored data and external consumers keep working unchanged.
enum InvoiceTemplateType { basic, standard, premium }

extension InvoiceTemplateTypeX on InvoiceTemplateType {
  String get id => name;

  String get title => switch (this) {
    InvoiceTemplateType.basic => 'Basic Format',
    InvoiceTemplateType.standard => 'Enterprise Format',
    InvoiceTemplateType.premium => 'Premium Format',
  };

  String get shortLabel => switch (this) {
    InvoiceTemplateType.basic => 'Basic',
    InvoiceTemplateType.standard => 'Enterprise',
    InvoiceTemplateType.premium => 'Premium',
  };

  String get description => switch (this) {
    InvoiceTemplateType.basic =>
      'Clean and simple layout for everyday business needs.',
    InvoiceTemplateType.standard =>
      'Corporate layout with strong information hierarchy for larger organizations.',
    InvoiceTemplateType.premium =>
      'Branded, high-end invoice with refined typography and summary cards.',
  };

  static InvoiceTemplateType parse(String? raw) {
    return switch (raw?.toLowerCase()) {
      null || 'basic' || '01' => InvoiceTemplateType.basic,
      'standard' || 'enterprise' || '02' => InvoiceTemplateType.standard,
      'premium' || '03' => InvoiceTemplateType.premium,
      _ => InvoiceTemplateType.basic, // Fallback to basic
    };
  }
}
