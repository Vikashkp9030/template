import 'package:flutter/material.dart';

/// Font weight expressed independently of `package:flutter` and
/// `package:pdf`'s own `FontWeight` types, so a single [InvoiceTemplateTheme]
/// can be mapped to either renderer without picking a side.
enum InvoiceFontWeight { regular, medium, semiBold, bold, black }

extension InvoiceFontWeightX on InvoiceFontWeight {
  FontWeight get flutter => switch (this) {
    InvoiceFontWeight.regular => FontWeight.w400,
    InvoiceFontWeight.medium => FontWeight.w500,
    InvoiceFontWeight.semiBold => FontWeight.w600,
    InvoiceFontWeight.bold => FontWeight.w700,
    InvoiceFontWeight.black => FontWeight.w900,
  };
}

/// A single type-scale entry shared by every renderer.
class InvoiceTextStyle {
  const InvoiceTextStyle({
    required this.fontSize,
    this.weight = InvoiceFontWeight.regular,
    this.color = 0xFF111827,
    this.letterSpacing = 0.0,
    this.height,
  });

  final double fontSize;
  final InvoiceFontWeight weight;
  final int color;
  final double letterSpacing;
  final double? height;

  TextStyle get flutter => TextStyle(
    fontSize: fontSize,
    fontWeight: weight.flutter,
    color: Color(color),
    letterSpacing: letterSpacing,
    height: height,
  );

