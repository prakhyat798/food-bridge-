import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodbridge/main.dart';

void main() {
  testWidgets('FoodBridgeApp renders smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(const ProviderScope(child: FoodBridgeApp()));
    
    // Verify that the app mounts
    expect(find.byType(FoodBridgeApp), findsOneWidget);

    // Fast-forward past splash screen transition
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
  });
}
