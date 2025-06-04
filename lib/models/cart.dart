import 'package:qsr_app/models/menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String? selectedSize; // Add this line
  Map<String, List<MenuItem>>? customizations;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.selectedSize, // Add this line
    this.customizations,
  });
}

class Cart {
  final List<CartItem> items = [];

  double get totalPrice {
    double total = 0;
    for (final item in items) {
      double itemPrice = item.menuItem.price;
      if (item.selectedSize != null && item.menuItem.sizes != null && item.menuItem.sizes!.containsKey(item.selectedSize)) {
        itemPrice = item.menuItem.sizes![item.selectedSize]!;
      }
      total += itemPrice * item.quantity;
    }
    return total;
  }
}
