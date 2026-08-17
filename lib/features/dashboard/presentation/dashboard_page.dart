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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: visualConfig.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: visualConfig.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Card: Nomor Meja & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    meja.nomorMeja,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (meja.namaMeja != null && meja.namaMeja!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(${meja.namaMeja})',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: visualConfig.badgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(visualConfig.icon, size: 14, color: visualConfig.textColor),
                    const SizedBox(width: 4),
                    Text(
                      visualConfig.label,
                      style: TextStyle(
                        color: visualConfig.textColor,
                        fontSize: 11,
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
              Icon(Icons.timer_outlined, size: 16, color: visualConfig.textColor),
              const SizedBox(width: 6),
              Text(
                statusVisual == StatusVisualMeja.tersedia
                    ? 'Tersedia'
                    : (statusVisual == StatusVisualMeja.nonaktif ? 'Nonaktif' : sisaWaktuText),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: visualConfig.textColor,
                ),
              ),
            ],
          ),

          const Divider(height: 1),

          // Footer Details: Jam Mulai & Total Belanja (Rp)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mulai: $jamMulaiText',
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              ),
              Text(
                totalBelanjaText,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _VisualConfig _getVisualConfig(StatusVisualMeja status) {
    switch (status) {
      case StatusVisualMeja.tersedia:
        return _VisualConfig(
          label: 'Tersedia',
          icon: Icons.check_circle_outline_rounded,
          bgColor: const Color(0xFFF2F9F5),
          badgeBgColor: const Color(0xFFE1F5FE),
          borderColor: const Color(0xFFA5D6A7),
          textColor: const Color(0xFF2E7D32),
        );
      case StatusVisualMeja.aktif:
        return _VisualConfig(
          label: 'Aktif',
          icon: Icons.timer_rounded,
          bgColor: const Color(0xFFF0F4FE),
          badgeBgColor: const Color(0xFFDBEAFE),
          borderColor: const Color(0xFF90CAF9),
          textColor: const Color(0xFF1565C0),
        );
      case StatusVisualMeja.kurang15Menit:
        return _VisualConfig(
          label: '< 15 Mnt',
          icon: Icons.warning_amber_rounded,
          bgColor: const Color(0xFFFFFDE7),
          badgeBgColor: const Color(0xFFFFF59D),
          borderColor: const Color(0xFFFFE082),
          textColor: const Color(0xFFF57F17),
        );
      case StatusVisualMeja.masaTenggang:
        return _VisualConfig(
          label: 'Tenggang',
          icon: Icons.hourglass_bottom_rounded,
          bgColor: const Color(0xFFFFF3E0),
          badgeBgColor: const Color(0xFFFFCC80),
          borderColor: const Color(0xFFFFB74D),
          textColor: const Color(0xFFE65100),
        );
      case StatusVisualMeja.melewatiWaktu:
        return _VisualConfig(
          label: 'Waktu Habis',
          icon: Icons.alarm_off_rounded,
          bgColor: const Color(0xFFFFEBEE),
          badgeBgColor: const Color(0xFFFFCDD2),
          borderColor: const Color(0xFFEF9A9A),
          textColor: const Color(0xFFC62828),
        );
      case StatusVisualMeja.nonaktif:
        return _VisualConfig(
          label: 'Nonaktif',
          icon: Icons.block_rounded,
          bgColor: const Color(0xFFF5F5F5),
          badgeBgColor: const Color(0xFFE0E0E0),
          borderColor: const Color(0xFFBDBDBD),
          textColor: const Color(0xFF616161),
        );
    }
  }
}

class _VisualConfig {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color badgeBgColor;
  final Color borderColor;
  final Color textColor;

  const _VisualConfig({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.badgeBgColor,
    required this.borderColor,
    required this.textColor,
  });
}
