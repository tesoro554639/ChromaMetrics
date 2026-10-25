import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/core/utils/number_formatter.dart';

void main() {
  group('NumberFormatter', () {
    test('formatPercentage formats positive numbers with plus sign by default', () {
      expect(NumberFormatter.formatPercentage(12.5), equals('+12.5%'));
      expect(NumberFormatter.formatPercentage(0.0), equals('0.0%'));
    });

    test('formatPercentage formats negative numbers accurately', () {
      expect(NumberFormatter.formatPercentage(-4.2), equals('-4.2%'));
    });

    test('formatPercentage respects showPlus: false', () {
      expect(NumberFormatter.formatPercentage(8.0, showPlus: false), equals('8.0%'));
    });

    test('formatCompact converts numbers into short units', () {
      expect(NumberFormatter.formatCompact(1500), contains('1.5K'));
      expect(NumberFormatter.formatCompact(3200000), contains('3.2M'));
    });

    test('formatCount formats thousands separators correctly', () {
      expect(NumberFormatter.formatCount(12500), equals('12,500'));
      expect(NumberFormatter.formatCount(0), equals('0'));
    });

    test('formatDataVolume converts bytes into KB, MB, and GB', () {
      expect(NumberFormatter.formatDataVolume(0), equals('0 B'));
      expect(NumberFormatter.formatDataVolume(512), equals('512 B'));
      expect(NumberFormatter.formatDataVolume(1024), equals('1.0 KB'));
      expect(NumberFormatter.formatDataVolume(1048576 * 1.5), equals('1.5 MB'));
      expect(NumberFormatter.formatDataVolume(1073741824 * 5), equals('5.0 GB'));
    });

    test('formatRate formats event counts into appropriate rate strings', () {
      expect(NumberFormatter.formatRate(120, const Duration(seconds: 1)), equals('120.0 req/s'));
      expect(NumberFormatter.formatRate(300, const Duration(seconds: 60)), equals('5.0 req/s'));
      expect(NumberFormatter.formatRate(30, const Duration(minutes: 1)), equals('0.5 req/s'));
      expect(NumberFormatter.formatRate(0, const Duration(seconds: 10)), equals('0.0 req/s'));
      expect(NumberFormatter.formatRate(50, Duration.zero), equals('0.0 req/s'));
    });
  });
}
