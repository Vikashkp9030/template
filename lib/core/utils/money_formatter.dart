import 'package:intl/intl.dart';

class MoneyFormatter {
  static String format(num value, {String currency = 'INR'}) {
    final format = NumberFormat.currency(
      locale: currency == 'INR' ? 'en_IN' : 'en_US',
      symbol: _symbol(currency),
      decimalDigits: 2,
    );
    return format.format(value);
  }

  static String plain(num value) => value.toStringAsFixed(2);

  static String _symbol(String currency) {
    return switch (currency) {
      'INR' => '₹',
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      _ => '$currency ',
    };
  }
}
