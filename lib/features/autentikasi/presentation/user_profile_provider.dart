import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart';
import 'auth_provider.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> loadProfile(String userId) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(authRepositoryProvider);
      final profile = await repository.fetchUserProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearProfile() {
    state = const AsyncValue.data(null);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier(ref);
});