  InvoiceTextStyle copyWith({int? color, double? fontSize}) => InvoiceTextStyle(
    fontSize: fontSize ?? this.fontSize,
    weight: weight,
    color: color ?? this.color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

/// Type scale used by a template: document title down to footer text.
class InvoiceTypeScale {
  const InvoiceTypeScale({
    required this.documentTitle,
    required this.sectionLabel,
    required this.body,
    required this.bodyStrong,
    required this.tableHeader,
    required this.tableCell,
    required this.tableCellStrong,
    required this.totalLabel,
    required this.totalValue,
    required this.grandTotalLabel,
    required this.grandTotalValue,
    required this.footer,
  });

  final InvoiceTextStyle documentTitle;
  final InvoiceTextStyle sectionLabel;
  final InvoiceTextStyle body;
  final InvoiceTextStyle bodyStrong;
  final InvoiceTextStyle tableHeader;
  final InvoiceTextStyle tableCell;
  final InvoiceTextStyle tableCellStrong;
  final InvoiceTextStyle totalLabel;
  final InvoiceTextStyle totalValue;
  final InvoiceTextStyle grandTotalLabel;
  final InvoiceTextStyle grandTotalValue;
  final InvoiceTextStyle footer;
}

/// Table-specific styling shared by every section that renders a grid.
class InvoiceTableStyle {
  const InvoiceTableStyle({
    required this.headerBackground,
    required this.headerForeground,
    required this.rowDivider,
    required this.cellPaddingVertical,
    required this.cellPaddingHorizontal,
    this.headerBorderOnly = false,
  });

  /// Null means the header sits on a transparent background with a rule
  /// underneath instead of a filled bar (used by Basic).
  final int? headerBackground;
  final int headerForeground;
  final int rowDivider;
  final double cellPaddingVertical;
  final double cellPaddingHorizontal;

  /// When true the header has no fill, only a bottom border (Basic style).
  final bool headerBorderOnly;
}

/// Single source of truth for one template's look: colors, spacing, and
/// typography. The PDF is rasterized from these same widgets, so Preview and
/// PDF read this one instance and cannot drift.
class InvoiceTemplateTheme {
  const InvoiceTemplateTheme({
    required this.pageMargin,
    required this.background,
    required this.primary,
    required this.accent,
    required this.textMuted,
    required this.divider,
    required this.surfaceMuted,
    required this.type,
    required this.table,
    this.grandTotalCardBackground,
    this.grandTotalCardForeground,
  });

  final double pageMargin;
  final int background;
  final int primary;
  final int accent;
  final int textMuted;
  final int divider;
  final int surfaceMuted;
  final InvoiceTypeScale type;
  final InvoiceTableStyle table;

  /// Premium renders totals inside a filled card; null for themes that use a
  /// plain list instead.
  final int? grandTotalCardBackground;
  final int? grandTotalCardForeground;
}

class InvoiceTemplateThemes {
  InvoiceTemplateThemes._();

  static const _basicInk = 0xFF111827;
  static const _basicMuted = 0xFF6B7280;

  static const basic = InvoiceTemplateTheme(
    pageMargin: 40,
    background: 0xFFFFFFFF,
    primary: _basicInk,
    accent: 0xFF374151,
    textMuted: _basicMuted,
    divider: 0xFFE5E7EB,
    surfaceMuted: 0xFFF9FAFB,
    type: InvoiceTypeScale(
      documentTitle: InvoiceTextStyle(
        fontSize: 26,
        weight: InvoiceFontWeight.regular,
        letterSpacing: 2.0,
        color: _basicInk,
      ),
      sectionLabel: InvoiceTextStyle(
        fontSize: 10,
        weight: InvoiceFontWeight.bold,
        color: _basicMuted,
        letterSpacing: 0.6,
      ),
      body: InvoiceTextStyle(fontSize: 11, color: _basicInk, height: 1.5),
      bodyStrong: InvoiceTextStyle(
        fontSize: 11,
        weight: InvoiceFontWeight.bold,
        color: _basicInk,
        height: 1.5,
      ),
      tableHeader: InvoiceTextStyle(
        fontSize: 10,
        weight: InvoiceFontWeight.bold,
        color: _basicMuted,
        letterSpacing: 0.4,
      ),
      tableCell: InvoiceTextStyle(fontSize: 11, color: _basicInk),
      tableCellStrong: InvoiceTextStyle(
        fontSize: 11,
        weight: InvoiceFontWeight.medium,
        color: _basicInk,
      ),
      totalLabel: InvoiceTextStyle(fontSize: 11, color: _basicMuted),
      totalValue: InvoiceTextStyle(fontSize: 11, color: _basicInk),
      grandTotalLabel: InvoiceTextStyle(
        fontSize: 13,
        weight: InvoiceFontWeight.bold,
        color: _basicInk,
      ),
      grandTotalValue: InvoiceTextStyle(
        fontSize: 15,
        weight: InvoiceFontWeight.bold,
        color: _basicInk,
      ),
      footer: InvoiceTextStyle(fontSize: 9, color: _basicMuted),
    ),
    table: InvoiceTableStyle(
      headerBackground: null,
      headerForeground: _basicMuted,
      rowDivider: 0xFFF3F4F6,
      cellPaddingVertical: 12,
      cellPaddingHorizontal: 8,
      headerBorderOnly: true,
    ),
  );

  static const _enterpriseAccent = 0xFF315A96;
  static const _enterpriseInk = 0xFF111111;
  static const _enterpriseBody = 0xFF333333;
  static const _enterpriseMuted = 0xFF667085;

  static const enterprise = InvoiceTemplateTheme(
    pageMargin: 25,
    background: 0xFFFFFFFF,
    primary: _enterpriseInk,
    accent: _enterpriseAccent,
    textMuted: _enterpriseMuted,
    divider: 0xFF999999,
    surfaceMuted: 0xFFE8F0F8,
    type: InvoiceTypeScale(
      documentTitle: InvoiceTextStyle(
        fontSize: 48,
        weight: InvoiceFontWeight.bold,
        letterSpacing: 0.0,
        color: _enterpriseAccent,
      ),
      sectionLabel: InvoiceTextStyle(
        fontSize: 12,
        weight: InvoiceFontWeight.bold,
        color: 0xFFFFFFFF,
        letterSpacing: 0.5,
      ),
      body: InvoiceTextStyle(fontSize: 11, color: _enterpriseInk, height: 1.6),
      bodyStrong: InvoiceTextStyle(
        fontSize: 12,
        weight: InvoiceFontWeight.bold,
        color: _enterpriseInk,
        height: 1.6,
      ),
      tableHeader: InvoiceTextStyle(
        fontSize: 11,
        weight: InvoiceFontWeight.bold,
        color: 0xFFFFFFFF,
        letterSpacing: 0.5,
      ),
      tableCell: InvoiceTextStyle(fontSize: 10, color: _enterpriseBody),
      tableCellStrong: InvoiceTextStyle(
        fontSize: 10,
        weight: InvoiceFontWeight.regular,
        color: _enterpriseBody,
      ),
      totalLabel: InvoiceTextStyle(fontSize: 11, color: _enterpriseInk),
      totalValue: InvoiceTextStyle(fontSize: 11, weight: InvoiceFontWeight.bold, color: _enterpriseInk),
      grandTotalLabel: InvoiceTextStyle(
        fontSize: 12,
        weight: InvoiceFontWeight.bold,
        color: _enterpriseInk,
      ),
      grandTotalValue: InvoiceTextStyle(
        fontSize: 13,
        weight: InvoiceFontWeight.bold,
        color: _enterpriseInk,
      ),
      footer: InvoiceTextStyle(fontSize: 10, color: _enterpriseInk),
    ),
    table: InvoiceTableStyle(
      headerBackground: _enterpriseAccent,
      headerForeground: 0xFFFFFFFF,
      rowDivider: 0xFF999999,
      cellPaddingVertical: 8,
      cellPaddingHorizontal: 8,
    ),
  );

  static const _premiumInk = 0xFF0F172A;
  static const _premiumAccent = 0xFF8B5CF6;
  static const _premiumMuted = 0xFF6B7280;

  static const premium = InvoiceTemplateTheme(
    pageMargin: 40,
    background: 0xFFFFFFFF,
    primary: _premiumInk,
    accent: _premiumAccent,
    textMuted: _premiumMuted,
    divider: 0xFFF1F5F9,
    surfaceMuted: 0xFFF8FAFC,
    grandTotalCardBackground: _premiumInk,
    grandTotalCardForeground: 0xFFFFFFFF,
    type: InvoiceTypeScale(
      documentTitle: InvoiceTextStyle(
        fontSize: 28,
        weight: InvoiceFontWeight.black,
        letterSpacing: -0.5,
        color: _premiumAccent,
      ),
      sectionLabel: InvoiceTextStyle(
        fontSize: 9,
        weight: InvoiceFontWeight.black,
        color: _premiumAccent,
        letterSpacing: 1.5,
      ),
      body: InvoiceTextStyle(fontSize: 10.5, color: _premiumInk, height: 1.5),
      bodyStrong: InvoiceTextStyle(
        fontSize: 10.5,
        weight: InvoiceFontWeight.bold,
        color: _premiumInk,
        height: 1.5,
      ),
      tableHeader: InvoiceTextStyle(
        fontSize: 9,
        weight: InvoiceFontWeight.black,
        color: _premiumAccent,
        letterSpacing: 1.0,
      ),
      tableCell: InvoiceTextStyle(fontSize: 11, color: _premiumInk),
      tableCellStrong: InvoiceTextStyle(
        fontSize: 11,
        weight: InvoiceFontWeight.bold,
        color: _premiumInk,
      ),
      totalLabel: InvoiceTextStyle(fontSize: 9, weight: InvoiceFontWeight.bold, color: 0xB3FFFFFF),
      totalValue: InvoiceTextStyle(fontSize: 12, weight: InvoiceFontWeight.bold, color: 0xB3FFFFFF),
      grandTotalLabel: InvoiceTextStyle(
        fontSize: 12,
        weight: InvoiceFontWeight.black,
        color: 0xFFFFFFFF,
      ),
      grandTotalValue: InvoiceTextStyle(
        fontSize: 19,
        weight: InvoiceFontWeight.black,
        color: 0xFFFFFFFF,
      ),
      footer: InvoiceTextStyle(fontSize: 9, color: _premiumMuted),
    ),
    table: InvoiceTableStyle(
      headerBackground: null,
      headerForeground: _premiumAccent,
      rowDivider: 0xFFF1F5F9,
      cellPaddingVertical: 16,
      cellPaddingHorizontal: 8,
      headerBorderOnly: true,
    ),
  );
}
