import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'pos_cart_provider.dart';
import 'dialogs/buat_pesanan_modal.dart';
import 'dialogs/struk_pesanan_dialog.dart';
import '../domain/pesanan_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../kafe/presentation/active_cafe_provider.dart';

final pesananListProvider = FutureProvider.autoDispose<List<PesananModel>>((ref) async {
  final activeCafe = ref.watch(activeCafeProvider).activeCafe;
  if (activeCafe == null) return [];
  final repo = ref.watch(pesananRepositoryProvider);
  return await repo.fetchPesananList(activeCafe.idKafe);
});

class PesananPage extends ConsumerWidget {
  const PesananPage({super.key});

  void _showBuatPesananModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const BuatPesananModal(),
    );
  }

  void _showStrukDialog(BuildContext context, PesananModel pesanan, String namaKafe) {
    showDialog(
      context: context,
      builder: (_) => StrukPesananDialog(
        rpcResult: {
          'nomor_pesanan': pesanan.nomorPesanan,
          'total_belanja': pesanan.totalBelanja,
          'durasi_menit': 60,
          'waktu_berakhir': pesanan.waktuPesanan.add(const Duration(minutes: 60)).toIso8601String(),
        },
        namaKafe: namaKafe,
        nomorMeja: pesanan.nomorMeja ?? '-',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pesananAsync = ref.watch(pesananListProvider);
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
                      'Daftar Transaksi Pesanan',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Riwayat pesanan kasir dan otomatisasi sesi Comfort Time (${activeCafe?.namaKafe ?? "Kafe"}).',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showBuatPesananModal(context),
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: const Text('Buat Pesanan Baru (POS)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Order History Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Riwayat Pesanan Kasir',
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: 'Muat Ulang Pesanan',
                          onPressed: () {
                            ref.invalidate(pesananListProvider);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    pesananAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('Gagal memuat pesanan: $err', style: const TextStyle(color: Colors.red)),
                      ),
                      data: (pesananList) {
                        if (pesananList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Belum Ada Transaksi Pesanan',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Klik "Buat Pesanan Baru (POS)" untuk memproses pesanan pertama.',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 120),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Nomor Pesanan', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Nomor Meja', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Total Belanja (Rp)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Waktu Pesanan', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status Pesanan', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi Struk', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: pesananList.map((p) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        p.nomorPesanan,
                                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                                      ),
                                    ),
                                    DataCell(
                                      Text('Meja ${p.nomorMeja ?? "-"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    DataCell(
                                      Text(
                                        CurrencyFormatter.formatRupiah(p.totalBelanja),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(
                                      Text(DateFormat('dd/MM/yyyy HH:mm').format(p.waktuPesanan)),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          p.statusPesanan.toUpperCase(),
                                          style: TextStyle(color: Colors.green[900], fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.receipt_outlined, size: 20),
                                        tooltip: 'Lihat Struk',
                                        onPressed: () => _showStrukDialog(context, p, activeCafe?.namaKafe ?? 'CafeFlow'),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
