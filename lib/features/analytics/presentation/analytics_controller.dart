import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env_config.dart';
import '../../tenant/presentation/tenant_controller.dart';
import '../data/analytics_repository.dart';
import '../domain/saas_metrics.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  if (EnvConfig.isDemoMode) {
    return MockAnalyticsRepository();
  }
  return SupabaseAnalyticsRepository(Supabase.instance.client);
});

// AsyncValue provider for tenant SaaS metrics
final saasMetricsProvider = FutureProvider<SaasMetrics>((ref) async {
  final activeTenant = ref.watch(activeTenantProvider);
  if (activeTenant == null) {
    return const SaasMetrics(
      currentMrr: 0,
      currentArr: 0,
      churnRatePercent: 0,
      arpu: 0,
      ltv: 0,
      activeSubscriptions: 0,
    );
  }
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getMetricsForTenant(activeTenant.id);
});

// AsyncValue provider for 6-month financial history (FL Chart)
final revenueTrendProvider = FutureProvider<List<RevenueTrendPoint>>((ref) async {
  final activeTenant = ref.watch(activeTenantProvider);
  if (activeTenant == null) return [];
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getRevenueTrend(activeTenant.id);
});
