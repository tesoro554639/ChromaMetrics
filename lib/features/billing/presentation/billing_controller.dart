import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env_config.dart';
import '../../tenant/presentation/tenant_controller.dart';
import '../data/billing_repository.dart';
import '../domain/subscription_plan.dart';
import '../domain/subscription.dart';
import '../domain/invoice.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  if (EnvConfig.isDemoMode) {
    return MockBillingRepository();
  }
  return SupabaseBillingRepository(Supabase.instance.client);
});

final availablePlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  final repo = ref.watch(billingRepositoryProvider);
  return repo.getAvailablePlans();
});

final activeSubscriptionProvider = FutureProvider<TenantSubscription?>((ref) async {
  final activeTenant = ref.watch(activeTenantProvider);
  if (activeTenant == null) return null;
  final repo = ref.watch(billingRepositoryProvider);
  return repo.getActiveSubscription(activeTenant.id);
});

final invoicesListProvider = FutureProvider<List<Invoice>>((ref) async {
  final activeTenant = ref.watch(activeTenantProvider);
  if (activeTenant == null) return [];
  final repo = ref.watch(billingRepositoryProvider);
  return repo.getInvoices(activeTenant.id);
});

class BillingActionsController extends StateNotifier<AsyncValue<void>> {
  final BillingRepository _repository;
  final Ref _ref;

  BillingActionsController(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> upgradePlan(String planId) async {
    final activeTenant = _ref.read(activeTenantProvider);
    if (activeTenant == null) return false;

    state = const AsyncValue.loading();
    try {
      await _repository.upgradePlan(activeTenant.id, planId);
      // Invalidate active subscription and tenant state
      _ref.invalidate(activeSubscriptionProvider);
      _ref.invalidate(tenantControllerProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final billingActionsControllerProvider =
    StateNotifierProvider<BillingActionsController, AsyncValue<void>>((ref) {
  final repo = ref.watch(billingRepositoryProvider);
  return BillingActionsController(repo, ref);
});
