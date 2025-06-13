import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/models/crew_pack_selection.dart';
import 'package:qsr_app/models/menu_extras.dart';
import 'package:qsr_app/models/combo_selection.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String? selectedSize;
  Map<String, List<MenuItem>>? customizations;
  CrewPackCustomization? crewPackCustomization;
  MenuItemExtras? extras;
  ComboMeal? comboMeal;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.selectedSize,
    this.customizations,
    this.crewPackCustomization,
    this.extras,
    this.comboMeal,
  });

  double get itemPrice {
    // If this is a combo meal, return combo price
    if (comboMeal != null) {
      return comboMeal!.totalPrice;
    }

    double basePrice = menuItem.price;

    // Handle bun selection for sandwiches (sizes represent bun types, not price tiers)
    if (selectedSize != null && menuItem.sizes != null && menuItem.sizes!.containsKey(selectedSize)) {
      // For sandwiches, calculate bun upgrade cost
      if (menuItem.category.toLowerCase().contains('sandwich')) {
        final bunPrice = menuItem.sizes![selectedSize]!;
        final lowestPrice = menuItem.sizes!.values.reduce((a, b) => a < b ? a : b);
        basePrice = lowestPrice + (bunPrice - lowestPrice); // Base price + bun upgrade
      } else {
        // For other items, use size price directly
        basePrice = menuItem.sizes![selectedSize]!;
      }
    }

    if (crewPackCustomization != null) {
      return crewPackCustomization!.totalPrice;
    }

    // Add extras price
    if (extras != null) {
      basePrice += extras!.totalExtrasPrice;
    }

    return basePrice;
  }

  // Helper getters for UI display
  bool get isCombo => comboMeal != null;

  String get displayName {
    if (comboMeal != null) {
      return '${comboMeal!.mainItem.name} COMBO';
    }
    return menuItem.name;
  }
}

class Cart {
  final List<CartItem> items = [];

  double get totalPrice {
    return items.fold(0.0, (total, item) => total + (item.itemPrice * item.quantity));
  }
}
