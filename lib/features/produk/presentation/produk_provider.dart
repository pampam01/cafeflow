import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/produk_repository.dart';
import '../domain/produk_model.dart';
import '../../kafe/presentation/active_cafe_provider.dart';

final produkRepositoryProvider = Provider<ProdukRepository>((ref) {
  return ProdukRepository();
});

class ProdukState {
  final List<ProdukModel> rawProdukList;
  final String searchQuery;
  final String selectedKategori; // 'semua', 'makanan', 'minuman', 'snack', 'lainnya'
  final bool isLoading;

  const ProdukState({
    this.rawProdukList = const [],
    this.searchQuery = '',
    this.selectedKategori = 'semua',
    this.isLoading = false,
  });

  List<ProdukModel> get filteredProdukList {
    return rawProdukList.where((p) {
      if (!p.statusAktif) return false;

      final matchKategori = selectedKategori == 'semua' || p.kategori.toLowerCase() == selectedKategori.toLowerCase();
      final matchQuery = searchQuery.isEmpty || p.namaProduk.toLowerCase().contains(searchQuery.toLowerCase());

      return matchKategori && matchQuery;
    }).toList();
  }

  ProdukState copyWith({
    List<ProdukModel>? rawProdukList,
    String? searchQuery,
    String? selectedKategori,
    bool? isLoading,
  }) {
    return ProdukState(
      rawProdukList: rawProdukList ?? this.rawProdukList,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedKategori: selectedKategori ?? this.selectedKategori,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProdukNotifier extends StateNotifier<ProdukState> {
  final ProdukRepository _repository;
  final Ref _ref;

  ProdukNotifier(this._repository, this._ref) : super(const ProdukState(isLoading: true)) {
    loadProduk();
  }

  Future<void> loadProduk() async {
    final activeCafe = _ref.read(activeCafeProvider).activeCafe;
    if (activeCafe == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.fetchProdukList(activeCafe.idKafe);
      state = state.copyWith(rawProdukList: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setKategori(String kategori) {
    state = state.copyWith(selectedKategori: kategori);
  }

  Future<bool> tambahProduk({
    required String namaProduk,
    required String kategori,
    required double harga,
    String? deskripsi,
    int durasiTambahanMenit = 0,
  }) async {
    final activeCafe = _ref.read(activeCafeProvider).activeCafe;
    if (activeCafe == null) return false;

    try {
      final newProd = await _repository.tambahProduk(
        idKafe: activeCafe.idKafe,
        namaProduk: namaProduk,
        kategori: kategori,
        harga: harga,
        deskripsi: deskripsi,
        durasiTambahanMenit: durasiTambahanMenit,
      );
      // Reset filter pencarian & kategori ke 'semua' agar produk baru langsung nampak di UI
      state = state.copyWith(
        rawProdukList: [...state.rawProdukList, newProd],
        searchQuery: '',
        selectedKategori: 'semua',
      );
      await loadProduk();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduk(ProdukModel produk) async {
    try {
      final updated = await _repository.updateProduk(produk);
      final current = [...state.rawProdukList];
      final idx = current.indexWhere((p) => p.idProduk == produk.idProduk);
      if (idx != -1) {
        current[idx] = updated;
        state = state.copyWith(rawProdukList: current);
      }
      await loadProduk();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleStatusAktif(String idProduk, bool statusAktif) async {
    final activeCafe = _ref.read(activeCafeProvider).activeCafe;
    if (activeCafe == null) return false;

    try {
      await _repository.toggleStatusAktif(idProduk, activeCafe.idKafe, statusAktif);
      await loadProduk();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleStatusTersedia(String idProduk, bool statusTersedia) async {
    final activeCafe = _ref.read(activeCafeProvider).activeCafe;
    if (activeCafe == null) return false;

    try {
      await _repository.toggleStatusTersedia(idProduk, activeCafe.idKafe, statusTersedia);
      await loadProduk();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final produkNotifierProvider = StateNotifierProvider<ProdukNotifier, ProdukState>((ref) {
  final repo = ref.watch(produkRepositoryProvider);
  return ProdukNotifier(repo, ref);
});
