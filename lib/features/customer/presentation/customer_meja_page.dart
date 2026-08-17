import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer_page_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class CustomerMejaPage extends ConsumerWidget {
  final String tokenQr;

  const CustomerMejaPage({
    super.key,
    required this.tokenQr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(customerMejaProvider(tokenQr));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Warm soft cream background
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480), // Mobile-First layout width limit
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: state.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : !state.isValid
                      ? Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.qr_code_scanner_rounded, size: 64, color: Colors.orange),
                                const SizedBox(height: 16),
                                Text(
                                  'QR Code Tidak Ditemukan',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.pesan ?? 'Pastikan Anda melakukan pemindaian pada Meja Kafe yang sah.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Brand Header Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.coffee_rounded, size: 16, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'CafeFlow Customer Portal',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Nama Kafe & Nomor Meja Header
                            Text(
                              state.namaKafe,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2C221E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Meja ${state.nomorMeja}${state.namaMeja != null ? " (${state.namaMeja})" : ""}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Main Comfort Time Display Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(
                                  color: state.adaSesiAktif
                                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                      : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.hourglass_top_rounded,
                                        size: 20,
                                        color: state.adaSesiAktif ? theme.colorScheme.primary : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Comfort Time Sesi Anda',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Live Timer Display
                                  if (state.adaSesiAktif) ...[
                                    Text(
                                      state.formattedCountdown,
                                      style: theme.textTheme.displayMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
                                        color: state.remainingDuration.inMinutes <= 15
                                            ? Colors.amber[900]
                                            : theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      state.remainingDuration == Duration.zero
                                          ? (state.tingkatKeramaian == 'ramai'
                                              ? 'Kafe cukup ramai. Pesan menu tambahan untuk perpanjang waktu.'
                                              : 'Sesi santai Anda telah usai. Nikmati kenyamanan kafe kami!')
                                          : 'Sisa waktu bersantai & nikmati suasana',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: state.remainingDuration == Duration.zero ? FontWeight.w600 : FontWeight.normal,
                                        color: state.remainingDuration == Duration.zero ? Colors.amber[900] : Colors.grey[600],
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 12),
                                    Icon(Icons.info_outline_rounded, size: 40, color: Colors.amber[800]),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Meja ini belum memiliki sesi aktif.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Silakan memesan ke kasir untuk memulai sesi santai Anda.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Total Belanja & Status Keramaian Cards Grid
                            Row(
                              children: [
                                // Total Belanja Card
                                Expanded(
                                  child: _CustomerMetricCard(
                                    title: 'Total Pesanan',
                                    value: CurrencyFormatter.formatRupiah(state.totalBelanja),
                                    icon: Icons.receipt_long_rounded,
                                    iconColor: Colors.blue[700]!,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Status Keramaian Card
                                Expanded(
                                  child: _CustomerMetricCard(
                                    title: 'Status Kafe',
                                    value: _getKeramaianLabel(state.tingkatKeramaian),
                                    icon: Icons.people_outline_rounded,
                                    iconColor: _getKeramaianColor(state.tingkatKeramaian),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Soft Reminder Box (if applicable)
                            if (state.pesanCustomer != null && state.pesanCustomer!.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1), // Soft warm amber container
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFFE082)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.stars_rounded, color: Color(0xFFF57F17), size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        state.pesanCustomer!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5D4037),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Refresh Status Action Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () {
                                  ref.read(customerMejaProvider(tokenQr).notifier).loadPublicStatus();
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Muat Ulang Status', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }

  String _getKeramaianLabel(String status) {
    switch (status.toLowerCase()) {
      case 'ramai':
        return 'Ramai';
      case 'sepi':
        return 'Sepi';
      case 'normal':
      default:
        return 'Normal';
    }
  }

  Color _getKeramaianColor(String status) {
    switch (status.toLowerCase()) {
      case 'ramai':
        return Colors.orange[800]!;
      case 'sepi':
        return Colors.teal[700]!;
      case 'normal':
      default:
        return Colors.blue[700]!;
    }
  }
}

class _CustomerMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _CustomerMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C221E),
            ),
          ),
        ],
      ),
    );
  }
}
