import 'package:flutter_test/flutter_test.dart';
import 'package:multi_tenant_saas_billing/features/auth/domain/auth_state.dart';

void main() {
  group('AppAuthState & AppUser Domain', () {
    test('AppUser computes displayName and initials correctly', () {
      const userWithFull = AppUser(
        id: 'usr_1',
        email: 'alex.chen@acme.com',
        fullName: 'Alex Chen',
      );
      expect(userWithFull.displayName, equals('Alex Chen'));
      expect(userWithFull.initials, equals('A'));

      const userEmailOnly = AppUser(
        id: 'usr_2',
        email: 'sarah@startup.io',
      );
      expect(userEmailOnly.displayName, equals('sarah@startup.io'));
      expect(userEmailOnly.initials, equals('S'));
    });

    test('AppAuthState hasError reports presence of error string', () {
      const stateOk = AppAuthState(isAuthenticated: true);
      expect(stateOk.hasError, isFalse);

      const stateErr = AppAuthState(errorMessage: 'Invalid credentials provided');
      expect(stateErr.hasError, isTrue);
    });
  });
}
