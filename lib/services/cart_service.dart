import 'package:qsr_app/models/cart.dart';
import 'package:qsr_app/models/menu_item.dart';

class CartService {
  static final Cart _cart = Cart();

  Cart get cart => _cart;

  void addToCart(MenuItem menuItem, {Map<String, List<MenuItem>>? customizations}) {
    // For crew packs or customizable items, always add as a new item
    if (customizations != null) {
      _cart.items.add(CartItem(
        menuItem: menuItem,
        quantity: 1,
        customizations: customizations,
      ));
    } else {
      // For regular items, check if they exist and update quantity
      final existingItem = _cart.items.firstWhere(
        (item) => item.menuItem.name == menuItem.name && item.customizations == null,
        orElse: () => CartItem(menuItem: MenuItem(name: '', description: '', price: 0, imageUrl: '', category: ''), quantity: 0),
      );

      if (existingItem.menuItem.name != '') {
        existingItem.quantity++;
      } else {
        _cart.items.add(CartItem(menuItem: menuItem, quantity: 1));
      }
    }
  }

  void removeItem(MenuItem menuItem, {Map<String, List<MenuItem>>? customizations}) {
    if (customizations != null) {
      // For customized items, remove the specific customized version
      _cart.items.removeWhere((item) =>
          item.menuItem.name == menuItem.name &&
          item.customizations == customizations);
    } else {
      // For regular items, remove all non-customized versions
      _cart.items.removeWhere((item) =>
          item.menuItem.name == menuItem.name &&
          item.customizations == null);
    }
  }

  void updateQuantity(MenuItem menuItem, int quantity,
      {Map<String, List<MenuItem>>? customizations}) {
    final existingItem = _cart.items.firstWhere(
      (item) =>
          item.menuItem.name == menuItem.name &&
          item.customizations == customizations,
      orElse: () => CartItem(
          menuItem: MenuItem(
              name: '', description: '', price: 0, imageUrl: '', category: ''),
          quantity: 0),
    );

    if (existingItem.menuItem.name != '') {
      existingItem.quantity = quantity;
    }
  }

  double getTotalPrice() {
    return _cart.totalPrice;
  }
}
