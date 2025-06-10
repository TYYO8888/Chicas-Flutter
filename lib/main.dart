// This is the main starting point of our app!
import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'layouts/main_layout.dart';
import 'services/navigation_service.dart';
import 'services/theme_service.dart' as theme_service;
import 'services/user_preferences_service.dart';
import 'services/data_sync_service.dart';
import 'services/performance_service.dart';
import 'themes/app_theme.dart';
import 'widgets/offline_indicator.dart';


// This is the main function that runs when the app starts.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Performance: Initialize services asynchronously for faster startup
  final themeService = theme_service.ThemeService();
  final userPreferencesService = UserPreferencesService();
  final dataSyncService = DataSyncService();
  final performanceService = PerformanceService();

  // Initialize critical services first (theme for immediate UI)
  await themeService.initialize();

  // Initialize other services in parallel for faster startup
  await Future.wait([
    userPreferencesService.initialize(),
    dataSyncService.initialize(),
    performanceService.initialize(),
  ]);

  runApp(MyApp(themeService: themeService)); // We tell Flutter to run our main app widget, MyApp.
}

// MyApp is like the main container for our whole app.
// It sets up the basic look and feel using Material Design.
class MyApp extends StatelessWidget {
  final theme_service.ThemeService themeService;

  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is like the main building block for a Material Design app.
    // It sets up things like the app's title, theme, and the first screen to show.
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, child) {
        return PerformanceMonitor(
          child: OfflineIndicator(
            child: MaterialApp(
              title: "Chica's Chicken", // The name of our app
              debugShowCheckedModeBanner: false,
              navigatorKey: NavigationService.navigatorKey,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _getThemeMode(),
              initialRoute: '/',
              routes: {
                '/': (context) => const LoadingScreen(),
                '/home': (context) => const MainLayout(),
                // 🚀 Developer routes removed for production
              },
            ),
          ),
        );
      },
    );
  }

  ThemeMode _getThemeMode() {
    switch (themeService.themeMode) {
      case theme_service.ThemeMode.light:
        return ThemeMode.light;
      case theme_service.ThemeMode.dark:
        return ThemeMode.dark;
      case theme_service.ThemeMode.system:
        return ThemeMode.system;
    }
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
