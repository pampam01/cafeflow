import 'package:flutter_test/flutter_test.dart';
import 'package:cafeflow/features/meja/domain/meja_model.dart';
import 'package:cafeflow/features/sesi_meja/domain/sesi_meja_model.dart';
import 'package:cafeflow/features/dashboard/presentation/dashboard_provider.dart';

void main() {
  group('Dashboard Occupancy & Visual Status Tests', () {
    test('Perhitungan Okupansi 75% (3/4 Meja Aktif Digunakan)', () {
      final mejaList = [
        const MejaModel(idMeja: 'm1', idKafe: 'k1', nomorMeja: 'M01', kapasitas: 2, statusAktif: true),
        const MejaModel(idMeja: 'm2', idKafe: 'k1', nomorMeja: 'M02', kapasitas: 4, statusAktif: true),
        const MejaModel(idMeja: 'm3', idKafe: 'k1', nomorMeja: 'M03', kapasitas: 2, statusAktif: true),
        const MejaModel(idMeja: 'm4', idKafe: 'k1', nomorMeja: 'M04', kapasitas: 6, statusAktif: true),
        const MejaModel(idMeja: 'm5', idKafe: 'k1', nomorMeja: 'M05', kapasitas: 2, statusAktif: false), // Soft deleted
      ];

      final now = DateTime.now();
      final sessionsMap = {
        'm1': SesiMejaModel(
          idSesiMeja: 's1', idKafe: 'k1', idMeja: 'm1',
          waktuMulai: now.subtract(const Duration(minutes: 20)),
          waktuBerakhir: now.add(const Duration(minutes: 40)),
          durasiAwalMenit: 60, totalDurasiMenit: 60, statusSesi: 'aktif',
        ),
        'm2': SesiMejaModel(
          idSesiMeja: 's2', idKafe: 'k1', idMeja: 'm2',
          waktuMulai: now.subtract(const Duration(minutes: 50)),
          waktuBerakhir: now.add(const Duration(minutes: 10)),
          durasiAwalMenit: 60, totalDurasiMenit: 60, statusSesi: 'aktif',
        ),
        'm3': SesiMejaModel(
          idSesiMeja: 's3', idKafe: 'k1', idMeja: 'm3',
          waktuMulai: now.subtract(const Duration(minutes: 70)),
          waktuBerakhir: now.subtract(const Duration(minutes: 10)),
          durasiAwalMenit: 60, totalDurasiMenit: 60, statusSesi: 'aktif',
        ),
      };

      final state = DashboardState(
        mejaList: mejaList,
        activeSessionsByMejaId: sessionsMap,
        currentTime: now,
      );

      expect(state.totalMejaAktif, equals(4));
      expect(state.mejaTerisi, equals(3));
      expect(state.mejaTersedia, equals(1));
      expect(state.persentaseOkupansi, equals(75.0));
    });

    test('Penentuan StatusVisualMeja berdasarkan sisa waktu', () {
      final now = DateTime.now();

      final sesiLebih15 = SesiMejaModel(
        idSesiMeja: 's1', idKafe: 'k1', idMeja: 'm1',
        waktuMulai: now,
        waktuBerakhir: now.add(const Duration(minutes: 30)),
        durasiAwalMenit: 60, totalDurasiMenit: 60, statusSesi: 'aktif',
      );

      final sesiKurang15 = SesiMejaModel(
        idSesiMeja: 's2', idKafe: 'k1', idMeja: 'm2',
        waktuMulai: now,
        waktuBerakhir: now.add(const Duration(minutes: 10)),
        durasiAwalMenit: 60, totalDurasiMenit: 60, statusSesi: 'aktif',
      );

      final sesiTenggang = SesiMejaModel(
        idSesiMeja: 's3', idKafe: 'k1', idMeja: 'm3',
        waktuMulai: now.subtract(const Duration(minutes: 65)),
        waktuBerakhir: now.subtract(const Duration(minutes: 5)),
        durasiAwalMenit: 60, totalDurasiMenit: 60, statusSesi: 'aktif',
      );

      final sesiWaktuHabis = SesiMejaModel(
        idSesiMeja: 's4', idKafe: 'k1', idMeja: 'm4',
        waktuMulai: now.subtract(const Duration(minutes: 90)),
        waktuBerakhir: now.subtract(const Duration(minutes: 30)),
        durasiAwalMenit: 60, totalDurasiMenit: 60, statusSesi: 'aktif',
      );

      expect(sesiLebih15.getStatusVisual(true, 'terisi'), equals(StatusVisualMeja.aktif));
      expect(sesiKurang15.getStatusVisual(true, 'terisi'), equals(StatusVisualMeja.kurang15Menit));
      expect(sesiTenggang.getStatusVisual(true, 'terisi'), equals(StatusVisualMeja.masaTenggang));
      expect(sesiWaktuHabis.getStatusVisual(true, 'terisi'), equals(StatusVisualMeja.melewatiWaktu));
    });
  });
}
