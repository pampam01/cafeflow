class DetailPesananModel {
  final String? idDetailPesanan;
  final String? idPesanan;
  final String idProduk;
  final String? namaProduk;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;
  final String? catatan;

  const DetailPesananModel({
    this.idDetailPesanan,
    this.idPesanan,
    required this.idProduk,
    this.namaProduk,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
    this.catatan,
  });

  factory DetailPesananModel.fromJson(Map<String, dynamic> json) {
    final produk = json['data_produk'] as Map<String, dynamic>?;

    return DetailPesananModel(
      idDetailPesanan: json['id_detail_pesanan'] as String?,
      idPesanan: json['id_pesanan'] as String?,
      idProduk: json['id_produk'] as String,
      namaProduk: produk != null ? produk['nama_produk'] as String? : json['nama_produk'] as String?,
      jumlah: json['jumlah'] as int? ?? 1,
      hargaSatuan: json['harga_satuan'] is num
          ? (json['harga_satuan'] as num).toDouble()
          : double.tryParse(json['harga_satuan']?.toString() ?? '0') ?? 0.0,
      subtotal: json['subtotal'] is num
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      catatan: json['catatan'] as String?,
    );
  }

  Map<String, dynamic> toJsonForRpc() {
    return {
      'id_produk': idProduk,
      'jumlah': jumlah,
      if (catatan != null && catatan!.isNotEmpty) 'catatan': catatan,
    };
  }
}

class PesananModel {
  final String idPesanan;
  final String idKafe;
  final String? idMeja;
  final String? nomorMeja;
  final String? idSesiMeja;
  final String nomorPesanan;
  final double totalBelanja;
  final String statusPesanan; // 'pending', 'diproses', 'selesai', 'dibatalkan'
  final DateTime waktuPesanan;
  final List<DetailPesananModel> items;

  const PesananModel({
    required this.idPesanan,
    required this.idKafe,
    this.idMeja,
    this.nomorMeja,
    this.idSesiMeja,
    required this.nomorPesanan,
    required this.totalBelanja,
    required this.statusPesanan,
    required this.waktuPesanan,
    this.items = const [],
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    final meja = json['data_meja'] as Map<String, dynamic>?;
    final itemsRaw = json['data_detail_pesanan'] as List<dynamic>?;

    return PesananModel(
      idPesanan: json['id_pesanan'] as String,
      idKafe: json['id_kafe'] as String,
      idMeja: json['id_meja'] as String?,
      nomorMeja: meja != null ? meja['nomor_meja'] as String? : json['nomor_meja'] as String?,
      idSesiMeja: json['id_sesi_meja'] as String?,
      nomorPesanan: json['nomor_pesanan'] as String? ?? 'CF-000',
      totalBelanja: json['total_belanja'] is num
          ? (json['total_belanja'] as num).toDouble()
          : double.tryParse(json['total_belanja']?.toString() ?? '0') ?? 0.0,
      statusPesanan: json['status_pesanan'] as String? ?? 'selesai',
      waktuPesanan: DateTime.parse(json['waktu_pesanan'].toString()).toLocal(),
      items: itemsRaw != null
          ? itemsRaw.map((i) => DetailPesananModel.fromJson(Map<String, dynamic>.from(i))).toList()
          : const [],
    );
  }
}
