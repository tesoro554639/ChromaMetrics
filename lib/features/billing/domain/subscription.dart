import '../../../../core/widgets/status_badge.dart';

class TenantSubscription {
  final String id;
  final String organizationId;
  final String planId;
  final String planName;
  final int planAmountCents;
  final String interval;
  final String status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;

  const TenantSubscription({
    required this.id,
    required this.organizationId,
    required this.planId,
    required this.planName,
    required this.planAmountCents,
    required this.interval,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isTrialing => status.toLowerCase() == 'trialing';

  /// Returns the number of full days remaining in the current billing period.
  int daysRemaining({DateTime? clock}) {
    final now = clock ?? DateTime.now();
    final difference = currentPeriodEnd.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  BadgeStatus get badgeStatus {
    switch (status.toLowerCase()) {
      case 'active':
        return BadgeStatus.active;
      case 'trialing':
        return BadgeStatus.trialing;
      case 'past_due':
        return BadgeStatus.pastDue;
      case 'canceled':
      default:
        return BadgeStatus.canceled;
    }
  }

  factory TenantSubscription.fromJson(Map<String, dynamic> json) {
    final plan = json['subscription_plans'] as Map<String, dynamic>?;
    return TenantSubscription(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      planId: json['plan_id'] as String,
      planName: plan?['name'] as String? ?? 'Custom Plan',
      planAmountCents: plan?['amount_in_cents'] as int? ?? 0,
      interval: plan?['interval'] as String? ?? 'month',
      status: json['status'] as String? ?? 'active',
      currentPeriodStart: DateTime.tryParse(json['current_period_start'] as String? ?? '') ?? DateTime.now(),
      currentPeriodEnd: DateTime.tryParse(json['current_period_end'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
    );
  }
}
