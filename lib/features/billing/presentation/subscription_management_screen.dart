import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../tenant/presentation/tenant_controller.dart';
import 'billing_controller.dart';
import 'plan_tier_card.dart';

class SubscriptionManagementScreen extends ConsumerWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTenant = ref.watch(activeTenantProvider);
    final currentSubAsync = ref.watch(activeSubscriptionProvider);
    final plansAsync = ref.watch(availablePlansProvider);
    final actionState = ref.watch(billingActionsControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Subscription & Tier Management',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage customer billing plans, usage allowances, and Stripe synchronization for ${activeTenant?.name ?? "tenant"}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Current Subscription Banner Card
          currentSubAsync.when(
            data: (sub) {
              if (sub == null) return const SizedBox.shrink();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.star, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  sub.planName,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                StatusBadge(status: sub.badgeStatus),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Billed at ${CurrencyFormatter.formatCents(sub.planAmountCents)} per ${sub.interval}. Current billing period ends on ${DateFormatter.formatDate(sub.currentPeriodEnd)}.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Stripe Customer Billing Portal session initiated.'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Manage in Stripe'),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading subscription: $err'),
          ),

          const SizedBox(height: 32),

          Text(
            'Available Subscription Tiers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrade or downgrade your active plan. Changes take effect on next billing cycle.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Plans Grid
          plansAsync.when(
            data: (plans) {
              final activeSub = currentSubAsync.asData?.value;
              final isUpgrading = actionState.isLoading;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final int cols = constraints.maxWidth > 1000
                      ? 3
                      : constraints.maxWidth > 650
                          ? 2
                          : 1;

                  return GridView.builder(
                    itemCount: plans.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.76,
                    ),
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final isCurrent = activeSub != null &&
                          (activeSub.planId == plan.id || activeSub.planName == plan.name);

                      return PlanTierCard(
                        plan: plan,
                        isCurrent: isCurrent,
                        isUpgradeLoading: isUpgrading,
                        onSelectPlan: () async {
                          final success = await ref
                              .read(billingActionsControllerProvider.notifier)
                              .upgradePlan(plan.id);

                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Successfully upgraded to ${plan.name}!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading plans: $err'),
          ),
        ],
      ),
    );
  }
}
