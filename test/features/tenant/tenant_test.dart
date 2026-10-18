import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/features/tenant/domain/tenant.dart';
import 'package:multi_tenant_saas_billing/features/tenant/domain/membership.dart';

void main() {
  group('Tenant Domain', () {
    test('creates and parses Tenant from JSON accurately', () {
      final json = {
        'id': 'org-123',
        'name': 'Acme Corp',
        'slug': 'acme-corp',
        'stripe_customer_id': 'cus_12345',
        'billing_email': 'billing@acme.com',
        'currency': 'USD',
        'plan_name': 'Scale Enterprise',
      };

      final tenant = Tenant.fromJson(json);

      expect(tenant.id, equals('org-123'));
      expect(tenant.name, equals('Acme Corp'));
      expect(tenant.slug, equals('acme-corp'));
      expect(tenant.stripeCustomerId, equals('cus_12345'));
      expect(tenant.billingEmail, equals('billing@acme.com'));
      expect(tenant.planName, equals('Scale Enterprise'));

      final serialized = tenant.toJson();
      expect(serialized['id'], equals('org-123'));
      expect(serialized['billing_email'], equals('billing@acme.com'));
    });

    test('TenantRole permissions validate properly for billing and member management', () {
      expect(TenantRole.owner.canManageBilling, isTrue);
      expect(TenantRole.admin.canManageBilling, isTrue);
      expect(TenantRole.billingManager.canManageBilling, isTrue);
      expect(TenantRole.member.canManageBilling, isFalse);
      expect(TenantRole.viewer.canManageBilling, isFalse);

      expect(TenantRole.owner.canManageMembers, isTrue);
      expect(TenantRole.admin.canManageMembers, isTrue);
      expect(TenantRole.billingManager.canManageMembers, isFalse);
      expect(TenantRole.member.canManageMembers, isFalse);
    });

    test('TenantMembership parses from string role values', () {
      final membership = TenantMembership.fromJson({
        'id': 'mem-1',
        'organization_id': 'org-123',
        'user_id': 'usr-999',
        'role': 'billing_manager',
      });

      expect(membership.role, equals(TenantRole.billingManager));
      expect(membership.role.canManageBilling, isTrue);
      expect(membership.canManageBilling, isTrue);
      expect(membership.canManageMembers, isFalse);
    });

    test('TenantRole isOwner, isAdminOrAbove, and isReadOnly evaluate accurately', () {
      expect(TenantRole.owner.isOwner, isTrue);
      expect(TenantRole.admin.isOwner, isFalse);
      expect(TenantRole.owner.isAdminOrAbove, isTrue);
      expect(TenantRole.admin.isAdminOrAbove, isTrue);
      expect(TenantRole.member.isAdminOrAbove, isFalse);
      expect(TenantRole.viewer.isReadOnly, isTrue);
      expect(TenantRole.member.isReadOnly, isFalse);
    });
  });
}
