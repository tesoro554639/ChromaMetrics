import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/features/analytics/domain/saas_metrics.dart';

void main() {
  group('SaasMetrics Domain', () {
    test('computes ARPU, ARR, and LTV correctly from JSON', () {
      final json = {
        'current_mrr_usd': 5000.0,
        'current_arr_usd': 60000.0,
        'active_subscriptions_count': 10,
      };

      final metrics = SaasMetrics.fromJson(json);

      expect(metrics.currentMrr, equals(5000.0));
      expect(metrics.currentArr, equals(60000.0));
      expect(metrics.activeSubscriptions, equals(10));
      expect(metrics.arpu, equals(500.0)); // 5000 / 10
      expect(metrics.churnRatePercent, equals(2.1));
      expect(metrics.ltv, greaterThan(0));
    });

    test('handles zero active subscriptions safely without division by zero', () {
      final json = {
        'current_mrr_usd': 0.0,
        'current_arr_usd': 0.0,
        'active_subscriptions_count': 0,
      };

      final metrics = SaasMetrics.fromJson(json);
      expect(metrics.arpu, equals(0.0));
    });

    test('copyWith updates specified metrics and preserves others', () {
      const initial = SaasMetrics(
        currentMrr: 10000,
        currentArr: 120000,
        churnRatePercent: 2.5,
        arpu: 200,
        ltv: 8000,
        activeSubscriptions: 50,
        mrrGrowthPercent: 15.0,
      );

      expect(initial.hasPositiveGrowth, isTrue);

      final updated = initial.copyWith(
        currentMrr: 12000,
        mrrGrowthPercent: -3.5,
      );

      expect(updated.currentMrr, equals(12000));
      expect(updated.currentArr, equals(120000));
      expect(updated.mrrGrowthPercent, equals(-3.5));
      expect(updated.hasPositiveGrowth, isFalse);
    });

    test('RevenueTrendPoint parses monthly analytics correctly', () {
      final json = {
        'month_period': '2026-09',
        'revenue_usd': 42500.50,
        'invoices_paid_count': 85,
        'churn_count': 2,
      };

      final point = RevenueTrendPoint.fromJson(json);
      expect(point.month, equals('2026-09'));
      expect(point.revenue, equals(42500.50));
      expect(point.invoicesCount, equals(85));
      expect(point.churnCount, equals(2));
    });
  });
}
