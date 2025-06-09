// 🧪 Simple Main for Testing Backend Integration
// This is a simplified version to test the API without all the complex UI

import 'package:flutter/material.dart';
import 'screens/api_test_screen.dart';

void main() {
  runApp(const SimpleTestApp());
}

class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chica's Chicken - API Test",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFF5C22), // Chica Orange
        scaffoldBackgroundColor: Colors.white,
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
      ),
      home: const SimpleHomeScreen(),
    );
  }
}

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chica's Chicken - Backend Test"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant,
                size: 100,
                color: Color(0xFFFF5C22),
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome to Chica's Chicken!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Backend Integration Test",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApiTestScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.api),
                label: const Text('Test Backend API'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backend Status:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Colors.green, size: 12),
                          SizedBox(width: 8),
                          Text('Server running on localhost:3000'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Colors.orange, size: 12),
                          SizedBox(width: 8),
                          Text('Firebase: Mock mode (for testing)'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Colors.blue, size: 12),
                          SizedBox(width: 8),
                          Text('API: Ready for testing'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
