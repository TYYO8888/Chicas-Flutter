// 🧪 Payment Flow Integration Test
// Tests payment processing with multiple payment methods

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// NOTE: Uncomment when integration_test package is available
// import 'package:integration_test/integration_test.dart';
import 'package:qsr_app/main.dart' as app;
import 'package:qsr_app/services/theme_service.dart';

void main() {
  // NOTE: Uncomment when integration_test package is available
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('💳 Payment Flow Tests', () {
    late ThemeService themeService;

    setUpAll(() {
      themeService = ThemeService();
    });

    testWidgets('Credit card payment flow', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Setup: Add item to cart and navigate to payment
      await _setupOrderForPayment(tester);

      // Test credit card payment
      await _testCreditCardPayment(tester);

      // Verify payment success
      await _verifyPaymentSuccess(tester);
    });

    testWidgets('Apple Pay payment flow', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      await _setupOrderForPayment(tester);
      await _testApplePayPayment(tester);
      await _verifyPaymentSuccess(tester);
    });

    testWidgets('Google Pay payment flow', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      await _setupOrderForPayment(tester);
      await _testGooglePayPayment(tester);
      await _verifyPaymentSuccess(tester);
    });

    testWidgets('Loyalty points redemption', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      await _setupOrderForPayment(tester);
      await _testLoyaltyPointsRedemption(tester);
      await _verifyPaymentSuccess(tester);
    });

    testWidgets('Payment failure handling', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      await _setupOrderForPayment(tester);
      await _testPaymentFailureScenarios(tester);
    });

    testWidgets('Mixed payment methods', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      await _setupOrderForPayment(tester);
      await _testMixedPaymentMethods(tester);
      await _verifyPaymentSuccess(tester);
    });
  });
}

// Helper functions for payment flow testing

Future<void> _setupOrderForPayment(WidgetTester tester) async {
  // Navigate to menu
  final menuButton = find.text('MENU');
  if (menuButton.evaluate().isNotEmpty) {
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
  }

  // Add item to cart
  final firstItem = find.byType(Card).first;
  if (firstItem.evaluate().isNotEmpty) {
    await tester.tap(firstItem);
    await tester.pumpAndSettle();

    final addToCartButton = find.text('ADD TO CART');
    if (addToCartButton.evaluate().isNotEmpty) {
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();
    }
  }

  // Navigate to cart
  final cartIcon = find.byIcon(Icons.shopping_cart);
  if (cartIcon.evaluate().isNotEmpty) {
    await tester.tap(cartIcon);
    await tester.pumpAndSettle();
  }

  // Proceed to checkout
  final checkoutButton = find.text('CHECKOUT');
  if (checkoutButton.evaluate().isNotEmpty) {
    await tester.tap(checkoutButton);
    await tester.pumpAndSettle();
  }

  // Navigate to payment screen
  final paymentButton = find.text('PAYMENT');
  if (paymentButton.evaluate().isNotEmpty) {
    await tester.tap(paymentButton);
    await tester.pumpAndSettle();
  }
}

