import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/tenant.dart';
import '../domain/membership.dart';

abstract class TenantRepository {
  Future<List<Tenant>> getUserTenants();
  Future<TenantRole> getRoleInTenant(String tenantId);
  Future<Tenant> createTenant(String name, String slug);
}

class SupabaseTenantRepository implements TenantRepository {
  final SupabaseClient _client;

  SupabaseTenantRepository(this._client);

  @override
  Future<List<Tenant>> getUserTenants() async {
    final response = await _client
        .from('organizations')
        .select('*, subscriptions(subscription_plans(name))');

    return (response as List).map((row) {
      final subs = row['subscriptions'] as List?;
      String planName = 'Free Tier';
      if (subs != null && subs.isNotEmpty) {
        final subMap = subs.first as Map<String, dynamic>?;
        final planMap = subMap?['subscription_plans'] as Map<String, dynamic>?;
        if (planMap != null) {
          planName = planMap['name'] as String? ?? 'Free Tier';
        }
      }
      return Tenant.fromJson({
        ...row,
        'plan_name': planName,
      });
    }).toList();
  }

  @override
  Future<TenantRole> getRoleInTenant(String tenantId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return TenantRole.viewer;

    final response = await _client
        .from('organization_memberships')
        .select('role')
        .eq('organization_id', tenantId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return TenantRole.viewer;
    return TenantRole.fromString(response['role'] as String);
  }

  @override
  Future<Tenant> createTenant(String name, String slug) async {
    final response = await _client
        .from('organizations')
        .insert({
          'name': name,
          'slug': slug,
          'billing_email': _client.auth.currentUser?.email ?? 'billing@domain.com',
        })
        .select()
        .single();

    return Tenant.fromJson(response);
  }
}

class MockTenantRepository implements TenantRepository {
  final List<Tenant> _mockTenants = [
    const Tenant(
      id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      name: 'Acme Global Corp',
      slug: 'acme-global',
      stripeCustomerId: 'cus_acme_live_98124',
      billingEmail: 'billing@acmeglobal.io',
      currency: 'USD',
      planName: 'Growth & Pro',
    ),
    const Tenant(
      id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      name: 'Starlight AI Robotics',
      slug: 'starlight-ai',
      stripeCustomerId: 'cus_starlight_live_45311',
      billingEmail: 'finance@starlight.ai',
      currency: 'USD',
      planName: 'Enterprise Suite',
    ),
  ];

  @override
  Future<List<Tenant>> getUserTenants() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockTenants;
  }

  @override
  Future<TenantRole> getRoleInTenant(String tenantId) async {
    return TenantRole.owner;
  }

  @override
  Future<Tenant> createTenant(String name, String slug) async {
    final newTenant = Tenant(
      id: 'tenant-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      slug: slug,
      billingEmail: 'admin@$slug.io',
      planName: 'Starter Plan',
    );
    _mockTenants.add(newTenant);
    return newTenant;
  }
}
