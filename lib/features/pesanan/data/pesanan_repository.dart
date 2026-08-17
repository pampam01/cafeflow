import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/pesanan_model.dart';
import '../../../core/config/supabase_config.dart';

class PesananRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Memanggil fungsi RPC atomik `buat_pesanan_awal_dan_mulai_sesi`
  Future<Map<String, dynamic>> buatPesananAwalRpc({
    required String idKafe,
    required String idMeja,
    String? idPelanggan,
    required List<DetailPesananModel> items,
  }) async {
    final payload = items.map((i) => i.toJsonForRpc()).toList();

    try {
      final response = await _supabase.rpc(
        'buat_pesanan_awal_dan_mulai_sesi',
        params: {
          'p_id_kafe': idKafe,
          'p_id_meja': idMeja,
          'p_id_pelanggan': idPelanggan,
          'p_items': payload,
        },
      );

      if (response != null && response is Map) {
        return Map<String, dynamic>.from(response);
      }
      throw 'Respon transaksi atomik tidak valid';
    } catch (e) {
      debugPrint('Error buatPesananAwalRpc: $e');
      rethrow;
    }
  }

  /// Memanggil fungsi RPC atomik `tambah_pesanan_dan_perpanjang_sesi` untuk order tambahan
  Future<Map<String, dynamic>> tambahPesananDanPerpanjangSesiRpc({
    required String idKafe,
    required String idMeja,
    required String idSesiMeja,
    required List<DetailPesananModel> items,
  }) async {
    final payload = items.map((i) => i.toJsonForRpc()).toList();

    try {
      final response = await _supabase.rpc(
        'tambah_pesanan_dan_perpanjang_sesi',
        params: {
          'p_id_kafe': idKafe,
          'p_id_meja': idMeja,
          'p_id_sesi_meja': idSesiMeja,
          'p_items': payload,
        },
      );

      if (response != null && response is Map) {
        return Map<String, dynamic>.from(response);
      }
      throw 'Respon perpanjangan sesi atomik tidak valid';
    } catch (e) {
      debugPrint('Error tambahPesananDanPerpanjangSesiRpc: $e');
      rethrow;
    }
  }

  /// Memuat riwayat pesanan kafe
  Future<List<PesananModel>> fetchPesananList(String idKafe) async {
    try {
      final List<dynamic> response = await _supabase
          .from('data_pesanan')
          .select(
            '*, data_meja(nomor_meja), data_detail_pesanan(*, data_produk(nama_produk))',
          )
          .eq('id_kafe', idKafe)
          .order('waktu_pesanan', ascending: false);

      return response
          .map((json) => PesananModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error fetchPesananList: $e');
      return [];
    }
  }
}
