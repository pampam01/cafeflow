class ProdukModel {
  final String idProduk;
  final String idKafe;
  final String namaProduk;
  final String kategori; // 'makanan', 'minuman', 'snack', 'lainnya'
  final double harga;
  final String? deskripsi;
  final int durasiTambahanMenit;
  final bool statusTersedia;
  final bool statusAktif;
  final DateTime? dibuatPada;
  final DateTime? diubahPada;

  const ProdukModel({
    required this.idProduk,
    required this.idKafe,
    required this.namaProduk,
    this.kategori = 'makanan',
    required this.harga,
    this.deskripsi,
    this.durasiTambahanMenit = 0,
    this.statusTersedia = true,
    this.statusAktif = true,
    this.dibuatPada,
    this.diubahPada,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      idProduk: json['id_produk'] as String,
      idKafe: json['id_kafe'] as String,
      namaProduk: json['nama_produk'] as String? ?? 'Produk',
      kategori: json['kategori'] as String? ?? 'makanan',
      harga: json['harga'] is num
          ? (json['harga'] as num).toDouble()
          : double.tryParse(json['harga']?.toString() ?? '0') ?? 0.0,
      deskripsi: json['deskripsi'] as String?,
      durasiTambahanMenit: json['durasi_tambahan_menit'] as int? ?? 0,
      statusTersedia: json['status_tersedia'] as bool? ?? true,
      statusAktif: json['status_aktif'] as bool? ?? true,
      dibuatPada: json['dibuat_pada'] != null ? DateTime.tryParse(json['dibuat_pada'].toString()) : null,
      diubahPada: json['diubah_pada'] != null ? DateTime.tryParse(json['diubah_pada'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': idProduk,
      'id_kafe': idKafe,
      'nama_produk': namaProduk,
      'kategori': kategori,
      'harga': harga,
      'deskripsi': deskripsi,
      'durasi_tambahan_menit': durasiTambahanMenit,
      'status_tersedia': statusTersedia,
      'status_aktif': statusAktif,
    };
  }

  ProdukModel copyWith({
    String? idProduk,
    String? idKafe,
    String? namaProduk,
    String? kategori,
    double? harga,
    String? deskripsi,
    int? durasiTambahanMenit,
    bool? statusTersedia,
    bool? statusAktif,
  }) {
    return ProdukModel(
      idProduk: idProduk ?? this.idProduk,
      idKafe: idKafe ?? this.idKafe,
      namaProduk: namaProduk ?? this.namaProduk,
      kategori: kategori ?? this.kategori,
      harga: harga ?? this.harga,
      deskripsi: deskripsi ?? this.deskripsi,
      durasiTambahanMenit: durasiTambahanMenit ?? this.durasiTambahanMenit,
      statusTersedia: statusTersedia ?? this.statusTersedia,
      statusAktif: statusAktif ?? this.statusAktif,
      dibuatPada: dibuatPada,
      diubahPada: diubahPada,
    );
  }
}
