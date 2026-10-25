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

  /// Formats byte counts into human-readable data volume units (B, KB, MB, GB, TB).
  static String formatDataVolume(num bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double current = bytes.toDouble();
    while (current >= 1024 && i < suffixes.length - 1) {
      current /= 1024;
      i++;
    }
    return '${current.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  /// Formats an event count over a duration into a readable rate (e.g., '120.0 req/s', '45.0 req/m').
  static String formatRate(num count, Duration duration) {
    if (duration.inSeconds <= 0) return '0.0 req/s';
    final perSec = count / duration.inSeconds;
    if (perSec >= 1.0) {
      return '${perSec.toStringAsFixed(1)} req/s';
    } else if (duration.inMinutes > 0) {
      final perMin = count / duration.inMinutes;
      return '${perMin.toStringAsFixed(1)} req/m';
    } else {
      return '${count.toStringAsFixed(0)} req/${duration.inSeconds}s';
    }
  }
}
