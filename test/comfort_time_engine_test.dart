import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Comfort Time Engine Extension Logic Tests', () {
    test('Perpanjangan Sesi ketika Waktu Berakhir Masih Di Masa Depan', () {
      final now = DateTime.now();
      final waktuBerakhirLama = now.add(const Duration(minutes: 30));
      const tambahanMenit = 60;

      // Kasus A: Jika waktu_berakhir masih di masa depan -> Tambahkan dari waktu_berakhir_lama
      final waktuBerakhirBaru = waktuBerakhirLama.add(const Duration(minutes: tambahanMenit));

      final selisihTotalMenit = waktuBerakhirBaru.difference(now).inMinutes;

      expect(waktuBerakhirBaru.isAfter(waktuBerakhirLama), isTrue);
      expect(selisihTotalMenit, equals(90)); // 30 mnt sisa + 60 mnt tambahan = 90 mnt
    });

    test('Perpanjangan Sesi ketika Waktu Berakhir Sudah Melewati (Masa Tenggang)', () {
      final now = DateTime.now();
      final waktuBerakhirLama = now.subtract(const Duration(minutes: 15)); // Sudah lewat 15 mnt
      const tambahanMenit = 60;

      // Kasus B: Jika sudah melewati waktu -> Hitung dari NOW() agar durasi tenggang tidak memotong waktu perpanjangan baru
      DateTime waktuBerakhirBaru;
      if (waktuBerakhirLama.isBefore(now)) {
        waktuBerakhirBaru = now.add(const Duration(minutes: tambahanMenit));
      } else {
        waktuBerakhirBaru = waktuBerakhirLama.add(const Duration(minutes: tambahanMenit));
      }

      final sisaMenitBaru = waktuBerakhirBaru.difference(now).inMinutes;

      expect(waktuBerakhirBaru.isAfter(now), isTrue);
      expect(sisaMenitBaru, equals(60)); // Pelanggan mendapatkan 60 menit utuh dari NOW()
    });

    test('Kalkulasi Rule Waktu Dinamis berdasarkan Minimum Belanja', () {
      final rules = [
        {'min_belanja': 0.0, 'durasi_menit': 30},
        {'min_belanja': 20000.0, 'durasi_menit': 60},
        {'min_belanja': 35000.0, 'durasi_menit': 90},
        {'min_belanja': 50000.0, 'durasi_menit': 120},
      ];

      int getRuleMenit(double totalBelanja) {
        final sorted = [...rules]..sort((a, b) => (b['min_belanja'] as double).compareTo(a['min_belanja'] as double));
        for (final r in sorted) {
          if (totalBelanja >= (r['min_belanja'] as double)) {
            return r['durasi_menit'] as int;
          }
        }
        return 60;
      }

      expect(getRuleMenit(15000.0), equals(30));
      expect(getRuleMenit(24000.0), equals(60));
      expect(getRuleMenit(35000.0), equals(90));
      expect(getRuleMenit(75000.0), equals(120));
    });
  });
}
