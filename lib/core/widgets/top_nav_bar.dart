import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/tenant/domain/tenant.dart';
import '../../features/tenant/presentation/tenant_controller.dart';
import '../router/app_routes.dart';
import '../theme/app_colors.dart';

class TopNavBar extends ConsumerWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantState = ref.watch(tenantControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final activeTenant = tenantState.activeTenant;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tenant Selector Dropdown
          Row(
            children: [
              const Icon(Icons.business_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              if (tenantState.availableTenants.isNotEmpty && activeTenant != null)
                DropdownButtonHideUnderline(
                  child: DropdownButton<Tenant>(
                    value: activeTenant,
                    dropdownColor: AppColors.surfaceElevated,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 18),
                    items: tenantState.availableTenants.map((Tenant tenant) {
                      return DropdownMenuItem<Tenant>(
                        value: tenant,
                        child: Row(
                          children: [
                            Text(tenant.name),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tenant.planName ?? 'Active',
                                style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Tenant? newTenant) {
                      if (newTenant != null) {
                        ref.read(tenantControllerProvider.notifier).selectTenant(newTenant);
                      }
                    },
                  ),
                )
              else
                const Text('Loading Tenants...', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(width: 12),
              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Text(
                  tenantState.activeRole.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          // User Menu & Sign Out
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  authState.user?.fullName?.substring(0, 1) ?? 'A',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authState.user?.fullName ?? 'Alex Chen',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  Text(
                    authState.user?.email ?? 'alex@acmeglobal.io',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.logout, size: 18, color: AppColors.textSecondary),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
