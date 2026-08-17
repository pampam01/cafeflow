import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'produk_provider.dart';
import 'dialogs/tambah_edit_produk_dialog.dart';
import '../domain/produk_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../kafe/presentation/active_cafe_provider.dart';

class ProdukPage extends ConsumerWidget {
  const ProdukPage({super.key});

  void _showTambahProdukDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TambahEditProdukDialog(),
    );
  }

  void _showEditProdukDialog(BuildContext context, ProdukModel produk) {
    showDialog(
      context: context,
      builder: (context) => TambahEditProdukDialog(produkToEdit: produk),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final produkState = ref.watch(produkNotifierProvider);
    final activeCafe = ref.watch(activeCafeProvider).activeCafe;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Katalog Produk & Menu',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola menu kafe (${activeCafe?.namaKafe ?? "Kafe"}), harga Rupiah, dan durasi waktu tambahan.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showTambahProdukDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah Produk Baru'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter & Search Bar Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Cari nama produk...',
                              prefixIcon: Icon(Icons.search_rounded),
                              isDense: true,
                            ),
                            onChanged: (val) {
                              ref.read(produkNotifierProvider.notifier).setSearchQuery(val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: 'Muat Ulang Katalog',
                          onPressed: () {
                            ref.read(produkNotifierProvider.notifier).loadProduk();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final cat in ['semua', 'makanan', 'minuman', 'snack', 'lainnya']) ...[
                            ChoiceChip(
                              label: Text(cat == 'semua' ? 'Semua Kategori' : cat.toUpperCase()),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Product List Data Table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: produkState.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : produkState.filteredProdukList.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(Icons.no_food_outlined, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tidak Ada Produk Ditemukan',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Coba ganti kata kunci pencarian atau tambah produk baru.',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 120),
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Nama Produk', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Harga (Rp)', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Bonus Durasi', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Stok Tersedia', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Status Aktif', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: produkState.filteredProdukList.map((produk) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              produk.namaProduk,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            if (produk.deskripsi != null && produk.deskripsi!.isNotEmpty)
                                              Text(
                                                produk.deskripsi!,
                                                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                              ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            produk.kategori.toUpperCase(),
                                            style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          CurrencyFormatter.formatRupiah(produk.harga),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataCell(
                                        Text(produk.durasiTambahanMenit > 0 ? '+${produk.durasiTambahanMenit} mnt' : '-'),
                                      ),
                                      DataCell(
                                        Switch(
                                          value: produk.statusTersedia,
                                          activeColor: Colors.green,
                                          onChanged: (val) {
                                            ref.read(produkNotifierProvider.notifier).toggleStatusTersedia(produk.idProduk, val);
                                          },
                                        ),
                                      ),
                                      DataCell(
                                        Switch(
                                          value: produk.statusAktif,
                                          onChanged: (val) {
                                            ref.read(produkNotifierProvider.notifier).toggleStatusAktif(produk.idProduk, val);
                                          },
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Produk',
                                          onPressed: () => _showEditProdukDialog(context, produk),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
