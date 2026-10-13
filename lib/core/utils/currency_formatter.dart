import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatCents(int cents, {String currency = 'USD'}) {
    final double amount = cents / 100.0;
    final format = NumberFormat.simpleCurrency(name: currency, decimalDigits: 2);
    return format.format(amount);
  }

  static String formatAmount(double amount, {String currency = 'USD'}) {
    final format = NumberFormat.simpleCurrency(name: currency, decimalDigits: 2);
    return format.format(amount);
  }

  static String formatCompact(double amount, {String currency = 'USD'}) {
    final format = NumberFormat.compactSimpleCurrency(name: currency);
    return format.format(amount);
  }
}
