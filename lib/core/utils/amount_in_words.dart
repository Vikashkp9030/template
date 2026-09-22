/// Converts an amount to words using the Indian numbering system
/// (crore / lakh / thousand), which is what the reference documents print:
///
///     705.60 -> "Indian Rupee Seven Hundred Five and Sixty Paise Only"
class AmountInWords {
  const AmountInWords._();

  static const _units = <String>[
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
    'Seventeen', 'Eighteen', 'Nineteen',
  ];

  static const _tens = <String>[
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy',
    'Eighty', 'Ninety',
  ];

  /// Currency name and fractional-unit name, keyed by ISO code.
  static const _currencies = <String, ({String major, String minor})>{
    'INR': (major: 'Indian Rupee', minor: 'Paise'),
    'USD': (major: 'US Dollar', minor: 'Cents'),
    'EUR': (major: 'Euro', minor: 'Cents'),
    'GBP': (major: 'Pound Sterling', minor: 'Pence'),
  };

  static String convert(num amount, {String currency = 'INR'}) {
    final names = _currencies[currency] ??
        (major: currency, minor: 'Cents');

    final negative = amount < 0;
    final absolute = amount.abs();

    // Round to 2dp before splitting so 0.005 cases do not lose a paisa.
    final totalMinor = (absolute * 100).round();
    final major = totalMinor ~/ 100;
    final minor = totalMinor % 100;

    final buffer = StringBuffer();
    if (negative) buffer.write('Minus ');
    buffer.write(names.major);

    buffer
      ..write(' ')
      ..write(major > 0 ? _indian(major) : 'Zero');

    if (minor > 0) {
      buffer
        ..write(' and ')
        ..write(_below100(minor))
        ..write(' ')
        ..write(names.minor);
    }

    buffer.write(' Only');
    return buffer.toString();
  }

  static String _indian(int value) {
    if (value == 0) return 'Zero';

    final parts = <String>[];

    void take(int divisor, String label) {
      final chunk = value ~/ divisor;
      if (chunk == 0) return;
      parts.add('${_below100(chunk)} $label');
      value %= divisor;
    }

    // Anything above 99 crore is still expressed in crore, as Indian
    // numbering has no larger standard unit in common accounting use.
    take(10000000, 'Crore');
    take(100000, 'Lakh');
    take(1000, 'Thousand');
    take(100, 'Hundred');

    if (value > 0) parts.add(_below100(value));

    return parts.join(' ');
  }

  static String _below100(int value) {
    if (value < 20) return _units[value];
    final tens = _tens[value ~/ 10];
    final unit = value % 10;
    return unit == 0 ? tens : '$tens ${_units[unit]}';
  }
}
