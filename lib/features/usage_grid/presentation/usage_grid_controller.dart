import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env_config.dart';
import '../../tenant/presentation/tenant_controller.dart';
import '../data/usage_repository.dart';
import '../domain/customer_usage.dart';

final usageRepositoryProvider = Provider<UsageRepository>((ref) {
  if (EnvConfig.isDemoMode) {
    return MockUsageRepository();
  }
  return SupabaseUsageRepository(Supabase.instance.client);
});

final customerUsageListProvider = FutureProvider<List<CustomerUsage>>((ref) async {
  final activeTenant = ref.watch(activeTenantProvider);
  if (activeTenant == null) return [];
  final repo = ref.watch(usageRepositoryProvider);
  return repo.getUsageSummary(activeTenant.id);
});
