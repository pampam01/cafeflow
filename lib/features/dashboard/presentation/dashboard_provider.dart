import 'dart:async';
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
    _initDashboard();
    // Local ticker updating currentTime every 1 second (no DB hits)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(currentTime: DateTime.now());
    });
  }

  Future<void> _initDashboard() async {
    final activeCafe = _ref.read(activeCafeProvider).activeCafe;
    if (activeCafe == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final idKafe = activeCafe.idKafe;
    await refreshData(idKafe);
    _setupRealtimeSubscriptions(idKafe);
  }

  Future<void> refreshData(String idKafe) async {
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
      state = state.copyWith(isLoading: false);
    }
  }

  void _setupRealtimeSubscriptions(String idKafe) {
    _mejaSubscription?.cancel();
    _sesiSubscription?.cancel();

    _mejaSubscription = _repository.streamMeja(idKafe).listen((data) async {
      final updatedList = data.map((j) => MejaModel.fromJson(j)).toList();
      state = state.copyWith(
        mejaList: updatedList..sort((a, b) => a.urutanTampilan.compareTo(b.urutanTampilan)),
      );
    });

    _sesiSubscription = _repository.streamSesiMeja(idKafe).listen((data) async {
      final sesiList = data.map((j) => SesiMejaModel.fromJson(j)).where((s) => s.statusSesi == 'aktif').toList();
      final map = <String, SesiMejaModel>{};
      for (final s in sesiList) {
        map[s.idMeja] = s;
      }
      state = state.copyWith(activeSessionsByMejaId: map);
    });
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
