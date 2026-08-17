import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    // Attempt loading .env if available
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Warning: Could not load .env file, falling back to default/environment configuration.");
    }

    final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 
        const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://placeholder.supabase.co');
    final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 
        const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'placeholder-anon-key');

    // Only initialize Supabase if valid URL & Key are present
    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty && !supabaseUrl.contains('placeholder')) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
    } else {
      debugPrint("Supabase initial setup: Using local mock mode until valid credentials are configured in .env");
    }
  }

  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError("SupabaseClient belum diinisialisasi dengan URL dan Anon Key yang valid.");
    }
  }
}
