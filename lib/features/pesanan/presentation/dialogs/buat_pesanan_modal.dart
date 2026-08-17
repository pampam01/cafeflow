import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pos_cart_provider.dart';
import 'struk_pesanan_dialog.dart';
import '../../../produk/presentation/produk_provider.dart';
import '../../../meja/presentation/meja_provider.dart';
import '../../../meja/domain/meja_model.dart';
import '../../../kafe/presentation/active_cafe_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class BuatPesananModal extends ConsumerWidget {
  const BuatPesananModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final produkState = ref.watch(produkNotifierProvider);
    final mejaState = ref.watch(mejaListProvider);
    final cartState = ref.watch(posCartProvider);
    final activeCafe = ref.watch(activeCafeProvider).activeCafe;

    final allMejaList = mejaState.value?.where((m) => m.statusAktif).toList() ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 680),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.point_of_sale_rounded, color: theme.colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kasir Terminal POS',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${activeCafe?.namaKafe ?? 'Kafe'} • Pesanan Awal & Perpanjangan Sesi Comfort Time',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      ref.read(posCartProvider.notifier).resetCart();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // Main Body: 2 Columns (Left: Product Catalog & Table Selector, Right: Cart & Checkout Summary)
            Expanded(
              child: Row(
                children: [
                  // Left Side: Table Picker & Product List (60% width)
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Table Selector Dropdown
                          Text(
                            'Pilih Meja Pelanggan *',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<MejaModel>(
                            value: cartState.selectedMeja,
                            hint: const Text('Pilih Meja (Tersedia / Terisi)'),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.table_restaurant_outlined),
                            ),
                            items: allMejaList.map((meja) {
                              final isTerisi = meja.statusMeja == 'terisi';
                              final statusTag = isTerisi ? '⚡ Terisi (Pesanan Tambahan)' : '🟢 Tersedia';
                              return DropdownMenuItem(
                                value: meja,
                                child: Text('Meja ${meja.nomorMeja} — $statusTag'),
                              );
                            }).toList(),
                            onChanged: (meja) {
                              if (meja != null) {
                                ref.read(posCartProvider.notifier).selectMeja(meja);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // 2. Search & Category Filter
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Cari nama produk...',
                                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                                    isDense: true,
                                  ),
                                  onChanged: (query) {
                                    ref.read(produkNotifierProvider.notifier).setSearchQuery(query);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Category Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final cat in ['semua', 'makanan', 'minuman', 'snack', 'lainnya']) ...[
                                  ChoiceChip(
                                    label: Text(cat == 'semua' ? 'Semua Menu' : cat.toUpperCase()),
                                    selected: produkState.selectedKategori == cat,
                                    onSelected: (selected) {
                                      if (selected) {
                                        ref.read(produkNotifierProvider.notifier).setKategori(cat);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Product Grid
                          Expanded(
                            child: produkState.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : produkState.filteredProdukList.isEmpty
                                    ? const Center(child: Text('Tidak ada produk tersedia.'))
                                    : GridView.builder(
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 1.6,
                                        ),
                                        itemCount: produkState.filteredProdukList.length,
                                        itemBuilder: (context, index) {
                                          final produk = produkState.filteredProdukList[index];
                                          final isOutOfStock = !produk.statusTersedia;

                                          return Card(
                                            child: InkWell(
                                              onTap: isOutOfStock
                                                  ? null
                                                  : () {
                                                      ref.read(posCartProvider.notifier).addItem(produk);
                                                    },
                                              borderRadius: BorderRadius.circular(16),
                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      produk.namaProduk,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        color: isOutOfStock ? Colors.grey : null,
                                                      ),
                                                    ),
                                                    Text(
                                                      CurrencyFormatter.formatRupiah(produk.harga),
                                                      style: TextStyle(
                                                        color: isOutOfStock ? Colors.grey : theme.colorScheme.primary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        if (produk.durasiTambahanMenit > 0)
                                                          Text(
                                                            '+${produk.durasiTambahanMenit} mnt',
                                                            style: TextStyle(fontSize: 11, color: Colors.amber[900], fontWeight: FontWeight.bold),
                                                          )
                                                        else
                                                          const SizedBox(),
                                                        Icon(
                                                          isOutOfStock ? Icons.block : Icons.add_circle_outline_rounded,
                                                          color: isOutOfStock ? Colors.grey : theme.colorScheme.primary,
                                                          size: 22,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1),

                  // Right Side: Dark Espresso Cart Summary Panel (40% width)
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF211D1B), // Warm Espresso Dark Theme (Non-glaring)
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.shopping_bag_rounded, color: Color(0xFFFFB74D), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Keranjang Pesanan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              if (cartState.items.isNotEmpty)
                                TextButton(
                                  onPressed: () => ref.read(posCartProvider.notifier).resetCart(),
                                  child: const Text('Kosongkan', style: TextStyle(color: Color(0xFFEF5350), fontSize: 12)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Selected Table Tag
                          if (cartState.selectedMeja != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF332B27),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFFB74D).withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.table_restaurant_rounded, color: Color(0xFFFFB74D), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Meja ${cartState.selectedMeja!.nomorMeja}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFB74D)),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38231E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pilih Meja terlebih dahulu di sebelah kiri',
                                    style: TextStyle(fontSize: 11, color: Colors.orangeAccent),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Cart Items List
                          Expanded(
                            child: cartState.items.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.shopping_bag_outlined, size: 44, color: Colors.white30),
                                        SizedBox(height: 8),
                                        Text('Keranjang masih kosong', style: TextStyle(color: Colors.white54, fontSize: 13)),
                                        SizedBox(height: 4),
                                        Text('Klik menu di sebelah kiri untuk memilih', style: TextStyle(color: Colors.white38, fontSize: 11)),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: cartState.items.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final item = cartState.items.values.toList()[index];
                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2E2825),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF423B36)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.produk.namaProduk,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  CurrencyFormatter.formatRupiah(item.subtotal),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Color(0xFFFFD54F),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),

                                            // Catatan Textfield
                                            TextField(
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                              decoration: InputDecoration(
                                                hintText: 'Catatan (misal: Less sugar, extra ice)...',
                                                hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                filled: true,
                                                fillColor: const Color(0xFF1E1A18),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                              onChanged: (val) {
                                                ref.read(posCartProvider.notifier).updateCatatan(item.produk.idProduk, val);
                                              },
                                            ),
                                            const SizedBox(height: 10),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Quantity Selector
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF1E1A18),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.remove_rounded, size: 18, color: Colors.white70),
                                                        padding: const EdgeInsets.all(4),
                                                        constraints: const BoxConstraints(),
                                                        onPressed: () {
                                                          ref.read(posCartProvider.notifier).updateQuantity(item.produk.idProduk, -1);
                                                        },
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Text(
                                                          '${item.jumlah}',
                                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white70),
                                                        padding: const EdgeInsets.all(4),
                                                        constraints: const BoxConstraints(),
                                                        onPressed: () {
                                                          ref.read(posCartProvider.notifier).updateQuantity(item.produk.idProduk, 1);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF5350), size: 20),
                                                  onPressed: () {
                                                    ref.read(posCartProvider.notifier).removeItem(item.produk.idProduk);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Total & Checkout Button
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E2825),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF423B36)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Pembayaran', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                                    Text(
                                      CurrencyFormatter.formatRupiah(cartState.totalHarga),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                        color: Color(0xFFFFD54F),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: cartState.isSubmitting || cartState.selectedMeja == null || cartState.items.isEmpty
                                        ? null
                                        : () async {
                                            final result = await ref.read(posCartProvider.notifier).checkout();
                                            if (result != null && context.mounted) {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (_) => StrukPesananDialog(
                                                  rpcResult: result,
                                                  namaKafe: activeCafe?.namaKafe ?? 'CafeFlow',
                                                  nomorMeja: cartState.selectedMeja?.nomorMeja ?? '-',
                                                ),
                                              );
                                            }
                                          },
                                    child: cartState.isSubmitting
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('Konfirmasi & Proses Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
