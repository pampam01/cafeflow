import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/meja_model.dart';
import '../meja_provider.dart';

class LihatQrMejaDialog extends ConsumerStatefulWidget {
  final MejaModel meja;

  const LihatQrMejaDialog({
    super.key,
    required this.meja,
  });

  @override
  ConsumerState<LihatQrMejaDialog> createState() => _LihatQrMejaDialogState();
}

class _LihatQrMejaDialogState extends ConsumerState<LihatQrMejaDialog> {
  late String _kodeQr;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _kodeQr = widget.meja.kodeQr ?? 'CAF-${widget.meja.idKafe}-${widget.meja.nomorMeja}';
  }

  Future<void> _handleRegenerate() async {
    setState(() {
      _isRegenerating = true;
    });

    final newToken = await ref.read(mejaListProvider.notifier).regenerateQr(widget.meja.idMeja, widget.meja.nomorMeja);

    if (mounted) {
      setState(() {
        _isRegenerating = false;
        if (newToken != null) {
          _kodeQr = newToken;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token QR Code baru berhasil dibuat.')),
      );
    }
  }

  void _copyToken() {
    Clipboard.setData(ClipboardData(text: _kodeQr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token QR disalin ke clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR Code Meja ${widget.meja.nomorMeja}',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (widget.meja.namaMeja != null)
                      Text(
                        widget.meja.namaMeja!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // QR Rendering Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: _kodeQr,
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF5D4037),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF2C221E),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Pelanggan dapat memindai QR ini untuk membuka menu & self-order.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyToken,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Salin Token'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRegenerating ? null : _handleRegenerate,
                    icon: _isRegenerating
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Reset QR'),
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
