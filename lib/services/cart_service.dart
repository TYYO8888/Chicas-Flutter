import 'package:qsr_app/models/cart.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/models/crew_pack_selection.dart';
import 'package:qsr_app/models/menu_extras.dart';
import 'package:qsr_app/models/combo_selection.dart';

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
    MenuItemExtras? extras,
    ComboMeal? comboMeal,
  }) {
    // Clone the menu item to preserve all customizations
    final clonedMenuItem = menuItem.clone();

    // For combo meals, always add as a new item
    if (comboMeal != null) {
      _cart.items.add(CartItem(
        menuItem: clonedMenuItem,
        quantity: 1,
        selectedSize: selectedSize,
        comboMeal: comboMeal,
      ));
    }
    // For crew packs with sandwich selections, always add as a new item
    else if (crewPackCustomization != null) {
      _cart.items.add(CartItem(
        menuItem: clonedMenuItem,
        quantity: 1,
        selectedSize: selectedSize,
        crewPackCustomization: crewPackCustomization,
        extras: extras,
      ));
    }
    // For crew packs or customizable items, always add as a new item
    else if (customizations != null || extras != null) {
      _cart.items.add(CartItem(
        menuItem: clonedMenuItem,
        quantity: 1,
        selectedSize: selectedSize,
        customizations: customizations,
        extras: extras,
      ));
    } else {
      // For regular items, check if they have customizations (like selected sauces) or extras
      // If they do, always add as a new item to preserve the customizations
      if (clonedMenuItem.selectedSauces?.isNotEmpty == true ||
          clonedMenuItem.selectedBunType != null ||
          selectedSize != null ||
          extras != null) {
        // Item has customizations or extras, add as new item
        _cart.items.add(CartItem(
          menuItem: clonedMenuItem,
          quantity: 1,
          selectedSize: selectedSize,
          extras: extras,
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
            extras: extras,
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

  // Remove a specific cart item by index
  void removeCartItemByIndex(int index) {
    if (index >= 0 && index < _cart.items.length) {
      _cart.items.removeAt(index);
    }
  }

  // Update quantity of a specific cart item by index
  void updateCartItemQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cart.items.length) {
      if (newQuantity <= 0) {
        removeCartItemByIndex(index);
      } else {
        _cart.items[index].quantity = newQuantity;
      }
    }
  }

  // Update a cart item's customizations
  void updateCartItem(int index, {
    String? selectedSize,
    Map<String, List<MenuItem>>? customizations,
    CrewPackCustomization? crewPackCustomization,
  }) {
    if (index >= 0 && index < _cart.items.length) {
      final item = _cart.items[index];
      if (selectedSize != null) {
        item.selectedSize = selectedSize;
      }
      if (customizations != null) {
        item.customizations = customizations;
      }
      if (crewPackCustomization != null) {
        item.crewPackCustomization = crewPackCustomization;
      }
    }
  }

  // Clear all items from cart
  void clearCart() {
    _cart.items.clear();
  }

  // Get cart item count
  int get itemCount => _cart.items.length;

  // Check if cart is empty
  bool get isEmpty => _cart.items.isEmpty;

  // Get cart items (missing method)
  List<CartItem> getCartItems() {
    return _cart.items;
  }

  /// Add a combo meal to cart
  void addComboToCart(ComboMeal combo) {
    addToCart(
      combo.mainItem,
      comboMeal: combo,
    );
  }

  /// Check if an item is eligible for combo upgrade
  bool isComboEligible(MenuItem item) {
    return ComboConfiguration.isComboEligible(item);
  }

  /// Create a combo from a menu item
  ComboMeal createCombo(MenuItem item, {String? selectedSize}) {
    return ComboConfiguration.createCombo(item, selectedSize: selectedSize);
  }

  /// ✅ Update heat level for a cart item
  void updateHeatLevel(CartItem cartItem, String newHeatLevel) {
    // Find the cart item in the list
    final itemIndex = _cart.items.indexOf(cartItem);
    if (itemIndex != -1) {
      if (cartItem.comboMeal != null) {
        // Update heat level for combo meal main item
        cartItem.comboMeal!.mainItem.selectedHeatLevel = newHeatLevel;
      } else {
        // Update heat level for regular item
        cartItem.menuItem.selectedHeatLevel = newHeatLevel;
      }
    }
  }

  /// ✅ Check if cart item has heat level selection capability
  bool canEditHeatLevel(CartItem cartItem) {
    if (cartItem.comboMeal != null) {
      return cartItem.comboMeal!.mainItem.allowsHeatLevelSelection;
    }
    return cartItem.menuItem.allowsHeatLevelSelection;
  }

  /// ✅ Get current heat level for cart item
  String? getCurrentHeatLevel(CartItem cartItem) {
    if (cartItem.comboMeal != null) {
      return cartItem.comboMeal!.mainItem.selectedHeatLevel;
    }
    return cartItem.menuItem.selectedHeatLevel;
  }
}
