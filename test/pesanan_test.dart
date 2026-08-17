import 'package:flutter_test/flutter_test.dart';
import 'package:cafeflow/features/produk/domain/produk_model.dart';
import 'package:cafeflow/features/pesanan/domain/pesanan_model.dart';

void main() {
  group('Produk & Pesanan Domain Tests', () {
    test('ProdukModel.fromJson parsing data_produk', () {
      final json = {
        'id_produk': 'prod-123',
        'id_kafe': 'kafe-456',
        'nama_produk': 'Kopi Milk Espresso',
        'kategori': 'minuman',
        'harga': 28000.0,
        'deskripsi': 'Espresso nikmat dengan susu segar',
        'durasi_tambahan_menit': 15,
        'status_tersedia': true,
        'status_aktif': true,
      };

      final produk = ProdukModel.fromJson(json);

      expect(produk.idProduk, equals('prod-123'));
      expect(produk.namaProduk, equals('Kopi Milk Espresso'));
      expect(produk.kategori, equals('minuman'));
      expect(produk.harga, equals(28000.0));
      expect(produk.durasiTambahanMenit, equals(15));
      expect(produk.statusTersedia, isTrue);
    });

    test('PesananModel.fromJson parsing data_pesanan', () {
      final json = {
        'id_pesanan': 'order-123',
        'id_kafe': 'kafe-456',
        'id_meja': 'meja-789',
        'nomor_pesanan': 'CF-20260817-0001',
        'total_belanja': 56000.0,
        'status_pesanan': 'selesai',
        'waktu_pesanan': '2026-08-17T20:00:00Z',
        'data_meja': {'nomor_meja': 'M01'},
        'data_detail_pesanan': [
          {
            'id_detail_pesanan': 'dt-1',
            'id_produk': 'prod-123',
            'jumlah': 2,
            'harga_satuan': 28000.0,
            'subtotal': 56000.0,
            'catatan': 'Less ice',
            'data_produk': {'nama_produk': 'Kopi Milk Espresso'},
          }
        ],
      };

      final pesanan = PesananModel.fromJson(json);

      expect(pesanan.idPesanan, equals('order-123'));
      expect(pesanan.nomorPesanan, equals('CF-20260817-0001'));
      expect(pesanan.nomorMeja, equals('M01'));
      expect(pesanan.totalBelanja, equals(56000.0));
      expect(pesanan.items.length, equals(1));
      expect(pesanan.items.first.namaProduk, equals('Kopi Milk Espresso'));
      expect(pesanan.items.first.subtotal, equals(56000.0));
    });
  });
}
