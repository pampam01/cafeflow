import 'package:flutter/material.dart';

class MejaPage extends StatelessWidget {
  const MejaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Meja Kafe',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Atur kapasitas, status ketersediaan, dan penataan meja kafe.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.table_restaurant_rounded, size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Modul Meja Kafe (data_meja)',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Kelola data meja dengan status: tersedia, terisi, dipesan, nonaktif.'),
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
