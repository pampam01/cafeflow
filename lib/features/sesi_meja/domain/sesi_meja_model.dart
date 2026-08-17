enum StatusVisualMeja {
  tersedia,
  aktif,
  kurang15Menit,
  masaTenggang,
  melewatiWaktu,
  nonaktif,
}

class SesiMejaModel {
  final String idSesiMeja;
  final String idKafe;
  final String idMeja;
  final String? idPelanggan;
  final DateTime waktuMulai;
  final DateTime waktuBerakhir;
  final int durasiAwalMenit;
  final int totalDurasiMenit;
  final String statusSesi; // 'aktif', 'selesai', 'dibatalkan', 'kedaluwarsa'
  final double totalBelanja;
  final DateTime? dibuatPada;
  final DateTime? diubahPada;

  const SesiMejaModel({
    required this.idSesiMeja,
    required this.idKafe,
    required this.idMeja,
    this.idPelanggan,
    required this.waktuMulai,
    required this.waktuBerakhir,
    required this.durasiAwalMenit,
    required this.totalDurasiMenit,
    required this.statusSesi,
    this.totalBelanja = 0.0,
    this.dibuatPada,
    this.diubahPada,
  });

  factory SesiMejaModel.fromJson(Map<String, dynamic> json) {
    return SesiMejaModel(
      idSesiMeja: json['id_sesi_meja'] as String,
      idKafe: json['id_kafe'] as String,
      idMeja: json['id_meja'] as String,
      idPelanggan: json['id_pelanggan'] as String?,
      waktuMulai: DateTime.parse(json['waktu_mulai'].toString()).toLocal(),
      waktuBerakhir: DateTime.parse(json['waktu_berakhir'].toString()).toLocal(),
      durasiAwalMenit: json['durasi_awal_menit'] as int? ?? 60,
      totalDurasiMenit: json['total_durasi_menit'] as int? ?? 60,
      statusSesi: json['status_sesi'] as String? ?? 'aktif',
      totalBelanja: json['total_belanja'] is num
          ? (json['total_belanja'] as num).toDouble()
          : double.tryParse(json['total_belanja']?.toString() ?? '0') ?? 0.0,
      dibuatPada: json['dibuat_pada'] != null ? DateTime.tryParse(json['dibuat_pada'].toString()) : null,
      diubahPada: json['diubah_pada'] != null ? DateTime.tryParse(json['diubah_pada'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sesi_meja': idSesiMeja,
      'id_kafe': idKafe,
      'id_meja': idMeja,
      'id_pelanggan': idPelanggan,
      'waktu_mulai': waktuMulai.toIso8601String(),
      'waktu_berakhir': waktuBerakhir.toIso8601String(),
      'durasi_awal_menit': durasiAwalMenit,
      'total_durasi_menit': totalDurasiMenit,
      'status_sesi': statusSesi,
      'total_belanja': totalBelanja,
    };
  }

  /// Menghitung sisa durasi saat ini secara lokal di frontend
  Duration get sisaWaktu {
    final now = DateTime.now();
    return waktuBerakhir.difference(now);
  }

  /// Menghitung status visual berdasarkan waktu saat ini
  StatusVisualMeja getStatusVisual(bool isMejaAktif, String statusMeja) {
    if (!isMejaAktif || statusMeja == 'nonaktif') {
      return StatusVisualMeja.nonaktif;
    }
    if (statusSesi != 'aktif') {
      return StatusVisualMeja.tersedia;
    }

    final diff = sisaWaktu;
    if (diff.inSeconds > 900) {
      // Lebih dari 15 menit tersisa
      return StatusVisualMeja.aktif;
    } else if (diff.inSeconds > 0) {
      // Kurang dari 15 menit tersisa
      return StatusVisualMeja.kurang15Menit;
    } else if (diff.inSeconds >= -900) {
      // Masa tenggang (0 hingga -15 menit setelah waktu berakhir)
      return StatusVisualMeja.masaTenggang;
    } else {
      // Melewati waktu > 15 menit
      return StatusVisualMeja.melewatiWaktu;
    }
  }
}
