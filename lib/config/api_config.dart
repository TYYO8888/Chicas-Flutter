// 🔧 API Configuration
// This file contains all the API endpoints and configuration

import 'package:flutter/foundation.dart';

class ApiConfig {
  // 🌐 Base URLs
  static const String _baseUrlDev = 'http://localhost:3000';
  static const String _baseUrlProd = 'https://your-app.appspot.com';

  // Get the appropriate base URL based on environment
  static String get baseUrl => kDebugMode ? _baseUrlDev : _baseUrlProd;
  static String get apiUrl => '$baseUrl/api';
  
  // 🔐 Authentication Endpoints
  static String get registerUrl => '$apiUrl/auth/register';
  static String get loginUrl => '$apiUrl/auth/login';
  static String get profileUrl => '$apiUrl/auth/profile';
  static String get logoutUrl => '$apiUrl/auth/logout';
  
  // 🍗 Menu Endpoints
  static String get menuCategoriesUrl => '$apiUrl/menu/categories';
  static String menuCategoryUrl(String categoryId) => '$apiUrl/menu/category/$categoryId';
  static String menuItemUrl(String itemId) => '$apiUrl/menu/item/$itemId';
  static String get menuSearchUrl => '$apiUrl/menu/search';
  
  // 🛒 Order Endpoints
  static String get ordersUrl => '$apiUrl/orders';
  static String orderUrl(String orderId) => '$apiUrl/orders/$orderId';
  static String orderStatusUrl(String orderId) => '$apiUrl/orders/$orderId/status';
  static String orderCancelUrl(String orderId) => '$apiUrl/orders/$orderId/cancel';
  
  // 💳 Payment Endpoints
  static String get paymentIntentUrl => '$apiUrl/payments/intent';
  static String get paymentConfirmUrl => '$apiUrl/payments/confirm';
  static String get paymentHistoryUrl => '$apiUrl/payments/history';
  static String get paymentRefundUrl => '$apiUrl/payments/refund';
  
  // 📊 Analytics Endpoints
  static String get analyticsDashboardUrl => '$apiUrl/analytics/dashboard';
  static String get analyticsSalesUrl => '$apiUrl/analytics/sales';
  static String get analyticsMenuUrl => '$apiUrl/analytics/menu-performance';
  
  // ⚙️ Request Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  
  // 📱 App Configuration
  static const String appName = "Chica's Chicken";
  static const String appVersion = '1.0.0';
  
  // 🔑 API Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': '$appName/$appVersion',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
