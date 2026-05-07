import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:respyr_dietitian/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Splash screen appears", (tester) async {
    app.main();

    // First frame
    await tester.pump();

    // Wait a little so splash paints (but before 3 sec navigation)
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey("splash_logo")), findsOneWidget);
  });
}