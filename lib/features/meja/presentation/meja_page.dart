import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'meja_provider.dart';
import '../domain/meja_model.dart';
import 'dialogs/tambah_edit_meja_dialog.dart';
import 'dialogs/lihat_qr_meja_dialog.dart';
import '../../kafe/presentation/active_cafe_provider.dart';

class MejaPage extends ConsumerWidget {
  const MejaPage({super.key});

  void _showTambahMejaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TambahEditMejaDialog(),
    );
  }

  void _showEditMejaDialog(BuildContext context, MejaModel meja) {
    showDialog(
      context: context,
      builder: (context) => TambahEditMejaDialog(mejaToEdit: meja),
    );
  }

  void _showLihatQrDialog(BuildContext context, MejaModel meja) {
    showDialog(
      context: context,
      builder: (context) => LihatQrMejaDialog(meja: meja),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mejaState = ref.watch(mejaListProvider);
    final activeCafe = ref.watch(activeCafeProvider).activeCafe;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manajemen Meja Kafe',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Atur denah, kapasitas, urutan tampilan, dan token QR code meja (${activeCafe?.namaKafe ?? 'Kafe'}).',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showTambahMejaDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah Meja Baru'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content Table Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.table_restaurant_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Daftar Meja Kafe',
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          tooltip: 'Muat Ulang Data',
                          onPressed: () {
                            ref.read(mejaListProvider.notifier).loadMeja();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    mejaState.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Gagal memuat data meja: $err',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      data: (mejaList) {
                        if (mejaList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(Icons.table_bar_outlined, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Belum Ada Meja Terdaftar',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Klik tombol "Tambah Meja Baru" di atas untuk mendaftarkan meja kafe.',
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
                              headingRowHeight: 44,
                              dataRowMaxHeight: 64,
                              columns: const [
                                DataColumn(label: Text('Kode / Nomor', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Nama Meja', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Kapasitas', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Urutan', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status Operasional', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status Aktif', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Aksi & QR Code', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: mejaList.map((meja) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        meja.nomorMeja,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(Text(meja.namaMeja ?? '-')),
                                    DataCell(
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text('${meja.kapasitas} orang'),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text('#${meja.urutanTampilan}')),
                                    DataCell(_StatusMejaBadge(statusMeja: meja.statusMeja)),
                                    DataCell(
                                      Switch(
                                        value: meja.statusAktif,
                                        onChanged: (val) {
                                          ref.read(mejaListProvider.notifier).toggleStatusAktif(meja.idMeja, val);
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF5D4037)),
                                            tooltip: 'Lihat QR Code',
                                            onPressed: () => _showLihatQrDialog(context, meja),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18),
                                            tooltip: 'Edit Meja',
                                            onPressed: () => _showEditMejaDialog(context, meja),
                                          ),
                                        ],
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

class _StatusMejaBadge extends StatelessWidget {
  final String statusMeja;

  const _StatusMejaBadge({required this.statusMeja});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (statusMeja) {
      case 'terisi':
        bg = Colors.blue[50]!;
        text = Colors.blue[900]!;
        label = 'Terisi';
        break;
      case 'dipesan':
        bg = Colors.amber[50]!;
        text = Colors.amber[900]!;
        label = 'Dipesan';
        break;
      case 'nonaktif':
        bg = Colors.grey[200]!;
        text = Colors.grey[800]!;
        label = 'Nonaktif';
        break;
      case 'tersedia':
      default:
        bg = Colors.green[50]!;
        text = Colors.green[900]!;
        label = 'Tersedia';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
