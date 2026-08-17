import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_responsive_layout.dart';
import '../../features/autentikasi/domain/auth_state.dart';
import '../../features/autentikasi/presentation/auth_provider.dart';
import '../../features/autentikasi/presentation/login_page.dart';
import '../../features/kafe/presentation/active_cafe_provider.dart';
import '../../features/kafe/presentation/pilih_kafe_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/sesi_meja/presentation/sesi_meja_page.dart';
import '../../features/meja/presentation/meja_page.dart';
import '../../features/produk/presentation/produk_page.dart';
import '../../features/pesanan/presentation/pesanan_page.dart';
import '../../features/pelanggan/presentation/pelanggan_page.dart';
import '../../features/analitik/presentation/analitik_page.dart';
import '../../features/pengaturan/presentation/pengaturan_page.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authNotifierProvider, (_, __) => notifyListeners());
    _ref.listen<ActiveCafeState>(activeCafeProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final activeCafeState = _ref.read(activeCafeProvider);

    final isLoggingIn = state.uri.toString() == '/login';
    final isSelectingCafe = state.uri.toString() == '/pilih-kafe';

    // 1. Jika belum login -> Arahkan ke /login jika mencoba mengakses route terproteksi
    if (!authState.isAuthenticated) {
      return isLoggingIn ? null : '/login';
    }

    // 2. Jika sudah terautentikasi tetapi belum memilih kafe aktif (pegawai multi-kafe)
    if (activeCafeState.needsSelection && !isSelectingCafe) {
      return '/pilih-kafe';
    }

    // 3. Jika sudah login & kafe aktif terpilih, tetapi berada di /login atau /pilih-kafe -> Arahkan ke /dashboard
    if (isLoggingIn || (isSelectingCafe && activeCafeState.hasActiveCafe)) {
      return '/dashboard';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/pilih-kafe',
        builder: (context, state) => const PilihKafePage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppResponsiveLayout(
            location: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/sesi-meja',
            builder: (context, state) => const SesiMejaPage(),
          ),
          GoRoute(
            path: '/meja',
            builder: (context, state) => const MejaPage(),
          ),
          GoRoute(
            path: '/produk',
            builder: (context, state) => const ProdukPage(),
          ),
          GoRoute(
            path: '/pesanan',
            builder: (context, state) => const PesananPage(),
          ),
          GoRoute(
            path: '/pelanggan',
            builder: (context, state) => const PelangganPage(),
          ),
          GoRoute(
            path: '/analitik',
            builder: (context, state) => const AnalitikPage(),
          ),
          GoRoute(
            path: '/pengaturan',
            builder: (context, state) => const PengaturanPage(),
          ),
        ],
      ),
    ],
  );
});
