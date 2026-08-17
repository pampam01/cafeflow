import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cafe_model.dart';
import '../../autentikasi/presentation/auth_provider.dart';

class ActiveCafeState {
  final List<CafeModel> availableCafes;
  final CafeModel? activeCafe;
  final bool isLoading;
  final String? error;

  const ActiveCafeState({
    this.availableCafes = const [],
    this.activeCafe,
    this.isLoading = false,
    this.error,
  });

  bool get hasActiveCafe => activeCafe != null;
  bool get needsSelection => availableCafes.length > 1 && activeCafe == null;

  ActiveCafeState copyWith({
    List<CafeModel>? availableCafes,
    CafeModel? activeCafe,
    bool? isLoading,
    String? error,
  }) {
    return ActiveCafeState(
      availableCafes: availableCafes ?? this.availableCafes,
      activeCafe: activeCafe ?? this.activeCafe,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ActiveCafeNotifier extends StateNotifier<ActiveCafeState> {
  final Ref _ref;

  ActiveCafeNotifier(this._ref) : super(const ActiveCafeState());

  Future<void> loadUserCafes(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = _ref.read(authRepositoryProvider);
      final cafes = await repository.fetchUserCafes(userId);

      if (cafes.length == 1) {
        // Otomatis pilih jika pegawai hanya mempunyai 1 kafe
        state = ActiveCafeState(
          availableCafes: cafes,
          activeCafe: cafes.first,
          isLoading: false,
        );
      } else {
        // Lebih dari 1 kafe -> butuh pemilihan di /pilih-kafe
        state = ActiveCafeState(
          availableCafes: cafes,
          activeCafe: null,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectCafe(CafeModel cafe) {
    state = state.copyWith(activeCafe: cafe);
  }

  void clearActiveCafe() {
    state = const ActiveCafeState();
  }
}

final activeCafeProvider = StateNotifierProvider<ActiveCafeNotifier, ActiveCafeState>((ref) {
  return ActiveCafeNotifier(ref);
});
