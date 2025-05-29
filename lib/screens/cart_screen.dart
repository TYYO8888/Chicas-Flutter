import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:qsr_app/models/cart.dart';
import 'package:qsr_app/services/cart_service.dart';

class CartScreen extends StatelessWidget {
  final CartService cartService;

  CartScreen({required this.cartService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: ListView.builder(
        itemCount: cartService.cart.items.length,
        itemBuilder: (context, index) {
          final cartItem = cartService.cart.items[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.menuItem.name,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(cartItem.menuItem.description),
                        SizedBox(height: 4.0),
                        Text(
                          '\$${cartItem.menuItem.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('x${cartItem.quantity}'),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Total: \$${cartService.getTotalPrice().toStringAsFixed(2)}',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
