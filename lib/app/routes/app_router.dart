import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_responsive_layout.dart';
import '../../features/autentikasi/presentation/login_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/sesi_meja/presentation/sesi_meja_page.dart';
import '../../features/meja/presentation/meja_page.dart';
import '../../features/produk/presentation/produk_page.dart';
import '../../features/pesanan/presentation/pesanan_page.dart';
import '../../features/pelanggan/presentation/pelanggan_page.dart';
import '../../features/analitik/presentation/analitik_page.dart';
import '../../features/pengaturan/presentation/pengaturan_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
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
}
