// This is the main starting point of our app!
import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'layouts/main_layout.dart';
import 'screens/api_test_screen.dart';

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
      title: "Chica's Chicken", // The name of our app
      debugShowCheckedModeBanner: false,      theme: ThemeData(
        // Brand Colors from style guide
        primaryColor: const Color(0xFFFF5C22), // Chica Orange
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'SofiaRoughBlackThree',
            color: Colors.black,
          ),
          displayMedium: TextStyle(
            fontFamily: 'SofiaRoughBlackThree',
            color: Colors.black,
          ),
          displaySmall: TextStyle(
            fontFamily: 'SofiaRoughBlackThree',
            color: Colors.black,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'MontserratBlack',
            color: Colors.black,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'SofiaSans',
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'SofiaSans',
            color: Colors.black,
          ),
        ),
        colorScheme: const ColorScheme(
          primary: Color(0xFFFF5C22), // Chica Orange
          secondary: Color(0xFF9B1C24),
          surface: Colors.white,
          onSurface: Colors.black,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          brightness: Brightness.light,
          error: Color(0xFF9B1C24),
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'SofiaRoughBlackThree',
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/home': (context) => const MainLayout(),
        '/api-test': (context) => const ApiTestScreen(),
      },
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
