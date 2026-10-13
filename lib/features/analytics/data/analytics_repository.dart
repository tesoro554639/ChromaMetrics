import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/saas_metrics.dart';

abstract class AnalyticsRepository {
  Future<SaasMetrics> getMetricsForTenant(String tenantId);
  Future<List<RevenueTrendPoint>> getRevenueTrend(String tenantId);
  Stream<SaasMetrics> subscribeToMetrics(String tenantId);
}

class SupabaseAnalyticsRepository implements AnalyticsRepository {
  final SupabaseClient _client;

  SupabaseAnalyticsRepository(this._client);

  @override
  Future<SaasMetrics> getMetricsForTenant(String tenantId) async {
    final response = await _client
        .from('view_saas_revenue_metrics')
        .select()
        .eq('organization_id', tenantId)
        .maybeSingle();

    if (response == null) {
      return const SaasMetrics(
        currentMrr: 0,
        currentArr: 0,
        churnRatePercent: 0,
        arpu: 0,
        ltv: 0,
        activeSubscriptions: 0,
      );
    }
    return SaasMetrics.fromJson(response);
  }

  @override
  Future<List<RevenueTrendPoint>> getRevenueTrend(String tenantId) async {
    final response = await _client.rpc(
      'get_saas_financial_history',
      params: {'p_organization_id': tenantId},
    );

    return (response as List)
        .map((row) => RevenueTrendPoint.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<SaasMetrics> subscribeToMetrics(String tenantId) {
    return _client
        .from('subscriptions')
        .stream(primaryKey: ['id'])
        .eq('organization_id', tenantId)
        .asyncMap((_) => getMetricsForTenant(tenantId));
  }
}

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<SaasMetrics> getMetricsForTenant(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final bool isEnterprise = tenantId.contains('bbbb');

    return SaasMetrics(
      currentMrr: isEnterprise ? 24500.00 : 8420.00,
      currentArr: isEnterprise ? 294000.00 : 101040.00,
      churnRatePercent: isEnterprise ? 1.4 : 2.8,
      arpu: isEnterprise ? 1250.00 : 210.00,
      ltv: isEnterprise ? 89200.00 : 7500.00,
      activeSubscriptions: isEnterprise ? 24 : 42,
      mrrGrowthPercent: 18.5,
      arrGrowthPercent: 21.2,
    );
  }

  @override
  Future<List<RevenueTrendPoint>> getRevenueTrend(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final bool isEnterprise = tenantId.contains('bbbb');
    final double base = isEnterprise ? 18000.0 : 5000.0;

    return [
      RevenueTrendPoint(month: 'May', revenue: base * 0.72, invoicesCount: 15, churnCount: 1),
      RevenueTrendPoint(month: 'Jun', revenue: base * 0.81, invoicesCount: 19, churnCount: 0),
      RevenueTrendPoint(month: 'Jul', revenue: base * 0.90, invoicesCount: 24, churnCount: 1),
      RevenueTrendPoint(month: 'Aug', revenue: base * 1.05, invoicesCount: 31, churnCount: 2),
      RevenueTrendPoint(month: 'Sep', revenue: base * 1.18, invoicesCount: 38, churnCount: 1),
      RevenueTrendPoint(month: 'Oct', revenue: base * 1.35, invoicesCount: 46, churnCount: 0),
    ];
  }

  @override
  Stream<SaasMetrics> subscribeToMetrics(String tenantId) {
    return Stream.periodic(
      const Duration(seconds: 30),
      (_) => getMetricsForTenant(tenantId),
    ).asyncMap((future) => future);
  }
}
