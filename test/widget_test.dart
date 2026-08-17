import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cafeflow/main.dart';

void main() {
  testWidgets('CafeFlowApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CafeFlowApp(),
      ),
    );

    // Verify CafeFlow brand title exists
    expect(find.text('CafeFlow'), findsOneWidget);
  });
}
