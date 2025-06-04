// This is the main starting point of our app!
import 'package:flutter/material.dart';
import 'package:qsr_app/screens/menu_screen.dart'; // Import the MenuScreen
import 'package:qsr_app/screens/cart_screen.dart'; // Import the CartScreen
import 'package:qsr_app/services/cart_service.dart'; // Import the CartService

final CartService cartService = CartService();
// We'll use this later for managing data

// This is the main function that runs when the app starts.
void main() {
  runApp(const MyApp()); // We tell Flutter to run our main app widget, MyApp.
}

// MyApp is like the main container for our whole app.
// It sets up the basic look and feel using Material Design.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is like the main building block for a Material Design app.
    // It sets up things like the app's title, theme, and the first screen to show.
    return MaterialApp(
      title: 'My QSR App', // The name of our app
      theme: ThemeData( // This is where we set the colors and look of our app
        primarySwatch: Colors.red, // The main color of our app (like a bright red!)
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red).copyWith(secondary: Colors.yellow), // A secondary color (like a sunny yellow!)
        visualDensity: VisualDensity.adaptivePlatformDensity, // Makes the app look good on different devices
      ),
      home: const HomeScreen(), // This is the first screen the user will see
    );
  }
}

// HomeScreen is the first screen of our app.
// It's a simple screen that welcomes the user.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold is like a basic structure for a screen in Material Design.
    // It provides a place for the app bar, the main content, and other things.
    return Scaffold(
      appBar: AppBar( // This is the bar at the top of the screen
        title: const Text('My QSR App'), // The title shown in the app bar
        backgroundColor: Theme.of(context).primaryColor, // Use the primary color for the app bar
      ),
      body: Center( // Center widget puts its child widget in the middle of the screen
        child: Column( // Column arranges its children widgets vertically
          mainAxisAlignment: MainAxisAlignment.center, // Center the column content vertically
          children: <Widget>[
            // This is a text widget that displays the app's name.
            Text(
              'Welcome to My QSR App!',
              style: TextStyle(
                fontSize: 24.0, // Make the text bigger
                fontWeight: FontWeight.bold, // Make the text bold
                color: Theme.of(context).primaryColor, // Use the primary color for the text
              ),
            ),
            const SizedBox(height: 20.0), // Add some space between the text and the button
            // This is a button that the user can tap to start ordering.
            ElevatedButton(
              onPressed: () {
                // Navigate to the menu screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Start Ordering'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the cart screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen(cartService: cartService)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('View Cart'),
            ),
            // TODO: Placeholder for future Revel Systems API integration.
            // This is where we will add code to connect to the Revel Systems API
            // to fetch menu items, send orders, etc.
            // We will use the 'http' package for making API calls.
          ],
        ),
      ),
    );
  }
}

// TODO: Suggest a folder structure for future features:
// lib/
//   main.dart (This file)
//   models/ (For data structures like Menu, Item, Cart)
//   services/ (For API calls and other background tasks, like Revel API integration)
//   widgets/ (For reusable UI pieces)
//   screens/ (For different screens like MenuScreen, CartScreen, CheckoutScreen)
//   utils/ (For helper functions)

// TODO: If you need to add Firebase later for notifications or other features,
// you would typically add the necessary Firebase dependencies to your pubspec.yaml file
// and then follow the Firebase setup instructions for Flutter.
// You might add Firebase initialization code in your main() function
// and create new files/folders under lib/ for Firebase-related logic.
