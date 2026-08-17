import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi locale data Bahasa Indonesia (id_ID) untuk intl DateFormat
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase secara aman
  await SupabaseConfig.initialize();

  runApp(
    const ProviderScope(
      child: CafeFlowApp(),
    ),
  );
}

class CafeFlowApp extends ConsumerWidget {
  const CafeFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'CafeFlow - Comfort Time Cafe System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
