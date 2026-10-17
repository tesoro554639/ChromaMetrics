import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/core/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    test('defaults to demo mode in standard testing runtime', () {
      expect(EnvConfig.isDemoMode, isTrue);
    });

    test('placeholder credentials evaluate hasSupabaseCredentials to false', () {
      expect(EnvConfig.hasSupabaseCredentials, isFalse);
    });

    test('isProduction returns false when running with default demo mode', () {
      expect(EnvConfig.isProduction, isFalse);
    });
  });
}
