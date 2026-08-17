import 'package:flutter_test/flutter_test.dart';
import 'package:cafeflow/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('Format angka ke Rupiah standar', () {
      expect(CurrencyFormatter.formatRupiah(25000), contains('25.000'));
      expect(CurrencyFormatter.formatRupiah(0), contains('0'));
      expect(CurrencyFormatter.formatRupiah(null), contains('0'));
    });
  });
}
