class MejaModel {
  final String idMeja;
  final String idKafe;
  final String nomorMeja;
  final String? namaMeja;
  final int kapasitas;
  final int urutanTampilan;
  final String? kodeQr;
  final String statusMeja; // 'tersedia', 'terisi', 'dipesan', 'nonaktif'
  final bool statusAktif;
  final DateTime? dibuatPada;
  final DateTime? diubahPada;

  const MejaModel({
    required this.idMeja,
    required this.idKafe,
    required this.nomorMeja,
    this.namaMeja,
    required this.kapasitas,
    this.urutanTampilan = 0,
    this.kodeQr,
    this.statusMeja = 'tersedia',
    this.statusAktif = true,
    this.dibuatPada,
    this.diubahPada,
  });

  factory MejaModel.fromJson(Map<String, dynamic> json) {
    return MejaModel(
      idMeja: json['id_meja'] as String,
      idKafe: json['id_kafe'] as String,
      nomorMeja: json['nomor_meja'] as String,
      namaMeja: json['nama_meja'] as String?,
      kapasitas: json['kapasitas'] is int ? json['kapasitas'] as int : int.tryParse(json['kapasitas'].toString()) ?? 2,
      urutanTampilan: json['urutan_tampilan'] is int ? json['urutan_tampilan'] as int : int.tryParse(json['urutan_tampilan']?.toString() ?? '0') ?? 0,
      kodeQr: json['kode_qr'] as String?,
      statusMeja: json['status_meja'] as String? ?? 'tersedia',
      statusAktif: json['status_aktif'] as bool? ?? true,
      dibuatPada: json['dibuat_pada'] != null ? DateTime.tryParse(json['dibuat_pada'].toString()) : null,
      diubahPada: json['diubah_pada'] != null ? DateTime.tryParse(json['diubah_pada'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_meja': idMeja,
      'id_kafe': idKafe,
      'nomor_meja': nomorMeja,
      'nama_meja': namaMeja,
      'kapasitas': kapasitas,
      'urutan_tampilan': urutanTampilan,
      'kode_qr': kodeQr,
      'status_meja': statusMeja,
      'status_aktif': statusAktif,
      if (dibuatPada != null) 'dibuat_pada': dibuatPada!.toIso8601String(),
      if (diubahPada != null) 'diubah_pada': diubahPada!.toIso8601String(),
    };
  }

  MejaModel copyWith({
    String? idMeja,
    String? idKafe,
    String? nomorMeja,
    String? namaMeja,
    int? kapasitas,
    int? urutanTampilan,
    String? kodeQr,
    String? statusMeja,
    bool? statusAktif,
    DateTime? dibuatPada,
    DateTime? diubahPada,
  }) {
    return MejaModel(
      idMeja: idMeja ?? this.idMeja,
      idKafe: idKafe ?? this.idKafe,
      nomorMeja: nomorMeja ?? this.nomorMeja,
      namaMeja: namaMeja ?? this.namaMeja,
      kapasitas: kapasitas ?? this.kapasitas,
      urutanTampilan: urutanTampilan ?? this.urutanTampilan,
      kodeQr: kodeQr ?? this.kodeQr,
      statusMeja: statusMeja ?? this.statusMeja,
      statusAktif: statusAktif ?? this.statusAktif,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diubahPada: diubahPada ?? this.diubahPada,
    );
  }
}