Future<void> _testCreditCardPayment(WidgetTester tester) async {
  // Select credit card payment method
  final creditCardOption = find.text('CREDIT CARD');
  if (creditCardOption.evaluate().isNotEmpty) {
    await tester.tap(creditCardOption);
    await tester.pumpAndSettle();
  }

  // Fill credit card form
  await _fillCreditCardForm(tester);

  // Process payment
  final payButton = find.text('PAY NOW');
  if (payButton.evaluate().isNotEmpty) {
    await tester.tap(payButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }
}

Future<void> _fillCreditCardForm(WidgetTester tester) async {
  // Fill card number (test card)
  final cardNumberField = find.byKey(const Key('cardNumber'));
  if (cardNumberField.evaluate().isNotEmpty) {
    await tester.enterText(cardNumberField, '4242424242424242');
    await tester.pumpAndSettle();
  }

  // Fill expiry date
  final expiryField = find.byKey(const Key('expiryDate'));
  if (expiryField.evaluate().isNotEmpty) {
    await tester.enterText(expiryField, '12/25');
    await tester.pumpAndSettle();
  }

  // Fill CVV
  final cvvField = find.byKey(const Key('cvv'));
  if (cvvField.evaluate().isNotEmpty) {
    await tester.enterText(cvvField, '123');
    await tester.pumpAndSettle();
  }

  // Fill cardholder name
  final nameField = find.byKey(const Key('cardholderName'));
  if (nameField.evaluate().isNotEmpty) {
    await tester.enterText(nameField, 'John Doe');
    await tester.pumpAndSettle();
  }
}

Future<void> _testApplePayPayment(WidgetTester tester) async {
  // Select Apple Pay option
  final applePayOption = find.text('APPLE PAY');
  if (applePayOption.evaluate().isNotEmpty) {
    await tester.tap(applePayOption);
    await tester.pumpAndSettle();
  }

  // Simulate Apple Pay authorization
  final applePayButton = find.byKey(const Key('applePayButton'));
  if (applePayButton.evaluate().isNotEmpty) {
    await tester.tap(applePayButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // In a real test, this would trigger the Apple Pay sheet
  // For integration testing, we simulate the success response
}

Future<void> _testGooglePayPayment(WidgetTester tester) async {
  // Select Google Pay option
  final googlePayOption = find.text('GOOGLE PAY');
  if (googlePayOption.evaluate().isNotEmpty) {
    await tester.tap(googlePayOption);
    await tester.pumpAndSettle();
  }

  // Simulate Google Pay authorization
  final googlePayButton = find.byKey(const Key('googlePayButton'));
  if (googlePayButton.evaluate().isNotEmpty) {
    await tester.tap(googlePayButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}

Future<void> _testLoyaltyPointsRedemption(WidgetTester tester) async {
  // Look for loyalty points section
  final loyaltySection = find.text('LOYALTY POINTS');
  if (loyaltySection.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(
      loyaltySection,
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  // Toggle points redemption
  final usePointsToggle = find.byKey(const Key('usePointsToggle'));
  if (usePointsToggle.evaluate().isNotEmpty) {
    await tester.tap(usePointsToggle);
    await tester.pumpAndSettle();
  }

  // Enter points to redeem
  final pointsField = find.byKey(const Key('pointsToRedeem'));
  if (pointsField.evaluate().isNotEmpty) {
    await tester.enterText(pointsField, '100');
    await tester.pumpAndSettle();
  }

  // Apply points
  final applyPointsButton = find.text('APPLY POINTS');
  if (applyPointsButton.evaluate().isNotEmpty) {
    await tester.tap(applyPointsButton);
    await tester.pumpAndSettle();
  }

  // Complete payment with remaining balance
  await _completeMixedPayment(tester);
}

Future<void> _completeMixedPayment(WidgetTester tester) async {
  // If there's remaining balance, pay with credit card
  final remainingBalance = find.text('REMAINING BALANCE');
  if (remainingBalance.evaluate().isNotEmpty) {
    await _testCreditCardPayment(tester);
  } else {
    // If fully paid with points, just confirm
    final confirmButton = find.text('CONFIRM ORDER');
    if (confirmButton.evaluate().isNotEmpty) {
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _testPaymentFailureScenarios(WidgetTester tester) async {
  // Test with invalid card number
  final creditCardOption = find.text('CREDIT CARD');
  if (creditCardOption.evaluate().isNotEmpty) {
    await tester.tap(creditCardOption);
    await tester.pumpAndSettle();
  }

  // Fill with invalid card details
  await _fillInvalidCreditCardForm(tester);

  // Attempt payment
  final payButton = find.text('PAY NOW');
  if (payButton.evaluate().isNotEmpty) {
    await tester.tap(payButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // Verify error message is shown
  await _verifyPaymentError(tester);
}

Future<void> _fillInvalidCreditCardForm(WidgetTester tester) async {
  // Fill with invalid card number
  final cardNumberField = find.byKey(const Key('cardNumber'));
  if (cardNumberField.evaluate().isNotEmpty) {
    await tester.enterText(cardNumberField, '4000000000000002'); // Declined card
    await tester.pumpAndSettle();
  }

  // Fill other required fields
  final expiryField = find.byKey(const Key('expiryDate'));
  if (expiryField.evaluate().isNotEmpty) {
    await tester.enterText(expiryField, '12/25');
    await tester.pumpAndSettle();
  }

  final cvvField = find.byKey(const Key('cvv'));
  if (cvvField.evaluate().isNotEmpty) {
    await tester.enterText(cvvField, '123');
    await tester.pumpAndSettle();
  }
}

Future<void> _testMixedPaymentMethods(WidgetTester tester) async {
  // Use loyalty points first
  await _testLoyaltyPointsRedemption(tester);
  
  // Then complete with credit card for remaining balance
  // This is handled in _completeMixedPayment called from loyalty points test
}

Future<void> _verifyPaymentSuccess(WidgetTester tester) async {
  // Look for success indicators
  final successIndicators = [
    'PAYMENT SUCCESSFUL',
    'ORDER CONFIRMED',
    'THANK YOU',
    'ORDER #',
  ];

  bool foundSuccess = false;
  for (final indicator in successIndicators) {
    if (find.text(indicator).evaluate().isNotEmpty) {
      foundSuccess = true;
      break;
    }
  }

  expect(foundSuccess, isTrue, reason: 'Payment success not confirmed');

  // Verify order number is displayed
  final orderNumber = find.textContaining('#');
  expect(orderNumber, findsAtLeastNWidgets(1));
}

Future<void> _verifyPaymentError(WidgetTester tester) async {
  // Look for error indicators
  final errorIndicators = [
    'PAYMENT FAILED',
    'CARD DECLINED',
    'ERROR',
    'TRY AGAIN',
  ];

  bool foundError = false;
  for (final indicator in errorIndicators) {
    if (find.text(indicator).evaluate().isNotEmpty) {
      foundError = true;
      break;
    }
  }

  expect(foundError, isTrue, reason: 'Payment error not shown');
}
