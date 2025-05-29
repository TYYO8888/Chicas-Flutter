import 'package:flutter/material.dart';
import 'package:qsr_app/models/menu_item.dart'; // Import the MenuItem model

class MenuItemScreen extends StatelessWidget {
  final String category;

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
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Center(
        child: Text('Menu Items for $category'), // Placeholder text
      ),
    );
  }
}
