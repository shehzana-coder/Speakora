// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import your actual main file - adjust path as needed
import 'package:myproject/main.dart';

void main() {
  testWidgets('Speakora app loads with splash screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpeakoraApp());

    // Wait for animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the onboarding screen elements are present
    expect(find.text('Empower'), findsOneWidget);
    expect(find.text('your'), findsOneWidget);
    expect(find.text('English.'), findsOneWidget);
    expect(find.text('Mastering English is the first step to mastering'),
        findsOneWidget);
    expect(find.text('global opportunities.'), findsOneWidget);

    // Check for buttons
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

    // Test navigation to home screen
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Check if we're on the home screen
    expect(find.text('Welcome to Speakora!'), findsOneWidget);
  });
}
