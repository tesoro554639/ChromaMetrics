import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  /// Formats a [DateTime] into a friendly relative elapsed time (e.g., 'just now', '5 minutes ago', 'yesterday').
  /// Supports optional [clock] parameter for deterministic testing.
  static String formatRelative(DateTime date, {DateTime? clock}) {
    final now = clock ?? DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      return formatDate(date);
    }

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? "minute" : "minutes"} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? "hour" : "hours"} ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return '$days ${days == 1 ? "day" : "days"} ago';
    } else {
      return formatDate(date);
    }
  }

  /// Formats a [Duration] into a concise readable string (e.g., '1h 15m', '45s', '2d 4h').
  static String formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      final remSec = duration.inSeconds % 60;
      return remSec == 0 ? '${duration.inMinutes}m' : '${duration.inMinutes}m ${remSec}s';
    } else if (duration.inHours < 24) {
      final remMin = duration.inMinutes % 60;
      return remMin == 0 ? '${duration.inHours}h' : '${duration.inHours}h ${remMin}m';
    } else {
      final remHours = duration.inHours % 24;
      return remHours == 0 ? '${duration.inDays}d' : '${duration.inDays}d ${remHours}h';
    }
  }
}

