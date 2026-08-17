import 'package:flutter_test/flutter_test.dart';
import 'package:cafeflow/features/customer/presentation/customer_page_provider.dart';

void main() {
  group('Customer Meja Public View & Timer Tests', () {
    test('CustomerMejaState countdown formatting', () {
      final now = DateTime.now();
      final waktuBerakhir = now.add(const Duration(hours: 1, minutes: 24, seconds: 32));

      final state = CustomerMejaState(
        adaSesiAktif: true,
        waktuBerakhir: waktuBerakhir,
        now: now,
      );

      expect(state.formattedCountdown, equals('01:24:32'));
    });

    test('CustomerMejaState no active session formatting', () {
      final state = CustomerMejaState(
        adaSesiAktif: false,
        now: DateTime.now(),
      );

      expect(state.formattedCountdown, equals('00:00:00'));
      expect(state.adaSesiAktif, isFalse);
    });
  });
}
