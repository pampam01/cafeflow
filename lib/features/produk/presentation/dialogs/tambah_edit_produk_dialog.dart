import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/produk_model.dart';
import '../produk_provider.dart';

class TambahEditProdukDialog extends ConsumerStatefulWidget {
  final ProdukModel? produkToEdit;

  const TambahEditProdukDialog({
    super.key,
    this.produkToEdit,
  });

  @override
  ConsumerState<TambahEditProdukDialog> createState() => _TambahEditProdukDialogState();
}

class _TambahEditProdukDialogState extends ConsumerState<TambahEditProdukDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _durasiController;
  late String _kategori;
  late bool _statusTersedia;
  bool _isLoading = false;

  bool get isEditing => widget.produkToEdit != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.produkToEdit?.namaProduk ?? '');
    _hargaController = TextEditingController(text: widget.produkToEdit?.harga.toStringAsFixed(0) ?? '');
    _deskripsiController = TextEditingController(text: widget.produkToEdit?.deskripsi ?? '');
    _durasiController = TextEditingController(text: widget.produkToEdit?.durasiTambahanMenit.toString() ?? '0');
    _kategori = widget.produkToEdit?.kategori ?? 'makanan';
    _statusTersedia = widget.produkToEdit?.statusTersedia ?? true;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _durasiController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final nama = _namaController.text.trim();
    final harga = double.tryParse(_hargaController.text) ?? 0.0;
    final deskripsi = _deskripsiController.text.trim();
    final durasi = int.tryParse(_durasiController.text) ?? 0;

    bool success;
    if (isEditing) {
      final updated = widget.produkToEdit!.copyWith(
        namaProduk: nama,
        kategori: _kategori,
        harga: harga,
        deskripsi: deskripsi.isEmpty ? null : deskripsi,
        durasiTambahanMenit: durasi,
        statusTersedia: _statusTersedia,
      );
      success = await ref.read(produkNotifierProvider.notifier).updateProduk(updated);
    } else {
      success = await ref.read(produkNotifierProvider.notifier).tambahProduk(
            namaProduk: nama,
            kategori: _kategori,
            harga: harga,
            deskripsi: deskripsi.isEmpty ? null : deskripsi,
            durasiTambahanMenit: durasi,
          );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan produk. Harap coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note_rounded : Icons.restaurant_menu_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Produk Menu' : 'Tambah Produk Baru',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nama Produk
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk *',
                  hintText: 'Contoh: Espresso Romano, Red Velvet Cake',
                  prefixIcon: Icon(Icons.fastfood_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  // Kategori Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _kategori,
                      decoration: const InputDecoration(
                        labelText: 'Kategori *',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'makanan', child: Text('Makanan')),
                        DropdownMenuItem(value: 'minuman', child: Text('Minuman')),
                        DropdownMenuItem(value: 'snack', child: Text('Snack / Camilan')),
                        DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _kategori = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Harga Produk
                  Expanded(
                    child: TextFormField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga (Rp) *',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (val) {
                        final numVal = double.tryParse(val ?? '');
                        if (numVal == null || numVal < 0) return 'Harga tidak valid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bonus Durasi Waktu Tambahan (Comfort Time)
              TextFormField(
                controller: _durasiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Bonus Durasi Tambahan (Menit)',
                  hintText: 'Contoh: 15 (Menambah +15 menit per item)',
                  prefixIcon: Icon(Icons.add_alarm_rounded),
                ),
              ),
              const SizedBox(height: 14),

              // Deskripsi Singkat
              TextFormField(
                controller: _deskripsiController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Produk (Opsional)',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Status Tersedia Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Status Ketersediaan Stok'),
                subtitle: Text(
                  _statusTersedia ? 'Stok Tersedia di Menu Kasir' : 'Stok Habis (Kosong)',
                  style: TextStyle(color: _statusTersedia ? Colors.green[800] : Colors.red[800], fontSize: 12),
                ),
                value: _statusTersedia,
                onChanged: (val) => setState(() => _statusTersedia = val),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isEditing ? 'Simpan Perubahan' : 'Tambah Produk'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
