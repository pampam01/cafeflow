import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/produk_model.dart';
import '../../../core/config/supabase_config.dart';

class ProdukRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Memuat daftar produk untuk kafe tertentu
  Future<List<ProdukModel>> fetchProdukList(String idKafe) async {
    try {
      final List<dynamic> response = await _supabase
          .from('data_produk')
          .select()
          .eq('id_kafe', idKafe)
          .order('kategori', ascending: true)
          .order('nama_produk', ascending: true);

      return response.map((json) => ProdukModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('Error fetchProdukList: $e');
      return [];
    }
  }

  /// Menambah produk baru
  Future<ProdukModel> tambahProduk({
    required String idKafe,
    required String namaProduk,
    required String kategori,
    required double harga,
    String? deskripsi,
    int durasiTambahanMenit = 0,
    bool statusTersedia = true,
  }) async {
    final data = {
      'id_kafe': idKafe,
      'nama_produk': namaProduk.trim(),
      'kategori': kategori,
      'harga': harga,
      'deskripsi': deskripsi?.trim(),
      'durasi_tambahan_menit': durasiTambahanMenit,
      'status_tersedia': statusTersedia,
      'status_aktif': true,
    };

    final response = await _supabase
        .from('data_produk')
        .insert(data)
        .select()
        .single();

    return ProdukModel.fromJson(response);
  }

  /// Mengedit data produk
  Future<ProdukModel> updateProduk(ProdukModel produk) async {
    final response = await _supabase
        .from('data_produk')
        .update({
          'nama_produk': produk.namaProduk.trim(),
          'kategori': produk.kategori,
          'harga': produk.harga,
          'deskripsi': produk.deskripsi?.trim(),
          'durasi_tambahan_menit': produk.durasiTambahanMenit,
          'status_tersedia': produk.statusTersedia,
          'status_aktif': produk.statusAktif,
        })
        .eq('id_produk', produk.idProduk)
        .eq('id_kafe', produk.idKafe)
        .select()
        .single();

    return ProdukModel.fromJson(response);
  }

  /// Toggle status_aktif (Soft Delete)
  Future<void> toggleStatusAktif(String idProduk, String idKafe, bool statusAktif) async {
    await _supabase
        .from('data_produk')
        .update({'status_aktif': statusAktif})
        .eq('id_produk', idProduk)
        .eq('id_kafe', idKafe);
  }

  /// Toggle status_tersedia (Stok Tersedia / Habis)
  Future<void> toggleStatusTersedia(String idProduk, String idKafe, bool statusTersedia) async {
    await _supabase
        .from('data_produk')
        .update({'status_tersedia': statusTersedia})
        .eq('id_produk', idProduk)
        .eq('id_kafe', idKafe);
  }
}
