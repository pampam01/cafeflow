import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/meja_model.dart';
import '../../sesi_meja/domain/sesi_meja_model.dart';
import '../../../core/config/supabase_config.dart';

class MejaRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Memuat daftar meja untuk kafe aktif
  Future<List<MejaModel>> fetchMejaList(String idKafe) async {
    try {
      final List<dynamic> response = await _supabase
          .from('data_meja')
          .select()
          .eq('id_kafe', idKafe)
          .order('urutan_tampilan', ascending: true)
          .order('nomor_meja', ascending: true);

      return response.map((json) => MejaModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('Error fetchMejaList: $e');
      return [];
    }
  }

  /// Memuat sesi meja aktif untuk kafe tertentu
  Future<List<SesiMejaModel>> fetchActiveSessions(String idKafe) async {
    try {
      final List<dynamic> response = await _supabase
          .from('data_sesi_meja')
          .select()
          .eq('id_kafe', idKafe)
          .eq('status_sesi', 'aktif');

      return response.map((json) => SesiMejaModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('Error fetchActiveSessions: $e');
      return [];
    }
  }

  /// Menambah meja baru
  Future<MejaModel> tambahMeja({
    required String idKafe,
    required String nomorMeja,
    String? namaMeja,
    required int kapasitas,
    int urutanTampilan = 0,
  }) async {
    final qrToken = 'CAF-$idKafe-${nomorMeja.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

    final data = {
      'id_kafe': idKafe,
      'nomor_meja': nomorMeja.trim().toUpperCase(),
      'nama_meja': namaMeja?.trim(),
      'kapasitas': kapasitas,
      'urutan_tampilan': urutanTampilan,
      'kode_qr': qrToken,
      'status_meja': 'tersedia',
      'status_aktif': true,
    };

    final response = await _supabase
        .from('data_meja')
        .insert(data)
        .select()
        .single();

    return MejaModel.fromJson(response);
  }

  /// Mengedit data meja
  Future<MejaModel> updateMeja(MejaModel meja) async {
    final response = await _supabase
        .from('data_meja')
        .update({
          'nomor_meja': meja.nomorMeja.trim().toUpperCase(),
          'nama_meja': meja.namaMeja?.trim(),
          'kapasitas': meja.kapasitas,
          'urutan_tampilan': meja.urutanTampilan,
          'status_meja': meja.statusMeja,
          'status_aktif': meja.statusAktif,
        })
        .eq('id_meja', meja.idMeja)
        .eq('id_kafe', meja.idKafe)
        .select()
        .single();

    return MejaModel.fromJson(response);
  }

  /// Toggle status_aktif (Soft Delete)
  Future<void> toggleStatusAktif(String idMeja, String idKafe, bool statusAktif) async {
    await _supabase
        .from('data_meja')
        .update({'status_aktif': statusAktif})
        .eq('id_meja', idMeja)
        .eq('id_kafe', idKafe);
  }

  /// Regenerate token QR Code aman
  Future<String> regenerateKodeQr(String idMeja, String idKafe, String nomorMeja) async {
    final newToken = 'CAF-$idKafe-${nomorMeja.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';
    await _supabase
        .from('data_meja')
        .update({'kode_qr': newToken})
        .eq('id_meja', idMeja)
        .eq('id_kafe', idKafe);
    return newToken;
  }

  /// Supabase Realtime Stream data_meja
  Stream<List<Map<String, dynamic>>> streamMeja(String idKafe) {
    try {
      return _supabase
          .from('data_meja')
          .stream(primaryKey: ['id_meja'])
          .eq('id_kafe', idKafe);
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Supabase Realtime Stream data_sesi_meja
  Stream<List<Map<String, dynamic>>> streamSesiMeja(String idKafe) {
    try {
      return _supabase
          .from('data_sesi_meja')
          .stream(primaryKey: ['id_sesi_meja'])
          .eq('id_kafe', idKafe);
    } catch (_) {
      return const Stream.empty();
    }
  }
}
