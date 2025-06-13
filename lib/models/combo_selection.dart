// 🍗🍟🥤 Combo Selection Models
// Handles combo meal customization with drink and side selection

import 'package:qsr_app/models/menu_item.dart';

/// Represents a combo meal configuration
class ComboMeal {
  final String id;
  final String name;
  final String description;
  final double basePrice; // Additional cost for combo upgrade
  final MenuItem mainItem;
  MenuItem? selectedDrink;
  MenuItem? selectedSide;
  String? selectedDrinkSize;
  String? selectedSideSize;

  ComboMeal({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.mainItem,
    this.selectedDrink,
    this.selectedSide,
    this.selectedDrinkSize,
    this.selectedSideSize,
  });

  /// Calculate total combo price
  double get totalPrice {
    // Calculate main item price including bun upgrades
    double mainItemPrice = mainItem.price;

    // Handle bun upgrades for sandwiches
    if (mainItem.category.toLowerCase().contains('sandwich') &&
        mainItem.selectedBunType != null &&
        mainItem.sizes != null) {
      final bunPrice = mainItem.sizes![mainItem.selectedBunType];
      if (bunPrice != null) {
        final lowestPrice = mainItem.sizes!.values.reduce((a, b) => a < b ? a : b);
        mainItemPrice = lowestPrice + (bunPrice - lowestPrice);
      }
    }

    double total = mainItemPrice + basePrice;
    
    // Add drink price (if size upgrade)
    if (selectedDrink != null && selectedDrinkSize != null) {
      final drinkSizes = selectedDrink!.sizes;
      if (drinkSizes != null && drinkSizes.containsKey(selectedDrinkSize)) {
        // Only charge difference if upgrading from regular
        final regularPrice = drinkSizes['Regular'] ?? drinkSizes.values.first;
        final selectedPrice = drinkSizes[selectedDrinkSize!]!;
        total += (selectedPrice - regularPrice);
      }
    }
    
    // Add side price (if size upgrade)
    if (selectedSide != null && selectedSideSize != null) {
      final sideSizes = selectedSide!.sizes;
      if (sideSizes != null && sideSizes.containsKey(selectedSideSize)) {
        // Only charge difference if upgrading from regular
        final regularPrice = sideSizes['Regular'] ?? sideSizes.values.first;
        final selectedPrice = sideSizes[selectedSideSize!]!;
        total += (selectedPrice - regularPrice);
      }
    }
    
    return total;
  }

  /// Check if combo is complete (has drink and side)
  bool get isComplete => selectedDrink != null && selectedSide != null;

  /// Get combo savings compared to individual items
  double get savings {
    if (!isComplete) return 0.0;
    
    double individualTotal = mainItem.price;
    
    // Add individual drink price
    if (selectedDrink != null) {
      final drinkPrice = selectedDrinkSize != null && selectedDrink!.sizes != null
          ? selectedDrink!.sizes![selectedDrinkSize!] ?? selectedDrink!.price
          : selectedDrink!.price;
      individualTotal += drinkPrice;
    }
    
    // Add individual side price
    if (selectedSide != null) {
      final sidePrice = selectedSideSize != null && selectedSide!.sizes != null
          ? selectedSide!.sizes![selectedSideSize!] ?? selectedSide!.price
          : selectedSide!.price;
      individualTotal += sidePrice;
    }
    
    return individualTotal - totalPrice;
  }

  /// Create a copy with updated selections
  ComboMeal copyWith({
    MenuItem? selectedDrink,
    MenuItem? selectedSide,
    String? selectedDrinkSize,
    String? selectedSideSize,
  }) {
    return ComboMeal(
      id: id,
      name: name,
      description: description,
      basePrice: basePrice,
      mainItem: mainItem,
      selectedDrink: selectedDrink ?? this.selectedDrink,
      selectedSide: selectedSide ?? this.selectedSide,
      selectedDrinkSize: selectedDrinkSize ?? this.selectedDrinkSize,
      selectedSideSize: selectedSideSize ?? this.selectedSideSize,
    );
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'mainItem': mainItem.toJson(),
      'selectedDrink': selectedDrink?.toJson(),
      'selectedSide': selectedSide?.toJson(),
      'selectedDrinkSize': selectedDrinkSize,
      'selectedSideSize': selectedSideSize,
    };
  }

  /// Create from JSON
  factory ComboMeal.fromJson(Map<String, dynamic> json) {
    return ComboMeal(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      basePrice: json['basePrice'].toDouble(),
      mainItem: MenuItem.fromJson(json['mainItem']),
      selectedDrink: json['selectedDrink'] != null 
          ? MenuItem.fromJson(json['selectedDrink']) 
          : null,
      selectedSide: json['selectedSide'] != null 
          ? MenuItem.fromJson(json['selectedSide']) 
          : null,
      selectedDrinkSize: json['selectedDrinkSize'],
      selectedSideSize: json['selectedSideSize'],
    );
  }
}

/// Combo configuration for different menu categories
class ComboConfiguration {
  static const double standardComboUpgrade = 8.50;
  static const double crewPackComboUpgrade = 15.00;
  
  /// Get combo upgrade price for menu item category
  static double getComboPrice(String category) {
    switch (category.toLowerCase()) {
      case 'crew packs':
      case 'crew-packs':
        return crewPackComboUpgrade;
      default:
        return standardComboUpgrade;
    }
  }
  
  /// Check if item is eligible for combo
  static bool isComboEligible(MenuItem item) {
    final eligibleCategories = [
      'sandwiches',
      'whole-wings',
      'chicken-pieces',
      'chicken-bites',
      'crew-packs',
    ];
    
    return eligibleCategories.contains(item.category.toLowerCase()) ||
           eligibleCategories.any((cat) => item.category.toLowerCase().contains(cat));
  }
  
  /// Create combo meal from menu item
  static ComboMeal createCombo(MenuItem mainItem, {String? selectedSize}) {
    final comboPrice = getComboPrice(mainItem.category);

    // Clone the main item to preserve customizations
    final clonedMainItem = mainItem.clone();

    // If a selected size (bun) is provided, store it
    if (selectedSize != null) {
      clonedMainItem.selectedBunType = selectedSize;
    }

    return ComboMeal(
      id: '${mainItem.id}_combo',
      name: '${mainItem.name} Combo',
      description: 'Includes ${mainItem.name}, side, and drink',
      basePrice: comboPrice,
      mainItem: clonedMainItem,
    );
  }
}
