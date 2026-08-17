import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Supabase dengan penanganan aman
  await SupabaseConfig.initialize();

  runApp(
    const ProviderScope(
      child: CafeFlowApp(),
    ),
  );
}

class CafeFlowApp extends StatelessWidget {
  const CafeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CafeFlow - Comfort Time Cafe System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
