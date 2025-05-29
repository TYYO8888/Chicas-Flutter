import 'package:qsr_app/models/cart.dart';
import 'package:qsr_app/models/menu_item.dart';

class CartService {
  static final Cart _cart = Cart();

  Cart get cart => _cart;

  void addItem(MenuItem menuItem) {
    // Check if the item is already in the cart
    final existingItem = _cart.items.firstWhere(
      (item) => item.menuItem.name == menuItem.name,
      orElse: () => CartItem(menuItem: MenuItem(name: '', description: '', price: 0, imageUrl: '', category: ''), quantity: 0), // Return a dummy CartItem if not found
    );

    if (existingItem.menuItem.name != '') {
      // If the item is already in the cart, increase the quantity
      existingItem.quantity++;
    } else {
      // If the item is not in the cart, add it to the cart with quantity 1
      _cart.items.add(CartItem(menuItem: menuItem, quantity: 1));
    }
  }

  void removeItem(MenuItem menuItem) {
    _cart.items.removeWhere((item) => item.menuItem.name == menuItem.name);
  }

  void updateQuantity(MenuItem menuItem, int quantity) {
    final existingItem = _cart.items.firstWhere(
      (item) => item.menuItem.name == menuItem.name,
      orElse: () => CartItem(menuItem: MenuItem(name: '', description: '', price: 0, imageUrl: '', category: ''), quantity: 0), // Return a dummy CartItem if not found
    );

    if (existingItem.menuItem.name != '') {
      existingItem.quantity = quantity;
    }
  }

  double getTotalPrice() {
    return _cart.totalPrice;
  }
}
