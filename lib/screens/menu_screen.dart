import 'package:flutter/material.dart';
import 'package:qsr_app/screens/menu_item_screen.dart'; // Import the MenuItemScreen
// Import the MenuItem model

class MenuScreen extends StatelessWidget {
  // Placeholder menu categories
  final List<String> menuCategories = const [
    'CREW Combos',
    'Whole Wings',
    'Chicken Bites',
    'Chicken Pieces',
    'Sandwiches',
    'Sides',
    'Fixin\'s',
    'Sauces',
    'Beverages',
  ];

  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Show 2 categories per row
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0, // Make the grid items square
        ),
        itemCount: menuCategories.length,
        itemBuilder: (context, index) {
          final category = menuCategories[index];
          return InkWell( // Make the grid item tappable
            onTap: () {
              // Navigate to the menu items screen for this category
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuItemScreen(category: category),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Placeholder image
                  Image.asset(
                    'assets/CC-Penta-3.png', // Replace with actual image URL
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
