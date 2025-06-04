import 'package:qsr_app/models/cart.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/models/crew_pack_selection.dart';

class CartService {
  static final Cart _cart = Cart();

  Cart get cart => _cart;

  void addToCart(
    MenuItem menuItem, {
    String? selectedSize,
    Map<String, List<MenuItem>>? customizations,
    CrewPackCustomization? crewPackCustomization,
  }) {
    // For crew packs with sandwich selections, always add as a new item
    if (crewPackCustomization != null) {
      _cart.items.add(CartItem(
        menuItem: menuItem,
        quantity: 1,
        crewPackCustomization: crewPackCustomization,
      ));
    }
    // For crew packs or customizable items, always add as a new item
    else if (customizations != null) {
      _cart.items.add(CartItem(
        menuItem: menuItem,
        quantity: 1,
        customizations: customizations,
      ));
    } else {
      // For regular items, check if they exist and update quantity
      final existingItem = _cart.items.firstWhere(
        (item) =>
            item.menuItem.id == menuItem.id &&
            item.customizations == null &&
            item.selectedSize == selectedSize &&
            item.crewPackCustomization == null,
        orElse: () => CartItem(
          menuItem: MenuItem(
            name: '',
            description: '',
            price: 0,
            category: '',
          ),
          quantity: 0,
        ),
      );

      if (existingItem.menuItem.name.isNotEmpty) {
        existingItem.quantity++;
      } else {
        _cart.items.add(CartItem(
          menuItem: menuItem,
          quantity: 1,
          selectedSize: selectedSize,
        ));
      }
    }
  }

  void removeItem(MenuItem menuItem, {
    Map<String, List<MenuItem>>? customizations,
    CrewPackCustomization? crewPackCustomization,
  }) {
    if (crewPackCustomization != null) {
      // For crew packs with sandwich selections, remove the specific customized version
      _cart.items.removeWhere((item) =>
          item.menuItem.id == menuItem.id &&
          item.crewPackCustomization == crewPackCustomization);
    } else if (customizations != null) {
      // For customized items, remove the specific customized version
      _cart.items.removeWhere((item) =>
          item.menuItem.id == menuItem.id &&
          item.customizations == customizations);
    } else {
      // For regular items, remove all non-customized versions
      _cart.items.removeWhere((item) =>
          item.menuItem.id == menuItem.id &&
          item.customizations == null &&
          item.crewPackCustomization == null);
    }
  }

  void updateQuantity(
    MenuItem menuItem,
    int quantity, {
    Map<String, List<MenuItem>>? customizations,
    CrewPackCustomization? crewPackCustomization,
  }) {
    final existingItem = _cart.items.firstWhere(
      (item) =>
          item.menuItem.id == menuItem.id &&
          item.customizations == customizations &&
          item.crewPackCustomization == crewPackCustomization,
      orElse: () => CartItem(
        menuItem: MenuItem(
          name: '',
          description: '',
          price: 0,
          category: '',
        ),
        quantity: 0,
      ),
    );

    if (existingItem.menuItem.name.isNotEmpty) {
      existingItem.quantity = quantity;
    }
  }

  double getTotalPrice() {
    return _cart.totalPrice;
  }
}
