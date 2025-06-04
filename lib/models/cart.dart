import 'package:qsr_app/models/menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  Map<String, List<MenuItem>>? customizations;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.customizations,
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
