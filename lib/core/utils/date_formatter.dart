import 'package:intl/intl.dart';

class DateFormatter {
  static String display(DateTime date) =>
      DateFormat('dd-MMM-yyyy').format(date);

  static String iso(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static String dateTime(DateTime date) =>
      DateFormat('dd-MMM-yyyy HH:mm').format(date);

  static DateTime parse(String raw) {
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;
    try {
      return DateFormat('dd-MM-yyyy').parseStrict(raw);
    } catch (_) {
      throw FormatException('Invalid date: $raw');
    }
  }
}
