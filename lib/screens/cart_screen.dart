import 'package:flutter/material.dart';
import 'package:qsr_app/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  final CartService cartService;

  const CartScreen({super.key, required this.cartService});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartService.cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cartService.cart.items[index];
                return Dismissible(
                  key: Key(cartItem.menuItem.name + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      widget.cartService.removeItem(cartItem.menuItem,
                          customizations: cartItem.customizations);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${cartItem.menuItem.name} removed from cart'),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            setState(() {
                              widget.cartService.addToCart(cartItem.menuItem,
                                  customizations: cartItem.customizations);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.menuItem.name,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(cartItem.menuItem.description),
                                    if (cartItem.menuItem.selectedSauces?.isNotEmpty ?? false)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          'Sauces: ${cartItem.menuItem.selectedSauces!.join(", ")}',
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    if (cartItem.customizations?.isNotEmpty ?? false)
                                      ...cartItem.customizations!.entries.map((entry) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            '${entry.key}: ${entry.value.map((item) => item.name).join(", ")}',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: cartItem.quantity > 1
                                            ? () {
                                                setState(() {
                                                  widget.cartService.updateQuantity(
                                                      cartItem.menuItem,
                                                      cartItem.quantity - 1,
                                                      customizations:
                                                          cartItem.customizations);
                                                });
                                              }
                                            : null,
                                      ),
                                      Text('${cartItem.quantity}'),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () {
                                          setState(() {
                                            widget.cartService.updateQuantity(
                                                cartItem.menuItem,
                                                cartItem.quantity + 1,
                                                customizations:
                                                    cartItem.customizations);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '\$${(cartItem.menuItem.price * cartItem.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${widget.cartService.getTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement integration with Revel's API to submit the order
                    // This will need to:
                    // 1. Convert cart items to Revel's order format
                    // 2. Include all customizations and sauce selections
                    // 3. Send the order to Revel's endpoint
                    // 4. Handle the response (order confirmation/rejection)
                    // 5. Show appropriate feedback to the user
                    // 6. Clear the cart on successful order
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
