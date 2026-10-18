import 'package:intl/intl.dart';

/// Utility class for formatting numerical metrics, percentages, and compact units.
class NumberFormatter {
  /// Formats a double percentage into a human-readable string with optional plus sign.
  /// Example: `formatPercentage(12.45)` -> `"+12.5%"`
  /// Example: `formatPercentage(-3.2, showPlus: false)` -> `"-3.2%"`
  static String formatPercentage(double value, {int decimalDigits = 1, bool showPlus = true}) {
    final formattedNumber = value.toStringAsFixed(decimalDigits);
    if (value > 0 && showPlus) {
      return '+$formattedNumber%';
    }
    return '$formattedNumber%';
  }

  /// Formats integer or double counts into compact metric strings (e.g., 1.5K, 2.3M).
  static String formatCompact(num value) {
    return NumberFormat.compact().format(value);
  }

  /// Formats an integer count with thousands separators (e.g., 12,500).
  static String formatCount(int count) {
    return NumberFormat.decimalPattern().format(count);
  }
}
