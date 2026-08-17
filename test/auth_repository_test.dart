import 'package:flutter_test/flutter_test.dart';
import 'package:cafeflow/features/autentikasi/domain/user_profile.dart';
import 'package:cafeflow/features/kafe/domain/cafe_model.dart';

void main() {
  group('Auth Domain & Model Parsing Tests', () {
    test('UserProfile.fromJson parsing data_pengguna', () {
      final json = {
        'id_pengguna': 'test-uuid-123',
        'id_kafe': 'kafe-uuid-456',
        'nama_lengkap': 'Budi Kasir',
        'email': 'budi@cafeflow.com',
        'peran': 'kasir',
        'status_aktif': true,
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.idPengguna, equals('test-uuid-123'));
      expect(profile.namaLengkap, equals('Budi Kasir'));
      expect(profile.email, equals('budi@cafeflow.com'));
      expect(profile.peran, equals('kasir'));
      expect(profile.statusAktif, isTrue);
    });

    test('CafeModel.fromJson parsing data_kafe', () {
      final json = {
        'id_kafe': 'kafe-uuid-456',
        'nama_kafe': 'CafeFlow Kopi Artisan',
        'alamat': 'Jl. Senopati No. 12',
        'nomor_telepon': '08123456789',
        'email_kafe': 'contact@cafeflow.com',
        'zona_waktu': 'Asia/Jakarta',
        'peran': 'manajer',
      };

      final cafe = CafeModel.fromJson(json);

      expect(cafe.idKafe, equals('kafe-uuid-456'));
      expect(cafe.namaKafe, equals('CafeFlow Kopi Artisan'));
      expect(cafe.peranPegawai, equals('manajer'));
      expect(cafe.zonaWaktu, equals('Asia/Jakarta'));
    });
  });
}
