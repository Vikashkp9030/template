import 'package:intl/intl.dart';

/// Number and date formats the reference documents print.
class DocumentFormat {
  const DocumentFormat._();

  /// `21 Sep 2026` — the date format every reference uses except the linked
  /// invoice date on credit notes.
  static String date(DateTime value) => DateFormat('dd MMM yyyy').format(value);

  /// `01/01/2018` — used for the invoice a credit note refers back to.
  static String shortDate(DateTime value) =>
      DateFormat('dd/MM/yyyy').format(value);

  /// `1,63,000.00` — Indian digit grouping, always two decimals, no symbol.
  static String amount(num value) =>
      NumberFormat('#,##,##0.00', 'en_IN').format(value);

  /// The same, prefixed with the currency symbol, as the grand totals print.
  static String currency(num value, String currencyCode) =>
      '${symbol(currencyCode)}${amount(value)}';

  /// A deduction, e.g. `(-) 100.00`.
  static String deduction(num value) => '(-) ${amount(value.abs())}';

  /// `1.00` — quantities keep two decimals in every reference.
  static String quantity(num value) => value.toStringAsFixed(2);

  static String symbol(String currencyCode) => switch (currencyCode) {
    'INR' => '₹',
    'USD' => r'$',
    'EUR' => '€',
    'GBP' => '£',
    _ => '$currencyCode ',
  };
}
