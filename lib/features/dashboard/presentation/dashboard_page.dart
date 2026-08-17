import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'dashboard_provider.dart';
import '../../kafe/presentation/active_cafe_provider.dart';
import '../../meja/domain/meja_model.dart';
import '../../sesi_meja/domain/sesi_meja_model.dart';
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
                    Row(
                      children: [
                        Text(
                          namaKafe,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green[300]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Real-time Live',
                                style: TextStyle(color: Colors.green[900], fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tanggalHariIni,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Muat Ulang Data',
                  onPressed: () {
                    final idKafe = activeCafeState.activeCafe?.idKafe;
                    if (idKafe != null) {
                      ref.read(dashboardNotifierProvider.notifier).refreshData(idKafe);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KPI Overview Metrics Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 650 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _KpiCard(
                      title: 'Total Meja Aktif',
                      value: '${dashboardState.totalMejaAktif} Meja',
                      subtitle: 'Kapasitas kafe terdaftar',
                      icon: Icons.table_restaurant_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    _KpiCard(
                      title: 'Meja Digunakan',
                      value: '${dashboardState.mejaTerisi} Meja',
                      subtitle: 'Sesi pelanggan berlangsung',
                      icon: Icons.people_alt_rounded,
                      color: Colors.blue[700]!,
                    ),
                    _KpiCard(
                      title: 'Meja Tersedia',
                      value: '${dashboardState.mejaTersedia} Meja',
                      subtitle: 'Siap menerima pelanggan',
                      icon: Icons.check_circle_outline_rounded,
                      color: Colors.teal[700]!,
                    ),
                    _KpiCard(
                      title: 'Tingkat Okupansi',
                      value: '${dashboardState.persentaseOkupansi.toStringAsFixed(1)}%',
                      subtitle: 'Rasio penggunaan meja',
                      icon: Icons.pie_chart_outline_rounded,
                      color: Colors.amber[800]!,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Section Header: Kartu Status Meja
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kartu Status Meja Operasional',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${dashboardState.mejaList.length} total meja',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Responsive Grid Kartu Meja
            if (dashboardState.isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dashboardState.mejaList.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.table_restaurant_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum Ada Meja Terdaftar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tambahkan meja di menu Manajemen Meja untuk memulai operasional.',
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
                  final crossAxisCount = constraints.maxWidth > 1100 ? 4 : (constraints.maxWidth > 750 ? 3 : (constraints.maxWidth > 500 ? 2 : 1));
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.45,
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

class _MejaCard extends StatelessWidget {
  final MejaModel meja;
  final SesiMejaModel? sesi;
  final DateTime now;

  const _MejaCard({
    required this.meja,
    required this.sesi,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(16.0),
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: visualConfig.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(visualConfig.icon, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          visualConfig.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Sisa Waktu Countdown
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: visualConfig.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    statusVisual == StatusVisualMeja.tersedia
                        ? 'Meja Tersedia'
                        : (statusVisual == StatusVisualMeja.nonaktif ? 'Meja Nonaktif' : sisaWaktuText),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: statusVisual == StatusVisualMeja.tersedia
                          ? theme.colorScheme.onSurface
                          : visualConfig.accentColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              const SizedBox(height: 6),

              // Footer Details: Jam Mulai & Total Belanja (Rp)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mulai: $jamMulaiText',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    totalBelanjaText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
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
