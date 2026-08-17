import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';

class StrukPesananDialog extends StatelessWidget {
  final Map<String, dynamic> rpcResult;
  final String namaKafe;
  final String nomorMeja;

  const StrukPesananDialog({
    super.key,
    required this.rpcResult,
    required this.namaKafe,
    required this.nomorMeja,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPerpanjangan = rpcResult['is_perpanjangan'] as bool? ?? false;
    final nomorPesanan = rpcResult['nomor_pesanan'] as String? ?? 'CF-000';
    final totalBelanja = rpcResult['total_belanja'] is num
        ? (rpcResult['total_belanja'] as num).toDouble()
        : double.tryParse(rpcResult['total_belanja']?.toString() ?? '0') ?? 0.0;
    final durasiMenit = rpcResult['durasi_menit'] as int? ?? 60;
    final totalBelanjaSesi = rpcResult['total_belanja_sesi'] is num
        ? (rpcResult['total_belanja_sesi'] as num).toDouble()
        : totalBelanja;
    final waktuBerakhir = rpcResult['waktu_berakhir'] != null
        ? DateTime.parse(rpcResult['waktu_berakhir'].toString()).toLocal()
        : DateTime.now().add(Duration(minutes: durasiMenit));

    final formattedWaktuBerakhir = DateFormat('HH:mm').format(waktuBerakhir);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPerpanjangan ? Colors.blue[50] : Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPerpanjangan ? Icons.more_time_rounded : Icons.check_circle_rounded,
                color: isPerpanjangan ? Colors.blue[800] : Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              isPerpanjangan ? 'Pesanan Tambahan & Perpanjangan Sesi!' : 'Pesanan & Sesi Berhasil Dibuat!',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              namaKafe,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Struk Card Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF9F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _ReceiptRow(label: 'Nomor Pesanan', value: nomorPesanan, isBold: true),
                  const Divider(height: 16),
                  _ReceiptRow(label: 'Nomor Meja', value: 'Meja $nomorMeja', isBold: true),
                  const Divider(height: 16),
                  _ReceiptRow(
                    label: isPerpanjangan ? 'Total Pesanan Ini' : 'Total Belanja',
                    value: CurrencyFormatter.formatRupiah(totalBelanja),
                    isBold: true,
                  ),
                  if (isPerpanjangan) ...[
                    const SizedBox(height: 6),
                    _ReceiptRow(
                      label: 'Akumulasi Belanja Sesi',
                      value: CurrencyFormatter.formatRupiah(totalBelanjaSesi),
                      isBold: true,
                    ),
                  ],
                  const Divider(height: 16),
                  _ReceiptRow(
                    label: isPerpanjangan ? 'Tambahan Waktu' : 'Comfort Time Diperoleh',
                    value: '+$durasiMenit Menit',
                    valueColor: isPerpanjangan ? Colors.blue[900] : theme.colorScheme.primary,
                    isBold: true,
                  ),
                  const SizedBox(height: 6),
                  _ReceiptRow(
                    label: 'Berakhir Baru Pada',
                    value: '$formattedWaktuBerakhir WIB',
                    valueColor: Colors.amber[900],
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Tutup'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Cetak Struk'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black87,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
