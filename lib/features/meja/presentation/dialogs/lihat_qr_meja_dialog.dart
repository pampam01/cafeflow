import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _kodeQr = widget.meja.kodeQr ?? 'CFQR-${widget.meja.idKafe.substring(0, 8)}-${widget.meja.nomorMeja}';
  }

  String get _cleanToken {
    var t = _kodeQr.trim();
    if (t.contains('/m/')) {
      t = t.substring(t.lastIndexOf('/m/') + 3);
    }
    if (t.startsWith('/')) {
      t = t.substring(1);
    }
    return t;
  }

  /// Otomatis mendeteksi domain server saat ini (Localhost / Wi-Fi IP / Production Domain)
  String get _fullCustomerUrl {
    final baseOrigin = kIsWeb ? Uri.base.origin : 'https://cafeflow.app';
    return '$baseOrigin/#/m/$_cleanToken';
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

  void _copyFullUrl() {
    Clipboard.setData(ClipboardData(text: _fullCustomerUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link Alamat Lengkap ($_fullCustomerUrl) disalin ke clipboard.')),
    );
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(_fullCustomerUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _copyFullUrl();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullUrl = _fullCustomerUrl;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
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
            const SizedBox(height: 16),

            // QR Code Rendering (Auto-Encodes Full Executable Web Link)
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
                data: fullUrl,
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
            const SizedBox(height: 14),

            // Link URL Box (Displaying Full Scannable Address)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fullUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
                    tooltip: 'Salin Link Lengkap',
                    onPressed: _copyFullUrl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'Di-scan oleh HP pelanggan akan langsung membuka Halaman Pelanggan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Quick Action Buttons: Buka di Browser Baru, Copy Link, Reset QR
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _openInBrowser,
                    icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                    label: const Text('Buka Halaman Pelanggan di Tab Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyFullUrl,
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Salin Link'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isRegenerating ? null : _handleRegenerate,
                        icon: _isRegenerating
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reset QR'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
