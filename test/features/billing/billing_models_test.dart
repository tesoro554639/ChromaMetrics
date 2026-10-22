import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/core/widgets/status_badge.dart';
import 'package:multi_tenant_saas_billing/features/billing/domain/subscription_plan.dart';
import 'package:multi_tenant_saas_billing/features/billing/domain/invoice.dart';

void main() {
  group('Billing Models', () {
    test('SubscriptionPlan parses JSON and determines popular flag', () {
      final jsonPro = {
        'id': 'plan_pro_1',
        'name': 'Pro Tier',
        'description': 'For scaling startups',
        'amount_in_cents': 9900,
        'interval': 'month',
        'features': ['100,000 API calls', '10 Team seats', 'Priority SLA'],
        'limits': {'seats': 10, 'api_calls': 100000},
        'stripe_price_id': 'price_pro_month',
      };

      final planPro = SubscriptionPlan.fromJson(jsonPro);
      expect(planPro.name, equals('Pro Tier'));
      expect(planPro.amountInCents, equals(9900));
      expect(planPro.interval, equals('month'));
      expect(planPro.features.length, equals(3));
      expect(planPro.isPopular, isTrue);

      final jsonStarter = {
        'id': 'plan_starter_1',
        'name': 'Starter Tier',
        'description': 'For small businesses',
        'amount_in_cents': 2900,
        'interval': 'month',
        'features': ['10,000 API calls'],
        'limits': {'seats': 2},
        'stripe_price_id': 'price_starter_month',
      };

      final planStarter = SubscriptionPlan.fromJson(jsonStarter);
      expect(planStarter.isPopular, isFalse);
      expect(planStarter.amountInDollars, equals(29.0));
      expect(planStarter.isMonthly, isTrue);
      expect(planStarter.isAnnual, isFalse);
      expect(planStarter.seatLimit, equals(2));
    });

    test('SubscriptionPlan calculates annualSavingsPercent correctly', () {
      const annualPlan = SubscriptionPlan(
        id: 'plan_pro_annual',
        name: 'Pro Tier (Annual)',
        description: 'Billed annually',
        amountInCents: 96000,
        interval: 'year',
        features: ['All Pro features'],
        limits: {'seats': 10},
        stripePriceId: 'price_annual_1',
      );
      expect(annualPlan.annualSavingsPercent(10000), equals(20));

      const monthlyPlan = SubscriptionPlan(
        id: 'plan_pro_month',
        name: 'Pro Tier',
        description: 'Billed monthly',
        amountInCents: 10000,
        interval: 'month',
        features: [],
        limits: {},
        stripePriceId: 'price_month_1',
      );
      expect(monthlyPlan.annualSavingsPercent(10000), equals(0));
      expect(annualPlan.annualSavingsPercent(0), equals(0));
      expect(annualPlan.annualSavingsPercent(-500), equals(0));
    });

    test('Invoice status maps to expected BadgeStatus', () {
      final invoicePaid = Invoice(
        id: 'inv_1',
        organizationId: 'org_1',
        invoiceNumber: 'INV-2026-001',
        amountDueCents: 9900,
        amountPaidCents: 9900,
        status: 'paid',
        paidAt: DateTime.now(),
      );
      expect(invoicePaid.badgeStatus, equals(BadgeStatus.paid));

      const invoiceOpen = Invoice(
        id: 'inv_2',
        organizationId: 'org_1',
        invoiceNumber: 'INV-2026-002',
        amountDueCents: 9900,
        amountPaidCents: 0,
        status: 'open',
      );
      expect(invoiceOpen.badgeStatus, equals(BadgeStatus.trialing));

      const invoiceVoid = Invoice(
        id: 'inv_3',
        organizationId: 'org_1',
        invoiceNumber: 'INV-2026-003',
        amountDueCents: 9900,
        amountPaidCents: 0,
        status: 'void',
      );
      expect(invoiceVoid.badgeStatus, equals(BadgeStatus.canceled));
    });

    test('Invoice isPaid, isOpen, and isVoid helpers evaluate correctly', () {
      const invoicePaid = Invoice(
        id: 'inv_1',
        organizationId: 'org_1',
        invoiceNumber: 'INV-2026-001',
        amountDueCents: 9900,
        amountPaidCents: 9900,
        status: 'PAID',
      );
      expect(invoicePaid.isPaid, isTrue);
      expect(invoicePaid.isOpen, isFalse);
      expect(invoicePaid.isVoid, isFalse);

      const invoiceOpen = Invoice(
        id: 'inv_2',
        organizationId: 'org_1',
        invoiceNumber: 'INV-2026-002',
        amountDueCents: 9900,
        amountPaidCents: 0,
        status: 'open',
      );
      expect(invoiceOpen.isPaid, isFalse);
      expect(invoiceOpen.isOpen, isTrue);
      expect(invoiceOpen.isVoid, isFalse);

      const invoiceVoid = Invoice(
        id: 'inv_3',
        organizationId: 'org_1',
        invoiceNumber: 'INV-2026-003',
        amountDueCents: 9900,
        amountPaidCents: 0,
        status: 'uncollectible',
      );
      expect(invoiceVoid.isPaid, isFalse);
      expect(invoiceVoid.isOpen, isFalse);
      expect(invoiceVoid.isVoid, isTrue);
    });
  });
}
