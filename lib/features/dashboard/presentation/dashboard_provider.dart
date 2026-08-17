import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../meja/domain/meja_model.dart';
import '../../meja/data/meja_repository.dart';
import '../../meja/presentation/meja_provider.dart';
import '../../sesi_meja/domain/sesi_meja_model.dart';
import '../../kafe/presentation/active_cafe_provider.dart';

class DashboardState {
  final List<MejaModel> mejaList;
  final Map<String, SesiMejaModel> activeSessionsByMejaId;
  final DateTime currentTime;
  final bool isLoading;

  DashboardState({
    this.mejaList = const [],
    this.activeSessionsByMejaId = const {},
    DateTime? currentTime,
    this.isLoading = false,
  }) : currentTime = currentTime ?? DateTime.now();

  int get totalMejaAktif => mejaList.where((m) => m.statusAktif).length;

  int get mejaTerisi {
    return mejaList.where((m) {
      if (!m.statusAktif) return false;
      final sesi = activeSessionsByMejaId[m.idMeja];
      return sesi != null || m.statusMeja == 'terisi';
    }).length;
  }

  int get mejaTersedia {
    final sisa = totalMejaAktif - mejaTerisi;
    return sisa < 0 ? 0 : sisa;
  }

  double get persentaseOkupansi {
    if (totalMejaAktif == 0) return 0.0;
    return (mejaTerisi / totalMejaAktif) * 100;
  }

  DashboardState copyWith({
    List<MejaModel>? mejaList,
    Map<String, SesiMejaModel>? activeSessionsByMejaId,
    DateTime? currentTime,
    bool? isLoading,
  }) {
    return DashboardState(
      mejaList: mejaList ?? this.mejaList,
      activeSessionsByMejaId: activeSessionsByMejaId ?? this.activeSessionsByMejaId,
      currentTime: currentTime ?? this.currentTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final MejaRepository _repository;
  final Ref _ref;
  Timer? _timer;
  StreamSubscription? _mejaSubscription;
  StreamSubscription? _sesiSubscription;

  DashboardNotifier(this._repository, this._ref) : super(DashboardState(isLoading: true)) {
    // Mendengarkan perubahan kafe aktif (termasuk saat awal login/pilih kafe)
    _ref.listen<ActiveCafeState>(activeCafeProvider, (_, next) {
      if (next.activeCafe != null) {
        refreshData(next.activeCafe!.idKafe);
        _setupRealtimeSubscriptions(next.activeCafe!.idKafe);
      }
    }, fireImmediately: true);

    // Local ticker updating currentTime every 1 second (no DB hits)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(currentTime: DateTime.now());
    });
  }

  Future<void> refreshData([String? idKafeOverride]) async {
    final idKafe = idKafeOverride ?? _ref.read(activeCafeProvider).activeCafe?.idKafe;
    if (idKafe == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final mejaList = await _repository.fetchMejaList(idKafe);
      final sesiList = await _repository.fetchActiveSessions(idKafe);

      final sessionsMap = <String, SesiMejaModel>{};
      for (final sesi in sesiList) {
        sessionsMap[sesi.idMeja] = sesi;
      }

      state = state.copyWith(
        mejaList: mejaList,
        activeSessionsByMejaId: sessionsMap,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error refreshData Dashboard: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void _setupRealtimeSubscriptions(String idKafe) {
    _mejaSubscription?.cancel();
    _sesiSubscription?.cancel();

    _mejaSubscription = _repository.streamMeja(idKafe).listen((data) async {
      if (data.isNotEmpty) {
        final updatedList = data.map((j) => MejaModel.fromJson(j)).toList();
        state = state.copyWith(
          mejaList: updatedList..sort((a, b) => a.urutanTampilan.compareTo(b.urutanTampilan)),
        );
      } else {
        await refreshData(idKafe);
      }
    }, onError: (e) {
      debugPrint('Realtime streamMeja error: $e');
    });

    _sesiSubscription = _repository.streamSesiMeja(idKafe).listen((data) async {
      final sesiList = data.map((j) => SesiMejaModel.fromJson(j)).where((s) => s.statusSesi == 'aktif').toList();
      final map = <String, SesiMejaModel>{};
      for (final s in sesiList) {
        map[s.idMeja] = s;
      }
      state = state.copyWith(activeSessionsByMejaId: map);
    }, onError: (e) {
      debugPrint('Realtime streamSesiMeja error: $e');
    });
  }

  Future<bool> selesaikanSesi(String idMeja, String idSesiMeja) async {
    final activeCafe = _ref.read(activeCafeProvider).activeCafe;
    if (activeCafe == null) return false;

    try {
      await _repository.selesaikanSesiMeja(
        idKafe: activeCafe.idKafe,
        idMeja: idMeja,
        idSesiMeja: idSesiMeja,
      );
      await refreshData(activeCafe.idKafe);
      return true;
    } catch (e) {
      debugPrint('Error selesaikanSesi: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mejaSubscription?.cancel();
    _sesiSubscription?.cancel();
    super.dispose();
  }
}

final dashboardNotifierProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(mejaRepositoryProvider);
  return DashboardNotifier(repository, ref);
});
