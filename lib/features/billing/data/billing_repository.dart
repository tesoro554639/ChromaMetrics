import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/subscription_plan.dart';
import '../domain/subscription.dart';
import '../domain/invoice.dart';

abstract class BillingRepository {
  Future<List<SubscriptionPlan>> getAvailablePlans();
  Future<TenantSubscription?> getActiveSubscription(String tenantId);
  Future<List<Invoice>> getInvoices(String tenantId);
  Future<void> upgradePlan(String tenantId, String newPlanId);
}

class SupabaseBillingRepository implements BillingRepository {
  final SupabaseClient _client;

  SupabaseBillingRepository(this._client);

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    final response = await _client
        .from('subscription_plans')
        .select()
        .eq('active', true)
        .order('amount_in_cents', ascending: true);

    return (response as List).map((row) => SubscriptionPlan.fromJson(row)).toList();
  }

  @override
  Future<TenantSubscription?> getActiveSubscription(String tenantId) async {
    final response = await _client
        .from('subscriptions')
        .select('*, subscription_plans(*)')
        .eq('organization_id', tenantId)
        .maybeSingle();

    if (response == null) return null;
    return TenantSubscription.fromJson(response);
  }

  @override
  Future<List<Invoice>> getInvoices(String tenantId) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('organization_id', tenantId)
        .order('created_at', ascending: false);

    return (response as List).map((row) => Invoice.fromJson(row)).toList();
  }

  @override
  Future<void> upgradePlan(String tenantId, String newPlanId) async {
    // In production, this invokes an edge function calling Stripe Checkout or Subscription Update
    await _client.from('subscriptions').update({
      'plan_id': newPlanId,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('organization_id', tenantId);
  }
}

class MockBillingRepository implements BillingRepository {
  TenantSubscription? _mockSub = TenantSubscription(
    id: 'sub_mock_001',
    organizationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    planId: '22222222-2222-2222-2222-222222222222',
    planName: 'Growth & Pro',
    planAmountCents: 19900,
    interval: 'month',
    status: 'active',
    currentPeriodStart: DateTime.now().subtract(const Duration(days: 15)),
    currentPeriodEnd: DateTime.now().add(const Duration(days: 15)),
  );

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const [
      SubscriptionPlan(
        id: '11111111-1111-1111-1111-111111111111',
        name: 'Starter Plan',
        description: 'Essential billing and analytics for early-stage teams.',
        amountInCents: 4900,
        interval: 'month',
        stripePriceId: 'price_starter_monthly',
        features: [
          'Up to 5 Team Members',
          '100k Monthly API Calls',
          'Standard Support',
          'Basic Analytics',
        ],
        limits: {'team_members': 5, 'api_calls_monthly': 100000},
      ),
      SubscriptionPlan(
        id: '22222222-2222-2222-2222-222222222222',
        name: 'Growth & Pro',
        description: 'Advanced telemetry, priority SLAs, and customized billing.',
        amountInCents: 19900,
        interval: 'month',
        stripePriceId: 'price_pro_monthly',
        isPopular: true,
        features: [
          'Up to 25 Team Members',
          '1M Monthly API Calls',
          'Priority Support',
          'Real-Time Telemetry',
          'Custom PDF Invoices',
        ],
        limits: {'team_members': 25, 'api_calls_monthly': 1000000},
      ),
      SubscriptionPlan(
        id: '33333333-3333-3333-3333-333333333333',
        name: 'Enterprise Suite',
        description: 'Dedicated infrastructure, custom contracts, and unlimited scale.',
        amountInCents: 99900,
        interval: 'month',
        stripePriceId: 'price_enterprise_monthly',
        features: [
          'Unlimited Members',
          '10M Monthly API Calls',
          '24/7 Dedicated Slack Channel',
          'Custom RLS Policies',
          'SOC2 Compliance Export',
        ],
        limits: {'team_members': 999, 'api_calls_monthly': 10000000},
      ),
    ];
  }

  @override
  Future<TenantSubscription?> getActiveSubscription(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockSub;
  }

  @override
  Future<List<Invoice>> getInvoices(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    return [
      Invoice(
        id: 'inv_101',
        organizationId: tenantId,
        invoiceNumber: 'INV-2026-0091',
        amountDueCents: 19900,
        amountPaidCents: 19900,
        status: 'paid',
        paidAt: now.subtract(const Duration(days: 14)),
        lineItems: const [
          InvoiceItem(description: 'Growth & Pro Tier - Monthly Subscription', amountCents: 19900),
        ],
      ),
      Invoice(
        id: 'inv_102',
        organizationId: tenantId,
        invoiceNumber: 'INV-2026-0078',
        amountDueCents: 19900,
        amountPaidCents: 19900,
        status: 'paid',
        paidAt: now.subtract(const Duration(days: 44)),
        lineItems: const [
          InvoiceItem(description: 'Growth & Pro Tier - Monthly Subscription', amountCents: 19900),
        ],
      ),
      Invoice(
        id: 'inv_103',
        organizationId: tenantId,
        invoiceNumber: 'INV-2026-0065',
        amountDueCents: 19900,
        amountPaidCents: 19900,
        status: 'paid',
        paidAt: now.subtract(const Duration(days: 74)),
        lineItems: const [
          InvoiceItem(description: 'Growth & Pro Tier - Monthly Subscription', amountCents: 19900),
        ],
      ),
    ];
  }

  @override
  Future<void> upgradePlan(String tenantId, String newPlanId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final plans = await getAvailablePlans();
    final chosen = plans.firstWhere((p) => p.id == newPlanId);

    _mockSub = TenantSubscription(
      id: 'sub_mock_001',
      organizationId: tenantId,
      planId: chosen.id,
      planName: chosen.name,
      planAmountCents: chosen.amountInCents,
      interval: chosen.interval,
      status: 'active',
      currentPeriodStart: DateTime.now(),
      currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
    );
  }
}
