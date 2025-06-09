import 'package:qsr_app/models/cart.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/models/crew_pack_selection.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  static final Cart _cart = Cart();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  Cart get cart => _cart;

  void addToCart(
    MenuItem menuItem, {
    String? selectedSize,
    Map<String, List<MenuItem>>? customizations,
    CrewPackCustomization? crewPackCustomization,
  }) {
    // Clone the menu item to preserve all customizations
    final clonedMenuItem = menuItem.clone();

    // For crew packs with sandwich selections, always add as a new item
    if (crewPackCustomization != null) {
      _cart.items.add(CartItem(
        menuItem: clonedMenuItem,
        quantity: 1,
        selectedSize: selectedSize,
        crewPackCustomization: crewPackCustomization,
      ));
    }
    // For crew packs or customizable items, always add as a new item
    else if (customizations != null) {
      _cart.items.add(CartItem(
        menuItem: clonedMenuItem,
        quantity: 1,
        selectedSize: selectedSize,
        customizations: customizations,
      ));
    } else {
      // For regular items, check if they have customizations (like selected sauces)
      // If they do, always add as a new item to preserve the customizations
      if (clonedMenuItem.selectedSauces?.isNotEmpty == true ||
          clonedMenuItem.selectedBunType != null ||
          selectedSize != null) {
        // Item has customizations, add as new item
        _cart.items.add(CartItem(
          menuItem: clonedMenuItem,
          quantity: 1,
          selectedSize: selectedSize,
        ));
      } else {
        // Check if identical item exists and update quantity
        final existingItem = _cart.items.firstWhere(
          (item) =>
              item.menuItem.id == menuItem.id &&
              item.customizations == null &&
              item.selectedSize == selectedSize &&
              item.crewPackCustomization == null &&
              (item.menuItem.selectedSauces?.isEmpty ?? true) &&
              item.menuItem.selectedBunType == null,
          orElse: () => CartItem(
            menuItem: MenuItem(
              id: 'placeholder',
              name: '',
              description: '',
              price: 0,
              imageUrl: 'assets/placeholder.png',
              category: '',
            ),
            quantity: 0,
          ),
        );

        if (existingItem.menuItem.name.isNotEmpty) {
          existingItem.quantity++;
        } else {
          _cart.items.add(CartItem(
            menuItem: clonedMenuItem,
            quantity: 1,
            selectedSize: selectedSize,
          ));
        }
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
          id: 'placeholder',
          name: '',
          description: '',
          price: 0,
          imageUrl: 'assets/placeholder.png',
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
