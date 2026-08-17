class CafeModel {
  final String idKafe;
  final String namaKafe;
  final String? alamat;
  final String? nomorTelepon;
  final String? emailKafe;
  final String zonaWaktu;
  final String peranPegawai;

  const CafeModel({
    required this.idKafe,
    required this.namaKafe,
    this.alamat,
    this.nomorTelepon,
    this.emailKafe,
    this.zonaWaktu = 'Asia/Jakarta',
    this.peranPegawai = 'kasir',
  });

  factory CafeModel.fromJson(Map<String, dynamic> json, {String defaultPeran = 'kasir'}) {
    return CafeModel(
      idKafe: json['id_kafe'] as String,
      namaKafe: json['nama_kafe'] as String? ?? 'Kafe',
      alamat: json['alamat'] as String?,
      nomorTelepon: json['nomor_telepon'] as String?,
      emailKafe: json['email_kafe'] as String?,
      zonaWaktu: json['zona_waktu'] as String? ?? 'Asia/Jakarta',
      peranPegawai: json['peran'] as String? ?? defaultPeran,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kafe': idKafe,
      'nama_kafe': namaKafe,
      'alamat': alamat,
      'nomor_telepon': nomorTelepon,
      'email_kafe': emailKafe,
      'zona_waktu': zonaWaktu,
      'peran': peranPegawai,
    };
  }
}
