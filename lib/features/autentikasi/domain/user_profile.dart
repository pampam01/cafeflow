class UserProfile {
  final String idPengguna;
  final String? idKafe;
  final String namaLengkap;
  final String email;
  final String peran;
  final bool statusAktif;
  final DateTime? dibuatPada;
  final DateTime? diubahPada;

  const UserProfile({
    required this.idPengguna,
    this.idKafe,
    required this.namaLengkap,
    required this.email,
    required this.peran,
    required this.statusAktif,
    this.dibuatPada,
    this.diubahPada,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      idPengguna: json['id_pengguna'] as String,
      idKafe: json['id_kafe'] as String?,
      namaLengkap: json['nama_lengkap'] as String? ?? 'Pengguna',
      email: json['email'] as String? ?? '',
      peran: json['peran'] as String? ?? 'kasir',
      statusAktif: json['status_aktif'] as bool? ?? true,
      dibuatPada: json['dibuat_pada'] != null ? DateTime.tryParse(json['dibuat_pada']) : null,
      diubahPada: json['diubah_pada'] != null ? DateTime.tryParse(json['diubah_pada']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'id_kafe': idKafe,
      'nama_lengkap': namaLengkap,
      'email': email,
      'peran': peran,
      'status_aktif': statusAktif,
      'dibuat_pada': dibuatPada?.toIso8601String(),
      'diubah_pada': diubahPada?.toIso8601String(),
    };
  }
}
