import 'package:flutter/material.dart';

class AnalitikPage extends StatelessWidget {
  const AnalitikPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analitik & Laporan',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Analisis tingkat okupansi meja, durasi rata-rata pelanggan, dan efisiensi waktu kafe.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Modul Analitik Kafe',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Metrik performa penggunaan meja dan pola waktu kunjungan pelanggan.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
