import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/core/widgets/status_badge.dart';
import 'package:multi_tenant_saas_billing/features/billing/domain/subscription.dart';

void main() {
  group('TenantSubscription', () {
    final now = DateTime(2026, 10, 18, 12, 0);

    test('isActive and isTrialing report boolean state correctly', () {
      final activeSub = TenantSubscription(
        id: 'sub_1',
        organizationId: 'org_1',
        planId: 'pro',
        planName: 'Pro Tier',
        planAmountCents: 9900,
        interval: 'month',
        status: 'active',
        currentPeriodStart: now,
        currentPeriodEnd: now.add(const Duration(days: 30)),
      );
      expect(activeSub.isActive, isTrue);
      expect(activeSub.isTrialing, isFalse);
      expect(activeSub.badgeStatus, equals(BadgeStatus.active));

      final trialSub = TenantSubscription(
        id: 'sub_2',
        organizationId: 'org_1',
        planId: 'starter',
        planName: 'Starter Tier',
        planAmountCents: 2900,
        interval: 'month',
        status: 'trialing',
        currentPeriodStart: now,
        currentPeriodEnd: now.add(const Duration(days: 14)),
      );
      expect(trialSub.isActive, isFalse);
      expect(trialSub.isTrialing, isTrue);
      expect(trialSub.isTrialExpired(clock: now), isFalse);
      expect(trialSub.isTrialExpired(clock: now.add(const Duration(days: 15))), isTrue);
      expect(trialSub.badgeStatus, equals(BadgeStatus.trialing));
    });

    test('daysRemaining calculates days left until currentPeriodEnd', () {
      final sub = TenantSubscription(
        id: 'sub_3',
        organizationId: 'org_1',
        planId: 'pro',
        planName: 'Pro Tier',
        planAmountCents: 9900,
        interval: 'month',
        status: 'active',
        currentPeriodStart: now,
        currentPeriodEnd: now.add(const Duration(days: 12)),
      );
      expect(sub.daysRemaining(clock: now), equals(12));

      // Expired subscription returns 0
      final expiredSub = TenantSubscription(
        id: 'sub_4',
        organizationId: 'org_1',
        planId: 'pro',
        planName: 'Pro Tier',
        planAmountCents: 9900,
        interval: 'month',
        status: 'active',
        currentPeriodStart: now.subtract(const Duration(days: 40)),
        currentPeriodEnd: now.subtract(const Duration(days: 10)),
      );
      expect(expiredSub.daysRemaining(clock: now), equals(0));
    });

    test('isPastDue, isCanceled, and gracePeriodDaysRemaining evaluate accurately', () {
      final pastDueSub = TenantSubscription(
        id: 'sub_5',
        organizationId: 'org_1',
        planId: 'pro',
        planName: 'Pro Tier',
        planAmountCents: 9900,
        interval: 'month',
        status: 'past_due',
        currentPeriodStart: now.subtract(const Duration(days: 32)),
        currentPeriodEnd: now.subtract(const Duration(days: 2)), // ended 2 days ago
      );
      expect(pastDueSub.isPastDue, isTrue);
      expect(pastDueSub.isCanceled, isFalse);
      expect(pastDueSub.badgeStatus, equals(BadgeStatus.pastDue));
      // 7 days grace - 2 days elapsed = 5 days left
      expect(pastDueSub.gracePeriodDaysRemaining(clock: now), equals(5));

      final canceledSub = TenantSubscription(
        id: 'sub_6',
        organizationId: 'org_1',
        planId: 'pro',
        planName: 'Pro Tier',
        planAmountCents: 9900,
        interval: 'month',
        status: 'canceled',
        currentPeriodStart: now.subtract(const Duration(days: 60)),
        currentPeriodEnd: now.subtract(const Duration(days: 30)),
      );
      expect(canceledSub.isCanceled, isTrue);
      expect(canceledSub.isPastDue, isFalse);
      expect(canceledSub.gracePeriodDaysRemaining(clock: now), equals(0));
    });
  });
}
