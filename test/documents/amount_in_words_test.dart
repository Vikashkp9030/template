import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_template_preview/core/utils/amount_in_words.dart';

void main() {
  group('AmountInWords', () {
    test('matches the wording the reference documents print', () {
      expect(
        AmountInWords.convert(705.60),
        'Indian Rupee Seven Hundred Five and Sixty Paise Only',
      );
    });

    test('omits the fractional part when there is none', () {
      expect(AmountInWords.convert(700), 'Indian Rupee Seven Hundred Only');
    });

    test('uses Indian grouping', () {
      expect(
        AmountInWords.convert(12345678),
        'Indian Rupee One Crore Twenty Three Lakh Forty Five Thousand '
        'Six Hundred Seventy Eight Only',
      );
    });

    test('handles zero, sub-rupee and negative amounts', () {
      expect(AmountInWords.convert(0), 'Indian Rupee Zero Only');
      expect(
        AmountInWords.convert(0.05),
        'Indian Rupee Zero and Five Paise Only',
      );
      expect(
        AmountInWords.convert(-5.50),
        'Minus Indian Rupee Five and Fifty Paise Only',
      );
    });

    test('rounds to the nearest paisa rather than truncating', () {
      expect(AmountInWords.convert(2.999), 'Indian Rupee Three Only');
      expect(
        AmountInWords.convert(2.994),
        'Indian Rupee Two and Ninety Nine Paise Only',
      );
    });

    test('names other currencies', () {
      expect(
        AmountInWords.convert(2.50, currency: 'USD'),
        'US Dollar Two and Fifty Cents Only',
      );
      expect(AmountInWords.convert(1, currency: 'ZZZ'), 'ZZZ One Only');
    });
  });
}
