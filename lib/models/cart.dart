import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/models/crew_pack_selection.dart';
import 'package:qsr_app/models/menu_extras.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String? selectedSize;
  Map<String, List<MenuItem>>? customizations;
  CrewPackCustomization? crewPackCustomization;
  MenuItemExtras? extras;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.selectedSize,
    this.customizations,
    this.crewPackCustomization,
    this.extras,
  });

  double get itemPrice {
    double basePrice = menuItem.price;
    if (selectedSize != null && menuItem.sizes != null && menuItem.sizes!.containsKey(selectedSize)) {
      basePrice = menuItem.sizes![selectedSize]!;
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
}

class Cart {
  final List<CartItem> items = [];

  double get totalPrice {
    return items.fold(0.0, (total, item) => total + (item.itemPrice * item.quantity));
  }
}
