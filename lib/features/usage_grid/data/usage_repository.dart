import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/customer_usage.dart';

abstract class UsageRepository {
  Future<List<CustomerUsage>> getUsageSummary(
    String tenantId, {
    DateTime? from,
    DateTime? to,
  });
}

class SupabaseUsageRepository implements UsageRepository {
  final SupabaseClient _client;

  SupabaseUsageRepository(this._client);

  @override
  Future<List<CustomerUsage>> getUsageSummary(
    String tenantId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final fromDate = from ?? DateTime.now().subtract(const Duration(days: 30));
    final toDate = to ?? DateTime.now();

    final response = await _client.rpc(
      'get_tenant_usage_summary',
      params: {
        'p_organization_id': tenantId,
        'p_from': fromDate.toIso8601String(),
        'p_to': toDate.toIso8601String(),
      },
    );

    return (response as List)
        .map((row) => CustomerUsage.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}

class MockUsageRepository implements UsageRepository {
  @override
  Future<List<CustomerUsage>> getUsageSummary(
    String tenantId, {
    DateTime? from,
    DateTime? to,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();

    return [
      CustomerUsage(
        userId: 'usr_001',
        userEmail: 'dev.lead@tenant.io',
        userName: 'Sarah Connor',
        meterKey: 'api_calls',
        meterName: 'API Requests Metered',
        totalQuantity: 284520,
        unit: 'Requests',
        lastActivity: now.subtract(const Duration(minutes: 12)),
        status: 'ACTIVE',
      ),
      CustomerUsage(
        userId: 'usr_002',
        userEmail: 'data.eng@tenant.io',
        userName: 'Marcus Wright',
        meterKey: 'storage_gb',
        meterName: 'Storage Retained',
        totalQuantity: 84.5,
        unit: 'GB',
        lastActivity: now.subtract(const Duration(hours: 1)),
        status: 'ACTIVE',
      ),
      CustomerUsage(
        userId: 'usr_003',
        userEmail: 'ml.ops@tenant.io',
        userName: 'Kyle Reese',
        meterKey: 'compute_hours',
        meterName: 'Serverless Compute Units',
        totalQuantity: 412.0,
        unit: 'Compute Hours',
        lastActivity: now.subtract(const Duration(hours: 3)),
        status: 'ACTIVE',
      ),
      CustomerUsage(
        userId: 'usr_004',
        userEmail: 'product@tenant.io',
        userName: 'John Connor',
        meterKey: 'active_seats',
        meterName: 'Active Member Seats',
        totalQuantity: 18,
        unit: 'Seats',
        lastActivity: now.subtract(const Duration(minutes: 45)),
        status: 'ACTIVE',
      ),
      CustomerUsage(
        userId: 'usr_005',
        userEmail: 'qa.lead@tenant.io',
        userName: 'Grace Harper',
        meterKey: 'api_calls',
        meterName: 'API Requests Metered',
        totalQuantity: 98120,
        unit: 'Requests',
        lastActivity: now.subtract(const Duration(hours: 5)),
        status: 'ACTIVE',
      ),
      CustomerUsage(
        userId: 'usr_006',
        userEmail: 'security@tenant.io',
        userName: 'Miles Dyson',
        meterKey: 'api_calls',
        meterName: 'API Requests Metered',
        totalQuantity: 14200,
        unit: 'Requests',
        lastActivity: now.subtract(const Duration(days: 1)),
        status: 'INACTIVE',
      ),
    ];
  }
}
