import 'package:pdf/widgets.dart' as pw;

/// Measures text with the very font the page will be rendered with.
///
/// The layout blocks declare how tall they are so the sections below them sit
/// at the measured offsets. Anything that can wrap — an address, an item
/// description, the terms — therefore has to be wrapped here first, using the
/// same greedy word-breaking the text renderer uses, rather than guessed at.
class TextMeasure {
  const TextMeasure(this.context);

  final pw.Context context;

  double width(String text, pw.TextStyle style) {
    final font = style.font;
    final size = style.fontSize;
    if (font == null || size == null || text.isEmpty) return 0;
    final metrics = font.getFont(context).stringMetrics(text);
    return metrics.advanceWidth * size +
        (style.letterSpacing ?? 0) * text.length;
  }

  /// Number of rendered lines [text] occupies in a box [maxWidth] wide,
  /// counting explicit newlines.
  int lineCount(String text, pw.TextStyle style, double maxWidth) {
    if (text.isEmpty) return 1;
    var total = 0;
    for (final paragraph in text.split('\n')) {
      total += _wrap(paragraph, style, maxWidth);
    }
    return total == 0 ? 1 : total;
  }

  int _wrap(String paragraph, pw.TextStyle style, double maxWidth) {
    final words = paragraph.split(RegExp(r'\s+'))
      ..removeWhere((word) => word.isEmpty);
    if (words.isEmpty) return 1;
    if (maxWidth <= 0) return 1;

    var lines = 1;
    var current = words.first;
    for (final word in words.skip(1)) {
      final candidate = '$current $word';
      if (width(candidate, style) <= maxWidth) {
        current = candidate;
      } else {
        lines++;
        current = word;
      }
    }
    return lines;
  }
}
