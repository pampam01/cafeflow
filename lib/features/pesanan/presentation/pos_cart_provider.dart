import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pesanan_repository.dart';
import '../domain/pesanan_model.dart';
import '../../produk/domain/produk_model.dart';
import '../../meja/domain/meja_model.dart';
import '../../kafe/presentation/active_cafe_provider.dart';

final pesananRepositoryProvider = Provider<PesananRepository>((ref) {
  return PesananRepository();
});

class CartItem {
  final ProdukModel produk;
  final int jumlah;
  final String? catatan;

  const CartItem({
    required this.produk,
    required this.jumlah,
    this.catatan,
  });

  double get subtotal => produk.harga * jumlah;

  CartItem copyWith({
    int? jumlah,
    String? catatan,
  }) {
    return CartItem(
      produk: produk,
      jumlah: jumlah ?? this.jumlah,
      catatan: catatan ?? this.catatan,
    );
  }
}

class PosCartState {
  final MejaModel? selectedMeja;
  final Map<String, CartItem> items;
  final bool isSubmitting;
  final String? errorMessage;

  const PosCartState({
    this.selectedMeja,
    this.items = const {},
    this.isSubmitting = false,
    this.errorMessage,
  });

  double get totalHarga {
    return items.values.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  int get totalItemCount {
    return items.values.fold(0, (sum, item) => sum + item.jumlah);
  }

  PosCartState copyWith({
    MejaModel? selectedMeja,
    Map<String, CartItem>? items,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return PosCartState(
      selectedMeja: selectedMeja ?? this.selectedMeja,
      items: items ?? this.items,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class PosCartNotifier extends StateNotifier<PosCartState> {
  final Ref _ref;

  PosCartNotifier(this._ref) : super(const PosCartState());

  void selectMeja(MejaModel meja) {
    state = state.copyWith(selectedMeja: meja);
  }

  void addItem(ProdukModel produk) {
    final currentMap = Map<String, CartItem>.from(state.items);
    if (currentMap.containsKey(produk.idProduk)) {
      final existing = currentMap[produk.idProduk]!;
      currentMap[produk.idProduk] = existing.copyWith(jumlah: existing.jumlah + 1);
    } else {
      currentMap[produk.idProduk] = CartItem(produk: produk, jumlah: 1);
    }
    state = state.copyWith(items: currentMap);
  }

  void removeItem(String idProduk) {
    final currentMap = Map<String, CartItem>.from(state.items);
    currentMap.remove(idProduk);
    state = state.copyWith(items: currentMap);
  }

  void updateQuantity(String idProduk, int delta) {
    final currentMap = Map<String, CartItem>.from(state.items);
    if (!currentMap.containsKey(idProduk)) return;

    final existing = currentMap[idProduk]!;
    final newJumlah = existing.jumlah + delta;

    if (newJumlah <= 0) {
      currentMap.remove(idProduk);
    } else {
      currentMap[idProduk] = existing.copyWith(jumlah: newJumlah);
    }
    state = state.copyWith(items: currentMap);
  }

  void updateCatatan(String idProduk, String catatan) {
    final currentMap = Map<String, CartItem>.from(state.items);
    if (currentMap.containsKey(idProduk)) {
      currentMap[idProduk] = currentMap[idProduk]!.copyWith(catatan: catatan.trim());
      state = state.copyWith(items: currentMap);
    }
  }

  void resetCart() {
    state = const PosCartState();
  }

  Future<Map<String, dynamic>?> checkout() async {
    final activeCafe = _ref.read(activeCafeProvider).activeCafe;
    if (activeCafe == null || state.selectedMeja == null || state.items.isEmpty) {
      state = state.copyWith(errorMessage: 'Harap pilih meja dan minimal 1 produk.');
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final repo = _ref.read(pesananRepositoryProvider);
      final detailItems = state.items.values.map((cartItem) {
        return DetailPesananModel(
          idProduk: cartItem.produk.idProduk,
          jumlah: cartItem.jumlah,
          hargaSatuan: cartItem.produk.harga,
          subtotal: cartItem.subtotal,
          catatan: cartItem.catatan,
        );
      }).toList();

      final result = await repo.buatPesananAwalRpc(
        idKafe: activeCafe.idKafe,
        idMeja: state.selectedMeja!.idMeja,
        items: detailItems,
      );

      resetCart();
      return result;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return null;
    }
  }
}

final posCartProvider = StateNotifierProvider<PosCartNotifier, PosCartState>((ref) {
  return PosCartNotifier(ref);
});
