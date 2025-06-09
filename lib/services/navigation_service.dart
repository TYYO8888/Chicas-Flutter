import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static void navigateToMainLayoutPage(int pageIndex) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Pop all routes and navigate to main layout with specific page
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
        arguments: {'initialPage': pageIndex},
      );
    }
  }
  
  static void navigateToHome() {
    navigateToMainLayoutPage(0);
  }
  
  static void navigateToScan() {
    navigateToMainLayoutPage(1);
  }
  
  static void navigateToMenu() {
    navigateToMainLayoutPage(2);
  }
  
  static void navigateToCart() {
    navigateToMainLayoutPage(3);
  }
  
  static void navigateToMore() {
    navigateToMainLayoutPage(4);
  }
}
