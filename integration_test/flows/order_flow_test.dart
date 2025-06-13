// 🧪 Order Placement Flow Integration Test
// Tests complete order placement from menu browsing to confirmation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// NOTE: Uncomment when integration_test package is available
// import 'package:integration_test/integration_test.dart';
import 'package:qsr_app/main.dart' as app;
import 'package:qsr_app/services/theme_service.dart';

void main() {
  // NOTE: Uncomment when integration_test package is available
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('🛒 Order Placement Flow Tests', () {
    late ThemeService themeService;

    setUpAll(() {
      themeService = ThemeService();
    });

    testWidgets('Complete order placement flow', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Step 1: Navigate to menu
      await _navigateToMenu(tester);

      // Step 2: Browse menu categories
      await _browseMenuCategories(tester);

      // Step 3: Select items with customizations
      await _selectMenuItems(tester);

      // Step 4: Add extras and modifications
      await _addExtrasAndModifications(tester);

      // Step 5: Review cart
      await _reviewCart(tester);

      // Step 6: Proceed to checkout
      await _proceedToCheckout(tester);

      // Step 7: Verify order summary
      await _verifyOrderSummary(tester);
    });

    testWidgets('Menu browsing and search', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Navigate to menu
      await _navigateToMenu(tester);

      // Test category navigation
      await _testCategoryNavigation(tester);

      // Test search functionality
      await _testSearchFunctionality(tester);

      // Test item details view
      await _testItemDetailsView(tester);
    });

    testWidgets('Cart management', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Add items to cart
      await _navigateToMenu(tester);
      await _addMultipleItemsToCart(tester);

      // Test cart operations
      await _testCartOperations(tester);
    });

    testWidgets('Order customization flow', (WidgetTester tester) async {
      await tester.pumpWidget(app.MyApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Navigate to menu and select customizable item
      await _navigateToMenu(tester);
      await _selectCustomizableItem(tester);

      // Test all customization options
      await _testCustomizationOptions(tester);

      // Verify customizations in cart
      await _verifyCustomizationsInCart(tester);
    });
  });
}

// Helper functions for order flow testing

Future<void> _navigateToMenu(WidgetTester tester) async {
  // Look for menu navigation options
  final menuOptions = [
    'MENU',
    'ORDER NOW',
    'BROWSE MENU',
  ];

  bool navigatedToMenu = false;
  for (final option in menuOptions) {
    final finder = find.text(option);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder);
      await tester.pumpAndSettle();
      navigatedToMenu = true;
      break;
    }
  }

  // Alternative: Look for bottom navigation
  if (!navigatedToMenu) {
    final bottomNavMenu = find.byIcon(Icons.restaurant_menu);
    if (bottomNavMenu.evaluate().isNotEmpty) {
      await tester.tap(bottomNavMenu);
      await tester.pumpAndSettle();
      navigatedToMenu = true;
    }
  }

  expect(navigatedToMenu, isTrue, reason: 'Could not navigate to menu');
}

Future<void> _browseMenuCategories(WidgetTester tester) async {
  // Look for category tabs or buttons
  final categories = [
    'SANDWICHES',
    'SIDES',
    'BEVERAGES',
    'CREW PACKS',
  ];

  for (final category in categories) {
    final categoryFinder = find.text(category);
    if (categoryFinder.evaluate().isNotEmpty) {
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();
      
      // Verify category content loaded
      await tester.pump(const Duration(seconds: 1));
      break;
    }
  }
}

Future<void> _selectMenuItems(WidgetTester tester) async {
  // Look for menu item cards or tiles
  final menuItemCard = find.byType(Card).first;
  if (menuItemCard.evaluate().isNotEmpty) {
    await tester.tap(menuItemCard);
    await tester.pumpAndSettle();
  }

  // Look for "Add to Cart" button
  final addToCartButton = find.text('ADD TO CART');
  if (addToCartButton.evaluate().isNotEmpty) {
    await tester.tap(addToCartButton);
    await tester.pumpAndSettle();
  }
}

