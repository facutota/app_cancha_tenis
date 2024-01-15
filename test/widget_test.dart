import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_cancha_tenis/main.dart';

void main() {
  testWidgets('Widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  });
}
