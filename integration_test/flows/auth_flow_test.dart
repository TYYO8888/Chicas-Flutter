// 🧪 Authentication Flow Integration Test
// Tests complete user registration and login flows

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// NOTE: Uncomment when integration_test package is available
// import 'package:integration_test/integration_test.dart';
import 'package:qsr_app/main.dart' as app;
import 'package:qsr_app/services/theme_service.dart';

void main() {
  // NOTE: Uncomment when integration_test package is available
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🔐 Authentication Flow Tests', () {
    late ThemeService themeService;

    setUpAll(() {
      themeService = ThemeService();
    });

    testWidgets('Complete user registration flow', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Step 1: Navigate to sign-up from home screen
      // Look for sign-up button or link
      final signUpFinder = find.text('SIGN UP');
      if (signUpFinder.evaluate().isNotEmpty) {
        await tester.tap(signUpFinder);
        await tester.pumpAndSettle();
      }

      // Step 2: Fill registration form
      await _fillRegistrationForm(tester);

      // Step 3: Verify successful registration
      await _verifyRegistrationSuccess(tester);
    });

    testWidgets('User login flow', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Step 1: Navigate to login
      final loginFinder = find.text('LOGIN');
      if (loginFinder.evaluate().isNotEmpty) {
        await tester.tap(loginFinder);
        await tester.pumpAndSettle();
      }

      // Step 2: Fill login form
      await _fillLoginForm(tester);

      // Step 3: Verify successful login
      await _verifyLoginSuccess(tester);
    });

    testWidgets('Password reset flow', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Navigate to login screen first
      final loginFinder = find.text('LOGIN');
      if (loginFinder.evaluate().isNotEmpty) {
        await tester.tap(loginFinder);
        await tester.pumpAndSettle();
      }

      // Step 1: Tap forgot password
      final forgotPasswordFinder = find.text('FORGOT PASSWORD');
      if (forgotPasswordFinder.evaluate().isNotEmpty) {
        await tester.tap(forgotPasswordFinder);
        await tester.pumpAndSettle();
      }

      // Step 2: Enter email for password reset
      await _fillPasswordResetForm(tester);

      // Step 3: Verify reset email sent confirmation
      await _verifyPasswordResetSent(tester);
    });

    testWidgets('Guest user flow', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Step 1: Continue as guest
      final guestFinder = find.text('CONTINUE AS GUEST');
      if (guestFinder.evaluate().isNotEmpty) {
        await tester.tap(guestFinder);
        await tester.pumpAndSettle();
      }

      // Step 2: Verify guest access to menu
      await _verifyGuestAccess(tester);
    });
  });
}

// Helper functions for form filling and verification

Future<void> _fillRegistrationForm(WidgetTester tester) async {
  // Fill email field
  final emailField = find.byType(TextFormField).first;
  await tester.enterText(emailField, 'test@chicaschicken.com');
  await tester.pumpAndSettle();

  // Fill password field
  final passwordFields = find.byType(TextFormField);
  if (passwordFields.evaluate().length > 1) {
    await tester.enterText(passwordFields.at(1), 'TestPassword123!');
    await tester.pumpAndSettle();
  }

  // Fill confirm password field
  if (passwordFields.evaluate().length > 2) {
    await tester.enterText(passwordFields.at(2), 'TestPassword123!');
    await tester.pumpAndSettle();
  }

  // Fill name fields if present
  final nameField = find.byKey(const Key('firstName'));
  if (nameField.evaluate().isNotEmpty) {
    await tester.enterText(nameField, 'John');
    await tester.pumpAndSettle();
  }

  final lastNameField = find.byKey(const Key('lastName'));
  if (lastNameField.evaluate().isNotEmpty) {
    await tester.enterText(lastNameField, 'Doe');
    await tester.pumpAndSettle();
  }

  // Tap register button
  final registerButton = find.text('REGISTER');
  if (registerButton.evaluate().isNotEmpty) {
    await tester.tap(registerButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}

Future<void> _verifyRegistrationSuccess(WidgetTester tester) async {
  // Look for success indicators
  final successIndicators = [
    'WELCOME',
    'REGISTRATION SUCCESSFUL',
    'VERIFY EMAIL',
    'HOME', // If redirected to home screen
  ];

  bool foundSuccess = false;
  for (final indicator in successIndicators) {
    if (find.text(indicator).evaluate().isNotEmpty) {
      foundSuccess = true;
      break;
    }
  }

  expect(foundSuccess, isTrue, reason: 'Registration success not confirmed');
}

Future<void> _fillLoginForm(WidgetTester tester) async {
  // Fill email field
  final emailField = find.byType(TextFormField).first;
  await tester.enterText(emailField, 'test@chicaschicken.com');
  await tester.pumpAndSettle();

  // Fill password field
  final passwordFields = find.byType(TextFormField);
  if (passwordFields.evaluate().length > 1) {
    await tester.enterText(passwordFields.at(1), 'TestPassword123!');
    await tester.pumpAndSettle();
  }

  // Tap login button
  final loginButton = find.text('LOGIN');
  if (loginButton.evaluate().isNotEmpty) {
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}

Future<void> _verifyLoginSuccess(WidgetTester tester) async {
  // Look for post-login indicators
  final loginSuccessIndicators = [
    'WELCOME BACK',
    'HOME',
    'MENU',
    'MY ACCOUNT',
  ];

  bool foundSuccess = false;
  for (final indicator in loginSuccessIndicators) {
    if (find.text(indicator).evaluate().isNotEmpty) {
      foundSuccess = true;
      break;
    }
  }

  expect(foundSuccess, isTrue, reason: 'Login success not confirmed');
}

Future<void> _fillPasswordResetForm(WidgetTester tester) async {
  // Fill email field for password reset
  final emailField = find.byType(TextFormField).first;
  await tester.enterText(emailField, 'test@chicaschicken.com');
  await tester.pumpAndSettle();

  // Tap send reset email button
  final resetButton = find.text('SEND RESET EMAIL');
  if (resetButton.evaluate().isNotEmpty) {
    await tester.tap(resetButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
}

Future<void> _verifyPasswordResetSent(WidgetTester tester) async {
  // Look for confirmation message
  final confirmationMessages = [
    'EMAIL SENT',
    'CHECK YOUR EMAIL',
    'RESET LINK SENT',
  ];

  bool foundConfirmation = false;
  for (final message in confirmationMessages) {
    if (find.text(message).evaluate().isNotEmpty) {
      foundConfirmation = true;
      break;
    }
  }

  expect(foundConfirmation, isTrue, reason: 'Password reset confirmation not found');
}

Future<void> _verifyGuestAccess(WidgetTester tester) async {
  // Verify guest can access menu
  final menuIndicators = [
    'MENU',
    'SANDWICHES',
    'SIDES',
    'BEVERAGES',
  ];

  bool foundMenu = false;
  for (final indicator in menuIndicators) {
    if (find.text(indicator).evaluate().isNotEmpty) {
      foundMenu = true;
      break;
    }
  }

  expect(foundMenu, isTrue, reason: 'Guest access to menu not confirmed');
}
