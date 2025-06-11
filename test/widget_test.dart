// 🧪 QSR App Widget Tests
// Tests for Chica's Chicken ordering app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qsr_app/main.dart';
import 'package:qsr_app/services/theme_service.dart';

void main() {
  testWidgets('QSR App launches successfully', (WidgetTester tester) async {
    // Create a theme service for testing
    final themeService = ThemeService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(themeService: themeService));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app launches without crashing
    // Look for key elements that should be present
    expect(find.byType(MaterialApp), findsOneWidget);

    // The app should have some navigation or content
    // This is a basic smoke test to ensure the app doesn't crash on startup
  });
}
