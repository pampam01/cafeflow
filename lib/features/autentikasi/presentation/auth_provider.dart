import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart';
import 'user_profile_provider.dart';
import '../../kafe/presentation/active_cafe_provider.dart';
import '../../../core/config/supabase_config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState()) {
    _init();
  }

  void _init() {
    try {
      final currentUser = _repository.currentUser;
      if (currentUser != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: currentUser,
        );
        // Load user profile & cafe automatically
        _ref.read(userProfileProvider.notifier).loadProfile(currentUser.id);
        _ref.read(activeCafeProvider.notifier).loadUserCafes(currentUser.id);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }

    // Listen to Supabase auth state changes (session persistence on browser refresh)
    try {
      SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: session.user,
          );
          _ref.read(userProfileProvider.notifier).loadProfile(session.user.id);
          _ref.read(activeCafeProvider.notifier).loadUserCafes(session.user.id);
        } else {
          _clearLocalStates();
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      });
    } catch (_) {}
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _repository.signInWithEmail(email: email, password: password);
      if (response.user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        await _ref.read(userProfileProvider.notifier).loadProfile(response.user!.id);
        await _ref.read(activeCafeProvider.notifier).loadUserCafes(response.user!.id);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Gagal melakukan otentikasi. Sesi pengguna tidak ditemukan.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _repository.signOut();
    _clearLocalStates();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void _clearLocalStates() {
    _ref.read(userProfileProvider.notifier).clearProfile();
    _ref.read(activeCafeProvider.notifier).clearActiveCafe();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});
