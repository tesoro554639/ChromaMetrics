import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env_config.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (EnvConfig.isDemoMode) {
    return MockAuthRepository();
  }
  return SupabaseAuthRepository(Supabase.instance.client);
});

class AuthController extends StateNotifier<AppAuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AppAuthState()) {
    _init();
  }

  void _init() {
    final currentUser = _repository.getCurrentUser();
    if (currentUser != null) {
      state = AppAuthState(isAuthenticated: true, user: currentUser);
    } else {
      state = const AppAuthState(isAuthenticated: false);
    }

    _repository.authStateChanges.listen((newState) {
      state = newState;
    });
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signInWithEmailPassword(email, password);
      final user = _repository.getCurrentUser();
      state = AppAuthState(isAuthenticated: true, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
    state = const AppAuthState(isAuthenticated: false);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AppAuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
