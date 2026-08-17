import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compactRupiahFormat = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );

  /// Format angka ke Rupiah standar, misal: Rp 45.000
  static String formatRupiah(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final number = amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
    return _rupiahFormat.format(number);
  }

  /// Format angka ke Rupiah ringkas, misal: Rp 1.5jt
  static String formatRupiahRingkas(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final number = amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
    return _compactRupiahFormat.format(number);
  }
}
