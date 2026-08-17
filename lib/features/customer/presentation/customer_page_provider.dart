import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

class CustomerMejaState {
  final bool isLoading;
  final bool isValid;
  final String? pesan;
  final String namaKafe;
  final String nomorMeja;
  final String? namaMeja;
  final bool adaSesiAktif;
  final DateTime? waktuMulai;
  final DateTime? waktuBerakhir;
  final double totalBelanja;
  final String tingkatKeramaian; // 'sepi', 'normal', 'ramai'
  final String? pesanCustomer;
  final DateTime now;

  const CustomerMejaState({
    this.isLoading = true,
    this.isValid = true,
    this.pesan,
    this.namaKafe = 'CafeFlow',
    this.nomorMeja = '-',
    this.namaMeja,
    this.adaSesiAktif = false,
    this.waktuMulai,
    this.waktuBerakhir,
    this.totalBelanja = 0.0,
    this.tingkatKeramaian = 'normal',
    this.pesanCustomer,
    required this.now,
  });

  Duration get remainingDuration {
    if (waktuBerakhir == null) return Duration.zero;
    final diff = waktuBerakhir!.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  String get formattedCountdown {
    if (!adaSesiAktif || waktuBerakhir == null) return '00:00:00';
    final rem = remainingDuration;
    final hours = rem.inHours.toString().padLeft(2, '0');
    final minutes = (rem.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (rem.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  CustomerMejaState copyWith({
    bool? isLoading,
    bool? isValid,
    String? pesan,
    String? namaKafe,
    String? nomorMeja,
    String? namaMeja,
    bool? adaSesiAktif,
    DateTime? waktuMulai,
    DateTime? waktuBerakhir,
    double? totalBelanja,
    String? tingkatKeramaian,
    String? pesanCustomer,
    DateTime? now,
  }) {
    return CustomerMejaState(
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      pesan: pesan ?? this.pesan,
      namaKafe: namaKafe ?? this.namaKafe,
      nomorMeja: nomorMeja ?? this.nomorMeja,
      namaMeja: namaMeja ?? this.namaMeja,
      adaSesiAktif: adaSesiAktif ?? this.adaSesiAktif,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuBerakhir: waktuBerakhir ?? this.waktuBerakhir,
      totalBelanja: totalBelanja ?? this.totalBelanja,
      tingkatKeramaian: tingkatKeramaian ?? this.tingkatKeramaian,
      pesanCustomer: pesanCustomer ?? this.pesanCustomer,
      now: now ?? this.now,
    );
  }
}

class CustomerMejaNotifier extends StateNotifier<CustomerMejaState> {
  final CustomerRepository _repository;
  final String tokenQr;
  Timer? _timer;

  CustomerMejaNotifier(this._repository, this.tokenQr)
      : super(CustomerMejaState(now: DateTime.now())) {
    loadPublicStatus();
    _startLocalTicker();
  }

  void _startLocalTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        state = state.copyWith(now: DateTime.now());
      }
    });
  }

  Future<void> loadPublicStatus() async {
    state = state.copyWith(isLoading: true);
    final data = await _repository.fetchPublicMejaStatus(tokenQr);

    if (data['valid'] == false) {
      state = state.copyWith(
        isLoading: false,
        isValid: false,
        pesan: data['pesan']?.toString() ?? 'QR Code tidak valid.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      isValid: true,
      namaKafe: data['nama_kafe'] as String? ?? 'CafeFlow',
      nomorMeja: data['nomor_meja'] as String? ?? '-',
      namaMeja: data['nama_meja'] as String?,
      adaSesiAktif: data['ada_sesi_aktif'] as bool? ?? false,
      waktuMulai: data['waktu_mulai'] != null ? DateTime.tryParse(data['waktu_mulai'].toString())?.toLocal() : null,
      waktuBerakhir: data['waktu_berakhir'] != null ? DateTime.tryParse(data['waktu_berakhir'].toString())?.toLocal() : null,
      totalBelanja: data['total_belanja'] is num
          ? (data['total_belanja'] as num).toDouble()
          : double.tryParse(data['total_belanja']?.toString() ?? '0') ?? 0.0,
      tingkatKeramaian: data['tingkat_keramaian'] as String? ?? 'normal',
      pesanCustomer: data['pesan_customer'] as String?,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final customerMejaProvider = StateNotifierProvider.family<CustomerMejaNotifier, CustomerMejaState, String>(
  (ref, tokenQr) {
    final repo = ref.watch(customerRepositoryProvider);
    return CustomerMejaNotifier(repo, tokenQr);
  },
);
