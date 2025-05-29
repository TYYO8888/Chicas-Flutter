import 'package:qsr_app/models/menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({
    required this.menuItem,
    required this.quantity,
  });
}

class Cart {
  final List<CartItem> items = [];

  double get totalPrice {
    double total = 0;
    for (final item in items) {
      total += item.menuItem.price * item.quantity;
    }
    return total;
  }
}