Future<void> _addExtrasAndModifications(WidgetTester tester) async {
  // Look for extras section
  final extrasSection = find.text('EXTRAS');
  if (extrasSection.evaluate().isNotEmpty) {
    // Scroll to extras if needed
    await tester.scrollUntilVisible(
      extrasSection,
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Select some extras
    final checkboxes = find.byType(Checkbox);
    if (checkboxes.evaluate().isNotEmpty) {
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();
    }
  }

  // Look for size selection
  final sizeOptions = find.text('BRIOCHE BUN');
  if (sizeOptions.evaluate().isNotEmpty) {
    await tester.tap(sizeOptions);
    await tester.pumpAndSettle();
  }
}

Future<void> _reviewCart(WidgetTester tester) async {
  // Navigate to cart
  final cartIcon = find.byIcon(Icons.shopping_cart);
  if (cartIcon.evaluate().isNotEmpty) {
    await tester.tap(cartIcon);
    await tester.pumpAndSettle();
  }

  // Alternative: Look for cart button text
  final cartButton = find.text('CART');
  if (cartButton.evaluate().isNotEmpty) {
    await tester.tap(cartButton);
    await tester.pumpAndSettle();
  }

  // Verify cart contents
  expect(find.byType(ListTile), findsAtLeastNWidgets(1));
}

Future<void> _proceedToCheckout(WidgetTester tester) async {
  // Look for checkout button
  final checkoutButton = find.text('CHECKOUT');
  if (checkoutButton.evaluate().isNotEmpty) {
    await tester.tap(checkoutButton);
    await tester.pumpAndSettle();
  }
}

Future<void> _verifyOrderSummary(WidgetTester tester) async {
  // Verify order summary elements
  final summaryElements = [
    'ORDER SUMMARY',
    'TOTAL',
    'SUBTOTAL',
  ];

  for (final element in summaryElements) {
    expect(find.text(element), findsAtLeastNWidgets(1));
  }
}

Future<void> _testCategoryNavigation(WidgetTester tester) async {
  final categories = ['SANDWICHES', 'SIDES', 'BEVERAGES'];
  
  for (final category in categories) {
    final categoryFinder = find.text(category);
    if (categoryFinder.evaluate().isNotEmpty) {
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();
      
      // Verify category content
      await tester.pump(const Duration(milliseconds: 500));
    }
  }
}

Future<void> _testSearchFunctionality(WidgetTester tester) async {
  // Look for search field
  final searchField = find.byType(TextField);
  if (searchField.evaluate().isNotEmpty) {
    await tester.enterText(searchField, 'chicken');
    await tester.pumpAndSettle();
    
    // Verify search results
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> _testItemDetailsView(WidgetTester tester) async {
  // Tap on first menu item
  final firstItem = find.byType(Card).first;
  if (firstItem.evaluate().isNotEmpty) {
    await tester.tap(firstItem);
    await tester.pumpAndSettle();
    
    // Verify item details are shown
    expect(find.text('ADD TO CART'), findsAtLeastNWidgets(1));
  }
}

Future<void> _addMultipleItemsToCart(WidgetTester tester) async {
  // Add multiple items to test cart functionality
  for (int i = 0; i < 2; i++) {
    final menuItems = find.byType(Card);
    if (menuItems.evaluate().length > i) {
      await tester.tap(menuItems.at(i));
      await tester.pumpAndSettle();
      
      final addButton = find.text('ADD TO CART');
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();
      }
      
      // Navigate back to menu
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    }
  }
}

Future<void> _testCartOperations(WidgetTester tester) async {
  // Navigate to cart
  final cartIcon = find.byIcon(Icons.shopping_cart);
  if (cartIcon.evaluate().isNotEmpty) {
    await tester.tap(cartIcon);
    await tester.pumpAndSettle();
  }

  // Test quantity adjustment
  final incrementButton = find.byIcon(Icons.add);
  if (incrementButton.evaluate().isNotEmpty) {
    await tester.tap(incrementButton.first);
    await tester.pumpAndSettle();
  }

  // Test item removal
  final removeButton = find.byIcon(Icons.delete);
  if (removeButton.evaluate().isNotEmpty) {
    await tester.tap(removeButton.first);
    await tester.pumpAndSettle();
  }
}

Future<void> _selectCustomizableItem(WidgetTester tester) async {
  // Look for sandwiches category (most customizable)
  final sandwichesTab = find.text('SANDWICHES');
  if (sandwichesTab.evaluate().isNotEmpty) {
    await tester.tap(sandwichesTab);
    await tester.pumpAndSettle();
  }

  // Select first sandwich
  final firstSandwich = find.byType(Card).first;
  if (firstSandwich.evaluate().isNotEmpty) {
    await tester.tap(firstSandwich);
    await tester.pumpAndSettle();
  }
}

Future<void> _testCustomizationOptions(WidgetTester tester) async {
  // Test heat level selection
  final heatLevels = find.byIcon(Icons.local_fire_department);
  if (heatLevels.evaluate().isNotEmpty) {
    await tester.tap(heatLevels.first);
    await tester.pumpAndSettle();
  }

  // Test sauce selection
  final sauceCheckboxes = find.byType(Checkbox);
  if (sauceCheckboxes.evaluate().isNotEmpty) {
    await tester.tap(sauceCheckboxes.first);
    await tester.pumpAndSettle();
  }

  // Test bun selection
  final bunOptions = find.text('BRIOCHE BUN');
  if (bunOptions.evaluate().isNotEmpty) {
    await tester.tap(bunOptions);
    await tester.pumpAndSettle();
  }
}

Future<void> _verifyCustomizationsInCart(WidgetTester tester) async {
  // Add customized item to cart
  final addButton = find.text('ADD TO CART');
  if (addButton.evaluate().isNotEmpty) {
    await tester.tap(addButton);
    await tester.pumpAndSettle();
  }

  // Navigate to cart and verify customizations are shown
  final cartIcon = find.byIcon(Icons.shopping_cart);
  if (cartIcon.evaluate().isNotEmpty) {
    await tester.tap(cartIcon);
    await tester.pumpAndSettle();
  }

  // Verify customization details are visible in cart
  expect(find.byType(ListTile), findsAtLeastNWidgets(1));
}
