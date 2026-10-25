/// Utility class for string manipulation, privacy masking, and identifier generation.
class StringFormatter {
  /// Masks an email address for privacy in public/audit logs.
  /// Example: `maskEmail("alex.chen@acme.com")` -> `"a***n@acme.com"`
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];

    if (local.length <= 2) {
      return '$local***@$domain';
    }

    final first = local.substring(0, 1);
    final last = local.substring(local.length - 1);
    return '$first***$last@$domain';
  }

  /// Converts a company or organization name into a URL-friendly lowercase slug.
  /// Example: `toSlug("Starlight AI & Robotics")` -> `"starlight-ai-robotics"`
  static String toSlug(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  /// Truncates a string to [maxLength] characters, appending an ellipsis if truncated.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalizes the first letter of the string.
  /// Example: `capitalize("active")` -> `"Active"`
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Masks sensitive API keys, keeping only the leading prefix and last 4 characters.
  /// Example: `maskApiKey("sk_live_998877665544")` -> `"sk_live_...5544"`
  static String maskApiKey(String key) {
    if (key.length <= 8) return '****';
    final prefix = key.length > 8 ? key.substring(0, 8) : key.substring(0, 4);
    final suffix = key.substring(key.length - 4);
    return '$prefix...$suffix';
  }
}
