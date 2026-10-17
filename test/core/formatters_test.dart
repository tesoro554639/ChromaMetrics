import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/core/utils/currency_formatter.dart';
import 'package:multi_tenant_saas_billing/core/utils/date_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats cents into dollar strings', () {
      expect(CurrencyFormatter.formatCents(1000), equals('\$10.00'));
      expect(CurrencyFormatter.formatCents(0), equals('\$0.00'));
      expect(CurrencyFormatter.formatCents(4999), equals('\$49.99'));
      expect(CurrencyFormatter.formatCents(125000), equals('\$1,250.00'));
    });

    test('formats direct amount into dollar strings', () {
      expect(CurrencyFormatter.formatAmount(10.5), equals('\$10.50'));
      expect(CurrencyFormatter.formatAmount(0.0), equals('\$0.00'));
      expect(CurrencyFormatter.formatAmount(9999.99), equals('\$9,999.99'));
    });

    test('formats compact currency representation', () {
      final compact1k = CurrencyFormatter.formatCompact(1500);
      expect(compact1k, contains('1.5K'));

      final compact1m = CurrencyFormatter.formatCompact(2000000);
      expect(compact1m, contains('2M'));
    });
  });

  group('DateFormatter', () {
    final testDate = DateTime(2026, 10, 14, 15, 30);

    test('formatDate outputs formatted calendar day', () {
      expect(DateFormatter.formatDate(testDate), equals('Oct 14, 2026'));
    });

    test('formatMonthYear outputs short month and year', () {
      expect(DateFormatter.formatMonthYear(testDate), equals('Oct 2026'));
    });

    test('formatFull outputs date and time', () {
      final formatted = DateFormatter.formatFull(testDate);
      expect(formatted, contains('Oct 14, 2026'));
      expect(formatted, contains('03:30'));
    });

    test('formatRelative outputs accurate human-readable intervals', () {
      final baseClock = DateTime(2026, 10, 14, 15, 30, 0);

      // Just now (< 60s)
      final justNow = baseClock.subtract(const Duration(seconds: 25));
      expect(DateFormatter.formatRelative(justNow, clock: baseClock), equals('just now'));

      // Minutes ago
      final fiveMinAgo = baseClock.subtract(const Duration(minutes: 5));
      expect(DateFormatter.formatRelative(fiveMinAgo, clock: baseClock), equals('5 minutes ago'));
      final oneMinAgo = baseClock.subtract(const Duration(minutes: 1));
      expect(DateFormatter.formatRelative(oneMinAgo, clock: baseClock), equals('1 minute ago'));

      // Hours ago
      final twoHoursAgo = baseClock.subtract(const Duration(hours: 2));
      expect(DateFormatter.formatRelative(twoHoursAgo, clock: baseClock), equals('2 hours ago'));

      // Yesterday
      final yesterday = baseClock.subtract(const Duration(days: 1));
      expect(DateFormatter.formatRelative(yesterday, clock: baseClock), equals('yesterday'));

      // Days ago
      final fourDaysAgo = baseClock.subtract(const Duration(days: 4));
      expect(DateFormatter.formatRelative(fourDaysAgo, clock: baseClock), equals('4 days ago'));

      // Long ago (> 30 days)
      final fortyDaysAgo = baseClock.subtract(const Duration(days: 40));
      expect(DateFormatter.formatRelative(fortyDaysAgo, clock: baseClock), equals('Sep 04, 2026'));
    });
  });
}
