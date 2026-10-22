import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/features/usage_grid/domain/customer_usage.dart';

void main() {
  group('CustomerUsage Domain', () {
    final now = DateTime(2026, 10, 18, 14, 0);

    test('parses accurately from JSON with default fallback values', () {
      final json = {
        'user_id': 'usr_1',
        'user_email': 'dev@acme.com',
        'meter_key': 'meter_api_calls',
        'meter_name': 'API Gateway',
        'total_quantity': 4500,
        'unit': 'requests',
      };

      final usage = CustomerUsage.fromJson(json);
      expect(usage.userId, equals('usr_1'));
      expect(usage.userName, equals('Team Member'));
      expect(usage.totalQuantity, equals(4500.0));
      expect(usage.status, equals('ACTIVE'));
      expect(usage.isActive, isTrue);
    });

    test('copyWith updates specified fields while preserving existing values', () {
      final original = CustomerUsage(
        userId: 'usr_1',
        userEmail: 'dev@acme.com',
        userName: 'Alex',
        meterKey: 'meter_api_calls',
        meterName: 'API Gateway',
        totalQuantity: 1000,
        unit: 'requests',
        lastActivity: now,
        status: 'ACTIVE',
      );

      final updated = original.copyWith(
        totalQuantity: 1500,
        status: 'INACTIVE',
      );

      expect(updated.userId, equals('usr_1'));
      expect(updated.userName, equals('Alex'));
      expect(updated.totalQuantity, equals(1500.0));
      expect(updated.status, equals('INACTIVE'));
      expect(updated.isActive, isFalse);
    });

    test('formattedQuantity returns readable quantity with unit string', () {
      final wholeUsage = CustomerUsage(
        userId: 'usr_2',
        userEmail: 'ops@acme.com',
        userName: 'Sam',
        meterKey: 'meter_api_calls',
        meterName: 'API Gateway',
        totalQuantity: 2500,
        unit: 'requests',
        lastActivity: now,
      );
      expect(wholeUsage.formattedQuantity, equals('2500 requests'));

      final decimalUsage = CustomerUsage(
        userId: 'usr_3',
        userEmail: 'storage@acme.com',
        userName: 'Sam',
        meterKey: 'meter_storage_gb',
        meterName: 'Blob Storage',
        totalQuantity: 42.5,
        unit: 'GB',
        lastActivity: now,
      );
      expect(decimalUsage.formattedQuantity, equals('42.5 GB'));
    });
  });
}
