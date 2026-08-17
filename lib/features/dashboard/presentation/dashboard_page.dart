import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'dashboard_provider.dart';
import '../../kafe/presentation/active_cafe_provider.dart';
import '../../meja/domain/meja_model.dart';
import '../../meja/presentation/dialogs/lihat_qr_meja_dialog.dart';
import '../../sesi_meja/domain/sesi_meja_model.dart';
import '../../pesanan/presentation/dialogs/buat_pesanan_modal.dart';
import '../../../core/utils/currency_formatter.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeCafeState = ref.watch(activeCafeProvider);
    final dashboardState = ref.watch(dashboardNotifierProvider);

    final namaKafe = activeCafeState.activeCafe?.namaKafe ?? 'CafeFlow';
    final tanggalHariIni = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dashboardState.currentTime);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operational Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaKafe,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tanggalHariIni,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Sinkronkan Data Dashboard',
                      icon: const Icon(Icons.sync_rounded, size: 20),
                      onPressed: () {
                        ref.read(dashboardNotifierProvider.notifier).refreshData();
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const BuatPesananModal(),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      label: const Text('Buat Pesanan Baru (POS)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Operational KPI Row Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                final isMedium = constraints.maxWidth > 600;

                final kpiCards = [
                  _KpiCard(
                    title: 'Total Meja Aktif',
                    value: '${dashboardState.totalMejaAktif}',
                    subtitle: 'Terdaftar & aktif',
                    icon: Icons.table_restaurant_rounded,
                    color: Colors.blue[700]!,
                  ),
                  _KpiCard(
                    title: 'Meja Digunakan',
                    value: '${dashboardState.mejaTerisi}',
                    subtitle: 'Sesi berjalan',
                    icon: Icons.chair_alt_rounded,
                    color: Colors.amber[800]!,
                  ),
                  _KpiCard(
                    title: 'Meja Tersedia',
                    value: '${dashboardState.mejaTersedia}',
                    subtitle: 'Siap ditempati',
                    icon: Icons.event_available_rounded,
                    color: Colors.green[700]!,
                  ),
                  _KpiCard(
                    title: 'Persentase Okupansi',
                    value: '${dashboardState.persentaseOkupansi.toStringAsFixed(1)}%',
                    subtitle: 'Rasio penggunaan',
                    icon: Icons.pie_chart_outline_rounded,
                    color: Colors.purple[600]!,
                  ),
                ];

                if (isWide) {
                  return Row(
                    children: kpiCards
                        .map((card) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: card,
                              ),
                            ))
                        .toList(),
                  );
                } else if (isMedium) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: kpiCards[0]),
                          const SizedBox(width: 12),
                          Expanded(child: kpiCards[1]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: kpiCards[2]),
                          const SizedBox(width: 12),
                          Expanded(child: kpiCards[3]),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: kpiCards
                        .map((card) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: card,
                            ))
                        .toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 28),

            // Section Title: Grid Status Meja Operasional
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Operasional Meja',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    const Text('Tersedia', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.circle, size: 10, color: Color(0xFF1565C0)),
                    const SizedBox(width: 4),
                    const Text('Aktif', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.circle, size: 10, color: Color(0xFFE65100)),
                    const SizedBox(width: 4),
                    const Text('Tenggang', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.circle, size: 10, color: Color(0xFFC62828)),
                    const SizedBox(width: 4),
                    const Text('Habis', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid Cards Status Meja
            if (dashboardState.isLoading)
              const Padding(
                padding: EdgeInsets.all(48.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dashboardState.mejaList.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.table_bar_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Belum Ada Meja Terdaftar',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tambahkan meja pada menu Manajemen Meja untuk mulai beroperasi.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 850 ? 3 : (constraints.maxWidth > 550 ? 2 : 1));
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.18,
                    ),
                    itemCount: dashboardState.mejaList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final meja = dashboardState.mejaList[index];
                      final sesi = dashboardState.activeSessionsByMejaId[meja.idMeja];
                      return _MejaCard(
                        meja: meja,
                        sesi: sesi,
                        now: dashboardState.currentTime,
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MejaCard extends ConsumerWidget {
  final MejaModel meja;
  final SesiMejaModel? sesi;
  final DateTime now;

  const _MejaCard({
    required this.meja,
    required this.sesi,
    required this.now,
  });

  Future<void> _confirmSelesaikanSesi(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text('Selesaikan Sesi Meja ${meja.nomorMeja}?'),
          ],
        ),
        content: Text(
          'Tindakan ini akan mengosongkan meja dan mengubah status meja kembali menjadi "Tersedia". Akumulasi sesi ini adalah ${sesi != null ? CurrencyFormatter.formatRupiah(sesi!.totalBelanja) : "Rp0"}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ya, Selesaikan Sesi'),
          ),
        ],
      ),
    );

    if (confirm == true && sesi != null && context.mounted) {
      final success = await ref
          .read(dashboardNotifierProvider.notifier)
          .selesaikanSesi(meja.idMeja, sesi!.idSesiMeja);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sesi Meja ${meja.nomorMeja} berhasil diselesaikan. Meja kini tersedia!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyelesaikan sesi. Silakan coba lagi.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusVisual = sesi?.getStatusVisual(meja.statusAktif, meja.statusMeja) ??
        (!meja.statusAktif ? StatusVisualMeja.nonaktif : StatusVisualMeja.tersedia);

    final visualConfig = _getVisualConfig(statusVisual);

    // Hitung countdown jam:menit:detik lokal
    String sisaWaktuText = '-';
    if (sesi != null && statusVisual != StatusVisualMeja.tersedia && statusVisual != StatusVisualMeja.nonaktif) {
      final diff = sesi!.waktuBerakhir.difference(now);
      if (diff.inSeconds >= 0) {
        final minutes = diff.inMinutes;
        final seconds = diff.inSeconds % 60;
        sisaWaktuText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} tersisa';
      } else {
        final absDiff = diff.abs();
        final minutes = absDiff.inMinutes;
        final seconds = absDiff.inSeconds % 60;
        sisaWaktuText = '+${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} melewati';
      }
    }

    final jamMulaiText = sesi != null ? DateFormat('HH:mm').format(sesi!.waktuMulai) : '-';
    final totalBelanjaText = sesi != null ? CurrencyFormatter.formatRupiah(sesi!.totalBelanja) : 'Rp 0';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: visualConfig.accentColor, width: 6),
            ),
          ),
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Card: Nomor Meja & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          meja.nomorMeja,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (meja.namaMeja != null && meja.namaMeja!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '(${meja.namaMeja})',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: visualConfig.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(visualConfig.icon, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          visualConfig.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Sisa Waktu Countdown
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: visualConfig.accentColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      statusVisual == StatusVisualMeja.tersedia
                          ? 'Meja Tersedia'
                          : (statusVisual == StatusVisualMeja.nonaktif ? 'Meja Nonaktif' : sisaWaktuText),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: statusVisual == StatusVisualMeja.tersedia
                            ? theme.colorScheme.onSurface
                            : visualConfig.accentColor,
                      ),
                    ),
                  ),
                ],
              ),

              // Jam Mulai & Total Belanja
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mulai: $jamMulaiText',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    totalBelanjaText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),

              // Action Buttons Row (Selesaikan Sesi / Order Tambahan / Lihat QR)
              Row(
                children: [
                  if (sesi != null) ...[
                    // Button Selesaikan Sesi (Tutup Meja)
                    Expanded(
                      flex: 4,
                      child: Tooltip(
                        message: 'Selesaikan sesi meja & bebaskan meja',
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[700],
                            side: BorderSide(color: Colors.red[300]!),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _confirmSelesaikanSesi(context, ref),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                          label: const Text('Selesaikan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Button Order Tambahan (Perpanjang Sesi)
                    Expanded(
                      flex: 4,
                      child: Tooltip(
                        message: 'Tambah pesanan & perpanjang waktu',
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => BuatPesananModal(selectedMeja: meja),
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 14),
                          label: const Text('+ Order', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Button Buat Sesi Baru (Saat Meja Tersedia)
                    Expanded(
                      flex: 8,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32), // Emerald Green
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => BuatPesananModal(selectedMeja: meja),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 14),
                        label: const Text('Buat Pesanan Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),

                  // Button QR Code Modal
                  Tooltip(
                    message: 'Lihat Kode QR Meja',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => LihatQrMejaDialog(meja: meja),
                        );
                      },
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: Icon(Icons.qr_code_2_rounded, size: 16, color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _VisualConfig _getVisualConfig(StatusVisualMeja status) {
    switch (status) {
      case StatusVisualMeja.tersedia:
        return const _VisualConfig(
          label: 'Tersedia',
          icon: Icons.check_circle_outline_rounded,
          accentColor: Color(0xFF2E7D32), // Emerald Green
        );
      case StatusVisualMeja.aktif:
        return const _VisualConfig(
          label: 'Aktif',
          icon: Icons.timer_rounded,
          accentColor: Color(0xFF1565C0), // Royal Blue
        );
      case StatusVisualMeja.kurang15Menit:
        return const _VisualConfig(
          label: '< 15 Mnt',
          icon: Icons.warning_amber_rounded,
          accentColor: Color(0xFFD97706), // Amber Orange
        );
      case StatusVisualMeja.masaTenggang:
        return const _VisualConfig(
          label: 'Tenggang',
          icon: Icons.hourglass_bottom_rounded,
          accentColor: Color(0xFFE65100), // Vivid Deep Orange
        );
      case StatusVisualMeja.melewatiWaktu:
        return const _VisualConfig(
          label: 'Waktu Habis',
          icon: Icons.alarm_off_rounded,
          accentColor: Color(0xFFC62828), // Crimson Red
        );
      case StatusVisualMeja.nonaktif:
        return const _VisualConfig(
          label: 'Nonaktif',
          icon: Icons.block_rounded,
          accentColor: Color(0xFF616161), // Slate Grey
        );
    }
  }
}

class _VisualConfig {
  final String label;
  final IconData icon;
  final Color accentColor;

  const _VisualConfig({
    required this.label,
    required this.icon,
    required this.accentColor,
  });
}
