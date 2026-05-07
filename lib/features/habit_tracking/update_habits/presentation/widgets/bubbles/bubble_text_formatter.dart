import 'dart:math';

/// Pure utility functions for formatting habit titles and sizing them
/// to fit inside a circular bubble.
class BubbleTextFormatter {
  BubbleTextFormatter._();

  /// Wraps a habit name onto multiple lines so it fits inside a bubble.
  ///
  /// - Single short word: returned as-is.
  /// - Single long word: split roughly in half.
  /// - Multi-word: greedy-wrap at ~11 chars per line.
  static String formatTitle(String value) {
    final String text = value.trim();
    if (text.length <= 12) return text;

    final List<String> words = text.split(RegExp(r'\s+'));
    if (words.length == 1) {
      final int mid = (text.length / 2).ceil();
      return '${text.substring(0, mid)}\n${text.substring(mid)}';
    }

    final StringBuffer buf = StringBuffer();
    int lineLen = 0;
    for (final String word in words) {
      if (lineLen + word.length > 11) {
        buf.write('\n');
        lineLen = 0;
      } else if (lineLen != 0) {
        buf.write(' ');
        lineLen++;
      }
      buf.write(word);
      lineLen += word.length;
    }
    return buf.toString();
  }

  /// Computes a font size that fits the formatted title inside the
  /// inscribed square of a circle of the given diameter.
  static double dynamicTitleSize(String habitName, double bubbleSize) {
    final String formatted = formatTitle(habitName);
    final List<String> lines = formatted.split('\n');
    final int longest = lines.fold<int>(1, (p, c) => max(p, c.trim().length));
    final double innerSide = bubbleSize / 2 * sqrt2 * 0.78;
    final double w = innerSide / (longest * 0.55);
    final double h = (innerSide * 0.72) / (lines.length + 0.9);
    return min(w, h).clamp(11, 34).toDouble();
  }
}