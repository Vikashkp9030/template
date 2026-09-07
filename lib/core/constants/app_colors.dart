import 'package:flutter/material.dart';

class AppColors {
  static const seed = Color(0xFF0F766E);

  // Invoice template colors live in InvoiceTemplateThemes
  // (lib/features/invoice_templates/theme/invoice_template_theme.dart) —
  // the single source of truth shared by the Flutter and PDF renderers.

  // Thermal Template Colors
  static const thermalAccent = Color(0xFF000000);

  // Status Colors
  static const success = Color(0xFF15803D);
  static const warning = Color(0xFFB45309);
  static const danger = Color(0xFFB91C1C);

  // General UI
  static const surface = Color(0xFFF8FAFC);
  static const border = Color(0xFFE2E8F0);
}
