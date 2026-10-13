import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env_config.dart';
import '../data/tenant_repository.dart';
import '../domain/tenant.dart';
import '../domain/membership.dart';

final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  if (EnvConfig.isDemoMode) {
    return MockTenantRepository();
  }
  return SupabaseTenantRepository(Supabase.instance.client);
});

class TenantState {
  final List<Tenant> availableTenants;
  final Tenant? activeTenant;
  final TenantRole activeRole;
  final bool isLoading;
  final String? errorMessage;

  const TenantState({
    this.availableTenants = const [],
    this.activeTenant,
    this.activeRole = TenantRole.owner,
    this.isLoading = false,
    this.errorMessage,
  });

  TenantState copyWith({
    List<Tenant>? availableTenants,
    Tenant? activeTenant,
    TenantRole? activeRole,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TenantState(
      availableTenants: availableTenants ?? this.availableTenants,
      activeTenant: activeTenant ?? this.activeTenant,
      activeRole: activeRole ?? this.activeRole,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TenantController extends StateNotifier<TenantState> {
  final TenantRepository _repository;

  TenantController(this._repository) : super(const TenantState()) {
    loadTenants();
  }

  Future<void> loadTenants() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tenants = await _repository.getUserTenants();
      Tenant? selected = state.activeTenant;

      if (tenants.isNotEmpty) {
        // If current activeTenant is not in list or null, pick first
        if (selected == null || !tenants.any((t) => t.id == selected?.id)) {
          selected = tenants.first;
        }
      }

      TenantRole role = TenantRole.viewer;
      if (selected != null) {
        role = await _repository.getRoleInTenant(selected.id);
      }

      state = state.copyWith(
        availableTenants: tenants,
        activeTenant: selected,
        activeRole: role,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectTenant(Tenant tenant) async {
    state = state.copyWith(isLoading: true);
    final role = await _repository.getRoleInTenant(tenant.id);
    state = state.copyWith(
      activeTenant: tenant,
      activeRole: role,
      isLoading: false,
    );
  }
}

final tenantControllerProvider =
    StateNotifierProvider<TenantController, TenantState>((ref) {
  final repo = ref.watch(tenantRepositoryProvider);
  return TenantController(repo);
});

final activeTenantProvider = Provider<Tenant?>((ref) {
  return ref.watch(tenantControllerProvider).activeTenant;
});
