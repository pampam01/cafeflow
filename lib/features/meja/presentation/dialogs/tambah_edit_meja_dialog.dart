import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/meja_model.dart';
import '../meja_provider.dart';

class TambahEditMejaDialog extends ConsumerStatefulWidget {
  final MejaModel? mejaToEdit;

  const TambahEditMejaDialog({
    super.key,
    this.mejaToEdit,
  });

  @override
  ConsumerState<TambahEditMejaDialog> createState() => _TambahEditMejaDialogState();
}

class _TambahEditMejaDialogState extends ConsumerState<TambahEditMejaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomorMejaController;
  late TextEditingController _namaMejaController;
  late TextEditingController _kapasitasController;
  late TextEditingController _urutanController;
  bool _isLoading = false;

  bool get isEditing => widget.mejaToEdit != null;

  @override
  void initState() {
    super.initState();
    _nomorMejaController = TextEditingController(text: widget.mejaToEdit?.nomorMeja ?? '');
    _namaMejaController = TextEditingController(text: widget.mejaToEdit?.namaMeja ?? '');
    _kapasitasController = TextEditingController(text: widget.mejaToEdit?.kapasitas.toString() ?? '2');
    _urutanController = TextEditingController(text: widget.mejaToEdit?.urutanTampilan.toString() ?? '0');
  }

  @override
  void dispose() {
    _nomorMejaController.dispose();
    _namaMejaController.dispose();
    _kapasitasController.dispose();
    _urutanController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final nomor = _nomorMejaController.text.trim();
    final nama = _namaMejaController.text.trim();
    final kapasitas = int.tryParse(_kapasitasController.text) ?? 2;
    final urutan = int.tryParse(_urutanController.text) ?? 0;

    bool success;
    if (isEditing) {
      final updated = widget.mejaToEdit!.copyWith(
        nomorMeja: nomor,
        namaMeja: nama.isEmpty ? null : nama,
        kapasitas: kapasitas,
        urutanTampilan: urutan,
      );
      success = await ref.read(mejaListProvider.notifier).updateMeja(updated);
    } else {
      success = await ref.read(mejaListProvider.notifier).tambahMeja(
            nomorMeja: nomor,
            namaMeja: nama.isEmpty ? null : nama,
            kapasitas: kapasitas,
            urutanTampilan: urutan,
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
            content: Text('Gagal menyimpan meja. Pastikan nomor meja belum terpakai.'),
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
        constraints: const BoxConstraints(maxWidth: 420),
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
                      isEditing ? Icons.edit_outlined : Icons.add_business_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Meja Kafe' : 'Tambah Meja Baru',
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

              // Nomor Meja (Contoh: M01, M02)
              TextFormField(
                controller: _nomorMejaController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kode Meja *',
                  hintText: 'Contoh: M01, M02',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode/Nomor meja wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Nama Meja (Opsional: Sofa Depan, Outdoor 2)
              TextFormField(
                controller: _namaMejaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Meja (Opsional)',
                  hintText: 'Contoh: Meja Sofa VIP, Outdoor 02',
                  prefixIcon: Icon(Icons.table_restaurant_outlined),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  // Kapasitas Meja
                  Expanded(
                    child: TextFormField(
                      controller: _kapasitasController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kapasitas (Orang) *',
                        prefixIcon: Icon(Icons.people_outline_rounded),
                      ),
                      validator: (value) {
                        final val = int.tryParse(value ?? '');
                        if (val == null || val <= 0) {
                          return 'Min. 1 orang';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Urutan Tampilan
                  Expanded(
                    child: TextFormField(
                      controller: _urutanController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Urutan Tampilan',
                        prefixIcon: Icon(Icons.sort_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isEditing ? 'Simpan Perubahan' : 'Tambah Meja'),
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
