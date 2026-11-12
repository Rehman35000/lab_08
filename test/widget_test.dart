
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_campus/main.dart';

void main() {
  testWidgets('Smart Campus app loads splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCampusApp());

    // Verify that the splash screen appears.
    expect(find.text('Smart Campus'), findsOneWidget);

    // Complete the splash timer and animations.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify that the login screen appears.
    expect(find.text('Login'), findsWidgets);
  });
}
