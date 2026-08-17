import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/meja_repository.dart';
import '../domain/meja_model.dart';
import '../../kafe/presentation/active_cafe_provider.dart';

final mejaRepositoryProvider = Provider<MejaRepository>((ref) {
  return MejaRepository();
});

class MejaListNotifier extends StateNotifier<AsyncValue<List<MejaModel>>> {
  final MejaRepository _repository;
  final Ref _ref;

  MejaListNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadMeja();
  }

  Future<void> loadMeja() async {
    final activeCafeState = _ref.read(activeCafeProvider);
    final idKafe = activeCafeState.activeCafe?.idKafe;

    if (idKafe == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final mejaList = await _repository.fetchMejaList(idKafe);
      state = AsyncValue.data(mejaList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> tambahMeja({
    required String nomorMeja,
    String? namaMeja,
    required int kapasitas,
    int urutanTampilan = 0,
  }) async {
    final idKafe = _ref.read(activeCafeProvider).activeCafe?.idKafe;
    if (idKafe == null) return false;

    try {
      final newMeja = await _repository.tambahMeja(
        idKafe: idKafe,
        nomorMeja: nomorMeja,
        namaMeja: namaMeja,
        kapasitas: kapasitas,
        urutanTampilan: urutanTampilan,
      );

      final current = state.value ?? [];
      state = AsyncValue.data([...current, newMeja]..sort((a, b) => a.urutanTampilan.compareTo(b.urutanTampilan)));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMeja(MejaModel meja) async {
    try {
      final updated = await _repository.updateMeja(meja);
      final current = state.value ?? [];
      final index = current.indexWhere((m) => m.idMeja == meja.idMeja);
      if (index != -1) {
        current[index] = updated;
        state = AsyncValue.data([...current]..sort((a, b) => a.urutanTampilan.compareTo(b.urutanTampilan)));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleStatusAktif(String idMeja, bool statusAktif) async {
    final idKafe = _ref.read(activeCafeProvider).activeCafe?.idKafe;
    if (idKafe == null) return false;

    try {
      await _repository.toggleStatusAktif(idMeja, idKafe, statusAktif);
      await loadMeja();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> regenerateQr(String idMeja, String nomorMeja) async {
    final idKafe = _ref.read(activeCafeProvider).activeCafe?.idKafe;
    if (idKafe == null) return null;

    try {
      final newToken = await _repository.regenerateKodeQr(idMeja, idKafe, nomorMeja);
      await loadMeja();
      return newToken;
    } catch (e) {
      return null;
    }
  }
}

final mejaListProvider = StateNotifierProvider<MejaListNotifier, AsyncValue<List<MejaModel>>>((ref) {
  final repo = ref.watch(mejaRepositoryProvider);
  return MejaListNotifier(repo, ref);
});
