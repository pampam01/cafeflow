import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class CustomerRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Memanggil fungsi RPC aman publik `get_public_meja_status`
  Future<Map<String, dynamic>> fetchPublicMejaStatus(String tokenQr) async {
    try {
      final response = await _supabase.rpc(
        'get_public_meja_status',
        params: {'p_kode_qr': tokenQr},
      );

      if (response != null && response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return {'valid': false, 'pesan': 'Respon server tidak valid.'};
    } catch (e) {
      debugPrint('Error fetchPublicMejaStatus: $e');
      return {'valid': false, 'pesan': 'Gagal terhubung ke server: $e'};
    }
  }
}
