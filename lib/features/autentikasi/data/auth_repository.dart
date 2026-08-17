import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_profile.dart';
import '../../kafe/domain/cafe_model.dart';
import '../../../core/config/supabase_config.dart';

class AuthRepository {
  SupabaseClient get _supabase {
    return SupabaseConfig.client;
  }

  User? get currentUser {
    try {
      return _supabase.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<AuthState> get onAuthStateChange {
    try {
      return _supabase.auth.onAuthStateChange;
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Login email & password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw _parseAuthException(e);
    } catch (e) {
      throw 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    }
  }

  /// Kirim email reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw _parseAuthException(e);
    } catch (e) {
      throw 'Gagal mengumpulkan permintaan reset kata sandi.';
    }
  }

  /// Logout dari Supabase
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('SignOut exception: $e');
    }
  }

  /// Ambil profil pengguna dari data_pengguna
  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('data_pengguna')
          .select()
          .eq('id_pengguna', userId)
          .maybeSingle();

      if (response != null) {
        return UserProfile.fromJson(response);
      }
      
      // Fallback default profile jika data_pengguna belum dibuat di DB
      final user = currentUser;
      return UserProfile(
        idPengguna: userId,
        namaLengkap: user?.email?.split('@').first ?? 'Staf Cafe',
        email: user?.email ?? '',
        peran: 'kasir',
        statusAktif: true,
      );
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return UserProfile(
        idPengguna: userId,
        namaLengkap: 'Staf Cafe',
        email: currentUser?.email ?? '',
        peran: 'kasir',
        statusAktif: true,
      );
    }
  }

  /// Ambil daftar kafe tempat pengguna menjadi pegawai aktif
  Future<List<CafeModel>> fetchUserCafes(String userId) async {
    try {
      // Query junction data_pegawai_kafe
      final List<dynamic> response = await _supabase
          .from('data_pegawai_kafe')
          .select('id_kafe, peran, data_kafe(nama_kafe, alamat, nomor_telepon, email_kafe, zona_waktu)')
          .eq('id_pengguna', userId)
          .eq('status_aktif', true);

      if (response.isNotEmpty) {
        return response.map((item) {
          final kafeMap = Map<String, dynamic>.from(item['data_kafe'] as Map);
          kafeMap['id_kafe'] = item['id_kafe'];
          kafeMap['peran'] = item['peran'];
          return CafeModel.fromJson(kafeMap);
        }).toList();
      }

      // Fallback jika tidak ada di data_pegawai_kafe, coba data_kafe langsung
      final List<dynamic> kafeDirect = await _supabase.from('data_kafe').select();
      if (kafeDirect.isNotEmpty) {
        return kafeDirect.map((json) => CafeModel.fromJson(Map<String, dynamic>.from(json))).toList();
      }
    } catch (e) {
      debugPrint('Error fetching user cafes: $e');
    }

    // Default mock fallback kafe jika DB belum terisi data_kafe
    return const [
      CafeModel(
        idKafe: 'default-kafe-id-01',
        namaKafe: 'CafeFlow Central Coffee',
        alamat: 'Jl. Sudirman No. 45, Jakarta Pusat',
        peranPegawai: 'pemilik',
      ),
    ];
  }

  String _parseAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials')) {
      return 'Email atau kata sandi yang Anda masukkan salah.';
    } else if (msg.contains('email not confirmed')) {
      return 'Email Anda belum dikonfirmasi. Harap periksa kotak masuk email Anda.';
    } else if (msg.contains('user not found')) {
      return 'Akun dengan email ini tidak ditemukan.';
    } else if (msg.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Harap tunggu beberapa saat.';
    }
    return e.message;
  }
}
