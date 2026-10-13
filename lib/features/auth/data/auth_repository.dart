import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_state.dart';

abstract class AuthRepository {
  Stream<AppAuthState> get authStateChanges;
  Future<void> signInWithEmailPassword(String email, String password);
  Future<void> signOut();
  AppUser? getCurrentUser();
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Stream<AppAuthState> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final session = data.session;
      if (session == null) {
        return const AppAuthState(isAuthenticated: false);
      }
      return AppAuthState(
        isAuthenticated: true,
        user: AppUser(
          id: session.user.id,
          email: session.user.email ?? '',
          fullName: session.user.userMetadata?['full_name'] as String?,
          avatarUrl: session.user.userMetadata?['avatar_url'] as String?,
        ),
      );
    });
  }

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  AppUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }
}

class MockAuthRepository implements AuthRepository {
  AppAuthState _current = const AppAuthState(
    isAuthenticated: true,
    user: AppUser(
      id: 'usr_demo_founder_99',
      email: 'alex.chen@acmeglobal.io',
      fullName: 'Alex Chen (Founder & CEO)',
      avatarUrl: null,
    ),
  );

  @override
  Stream<AppAuthState> get authStateChanges => Stream.value(_current);

  @override
  Future<void> signInWithEmailPassword(String email, String password) async {
    _current = AppAuthState(
      isAuthenticated: true,
      user: AppUser(
        id: 'usr_demo_founder_99',
        email: email,
        fullName: 'Alex Chen (Founder & CEO)',
      ),
    );
  }

  @override
  Future<void> signOut() async {
    _current = const AppAuthState(isAuthenticated: false);
  }

  @override
  AppUser? getCurrentUser() => _current.user;
}
