import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/autentikasi/presentation/auth_provider.dart';
import '../../features/autentikasi/presentation/user_profile_provider.dart';
import '../../features/kafe/presentation/active_cafe_provider.dart';

class AppResponsiveLayout extends ConsumerWidget {
  final Widget child;
  final String location;

  const AppResponsiveLayout({
    super.key,
    required this.child,
    required this.location,
  });

  static const List<({String path, String label, IconData icon, IconData activeIcon})> navItems = [
    (path: '/dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded),
    (path: '/sesi-meja', label: 'Sesi Meja', icon: Icons.timer_outlined, activeIcon: Icons.timer_rounded),
    (path: '/meja', label: 'Meja Kafe', icon: Icons.table_restaurant_outlined, activeIcon: Icons.table_restaurant_rounded),
    (path: '/produk', label: 'Produk & Menu', icon: Icons.restaurant_menu_outlined, activeIcon: Icons.restaurant_menu_rounded),
    (path: '/pesanan', label: 'Pesanan', icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded),
    (path: '/pelanggan', label: 'Pelanggan', icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded),
    (path: '/analitik', label: 'Analitik', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded),
    (path: '/pengaturan', label: 'Pengaturan', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded),
  ];

  int _calculateSelectedIndex() {
    for (int i = 0; i < navItems.length; i++) {
      if (location.startsWith(navItems[i].path)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= 900;
    final selectedIndex = _calculateSelectedIndex();

    final userProfileAsync = ref.watch(userProfileProvider);
    final activeCafeState = ref.watch(activeCafeProvider);

    final namaUser = userProfileAsync.value?.namaLengkap ?? 'Staf Cafe';
    final peranUser = activeCafeState.activeCafe?.peranPegawai ?? userProfileAsync.value?.peran ?? 'Staf';
    final namaKafe = activeCafeState.activeCafe?.namaKafe ?? 'Kafe';

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar Navigation (Desktop)
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // App Brand Banner
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.coffee_rounded,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CafeFlow',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                namaKafe,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Navigation Menu Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: navItems.length,
                      itemBuilder: (context, index) {
                        final item = navItems[index];
                        final isSelected = selectedIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            dense: true,
                            selected: isSelected,
                            selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            leading: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected ? theme.colorScheme.primary : Colors.grey[700],
                              size: 20,
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? theme.colorScheme.primary : Colors.grey[800],
                                fontSize: 14,
                              ),
                            ),
                            onTap: () => context.go(item.path),
                          ),
                        );
                      },
                    ),
                  ),

                  // Profile & Logout Footer
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            namaUser.isNotEmpty ? namaUser[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaUser,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                peranUser.toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          onPressed: () {
                            ref.read(authNotifierProvider.notifier).signOut();
                          },
                          tooltip: 'Keluar Akun',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Desktop Content
            Expanded(
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          navItems[selectedIndex].label,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (activeCafeState.availableCafes.length > 1)
                          OutlinedButton.icon(
                            onPressed: () => context.go('/pilih-kafe'),
                            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                            label: Text(namaKafe),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_fire_department_rounded, color: Colors.amber[800], size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Mode Cafe Ramai Aktif',
                                style: TextStyle(
                                  color: Colors.amber[900],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                          tooltip: 'Notifikasi',
                        ),
                      ],
                    ),
                  ),
                ),
                body: child,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / Tablet Navigation Shell
    return Scaffold(
      appBar: AppBar(
        title: Text(navItems[selectedIndex].label),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(navItems[index].path),
        destinations: navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}
