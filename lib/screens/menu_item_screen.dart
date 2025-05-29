import 'package:flutter/material.dart';
import 'package:qsr_app/models/menu_item.dart';
import 'package:qsr_app/services/cart_service.dart';
import 'package:qsr_app/services/menu_service.dart';

final CartService cartService = CartService();

class MenuItemScreen extends StatelessWidget {
  final String category;
  final MenuService _menuService = MenuService();

  MenuItemScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: FutureBuilder<List<MenuItem>>(
          future: _menuService.getMenuItems(category),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final menuItems = snapshot.data!;
              return ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final menuItem = menuItems[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menuItem.name,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(menuItem.description),
                          SizedBox(height: 4.0),
                          Text(
                            '\$${menuItem.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Add the item to the cart
                              cartService.addItem(menuItem);
                              print('${menuItem.name} added to cart');
                            },
                            child: Text('Add to Cart'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
