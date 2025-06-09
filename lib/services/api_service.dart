// 🌐 API Service
// This handles all communication with our backend

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:firebase_auth/firebase_auth.dart'; // Temporarily disabled
import '../config/api_config.dart';
import '../models/menu_item.dart';
import '../utils/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // final FirebaseAuth _auth = FirebaseAuth.instance; // Temporarily disabled

  // 🔑 Get current user's auth token (mock for testing)
  Future<String?> _getAuthToken() async {
    try {
      // For testing without Firebase, return a mock token
      return 'mock-auth-token-for-testing';
    } catch (e) {
      AppLogger.error('Failed to get auth token: $e');
      return null;
    }
  }

  // 🌐 Generic HTTP request method
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      // Prepare headers
      Map<String, String> headers = {...ApiConfig.defaultHeaders};
      
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      // Add auth token if required
      if (requireAuth) {
        final token = await _getAuthToken();
        if (token == null) {
          throw Exception('Authentication required');
        }
        headers['Authorization'] = 'Bearer $token';
      }

      // Prepare request
      late http.Response response;
      final uri = Uri.parse(url);

      AppLogger.info('$method $url');

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers)
              .timeout(ApiConfig.requestTimeout);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(ApiConfig.requestTimeout);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(ApiConfig.requestTimeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers)
              .timeout(ApiConfig.requestTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      AppLogger.info('Response: ${response.statusCode}');

      // Parse response
      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(
          message: responseData['error'] ?? 'Request failed',
          statusCode: response.statusCode,
          details: responseData,
        );
      }
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on HttpException {
      throw ApiException(
        message: 'Network error occurred',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      
      AppLogger.error('API request failed: $e');
      throw ApiException(
        message: 'An unexpected error occurred',
        statusCode: 0,
      );
    }
  }

  // 📋 Menu API Methods
  Future<List<MenuCategory>> getMenuCategories() async {
    try {
      final response = await _makeRequest('GET', ApiConfig.menuCategoriesUrl);
      
      final List<dynamic> categoriesData = response['data'];
      return categoriesData
          .map((data) => MenuCategory.fromJson(data))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to fetch menu categories: $e');
      rethrow;
    }
  }

  Future<List<MenuItem>> getMenuItems(String categoryId) async {
    try {
      final response = await _makeRequest(
        'GET', 
        ApiConfig.menuCategoryUrl(categoryId)
      );
      
      final List<dynamic> itemsData = response['data'];
      return itemsData
          .map((data) => MenuItem.fromJson(data))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to fetch menu items for $categoryId: $e');
      rethrow;
    }
  }

  Future<MenuItem> getMenuItem(String itemId) async {
    try {
      final response = await _makeRequest(
        'GET', 
        ApiConfig.menuItemUrl(itemId)
      );
      
      return MenuItem.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Failed to fetch menu item $itemId: $e');
      rethrow;
    }
  }

  Future<List<MenuItem>> searchMenuItems(String query, {String? category}) async {
    try {
      String url = '${ApiConfig.menuSearchUrl}?q=${Uri.encodeComponent(query)}';
      if (category != null) {
        url += '&category=${Uri.encodeComponent(category)}';
      }
      
      final response = await _makeRequest('GET', url);
      
      final List<dynamic> itemsData = response['data'];
      return itemsData
          .map((data) => MenuItem.fromJson(data))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to search menu items: $e');
      rethrow;
    }
  }

  // 🛒 Order API Methods
  Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _makeRequest(
        'POST',
        ApiConfig.ordersUrl,
        body: orderData,
        requireAuth: true,
      );
      
      return response['data']['orderId'];
    } catch (e) {
      AppLogger.error('Failed to create order: $e');
      rethrow;
    }
  }

  Future<List<Order>> getUserOrders({int limit = 10, String? status}) async {
    try {
      String url = '${ApiConfig.ordersUrl}?limit=$limit';
      if (status != null) {
        url += '&status=${Uri.encodeComponent(status)}';
      }
      
      final response = await _makeRequest(
        'GET',
        url,
        requireAuth: true,
      );
      
      final List<dynamic> ordersData = response['data'];
      return ordersData
          .map((data) => Order.fromJson(data))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to fetch user orders: $e');
      rethrow;
    }
  }

  Future<Order> getOrder(String orderId) async {
    try {
      final response = await _makeRequest(
        'GET',
        ApiConfig.orderUrl(orderId),
        requireAuth: true,
      );
      
      return Order.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Failed to fetch order $orderId: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      await _makeRequest(
        'PUT',
        ApiConfig.orderCancelUrl(orderId),
        body: reason != null ? {'reason': reason} : null,
        requireAuth: true,
      );
    } catch (e) {
      AppLogger.error('Failed to cancel order $orderId: $e');
      rethrow;
    }
  }

  // 💳 Payment API Methods
  Future<String> createPaymentIntent(double amount, String orderId) async {
    try {
      final response = await _makeRequest(
        'POST',
        ApiConfig.paymentIntentUrl,
        body: {
          'amount': amount,
          'orderId': orderId,
          'currency': 'usd',
        },
        requireAuth: true,
      );
      
      return response['data']['clientSecret'];
    } catch (e) {
      AppLogger.error('Failed to create payment intent: $e');
      rethrow;
    }
  }

  Future<void> confirmPayment(String paymentIntentId, String orderId) async {
    try {
      await _makeRequest(
        'POST',
        ApiConfig.paymentConfirmUrl,
        body: {
          'paymentIntentId': paymentIntentId,
          'orderId': orderId,
        },
        requireAuth: true,
      );
    } catch (e) {
      AppLogger.error('Failed to confirm payment: $e');
      rethrow;
    }
  }
}

// 🚨 Custom Exception Class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? details;

  ApiException({
    required this.message,
    required this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// 📋 Menu Category Model
class MenuCategory {
  final String id;
  final String name;
  final int displayOrder;

  MenuCategory({
    required this.id,
    required this.name,
    required this.displayOrder,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'],
      name: json['name'],
      displayOrder: json['displayOrder'],
    );
  }
}

// 🛒 Order Model
class Order {
  final String id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? estimatedReady;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.estimatedReady,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      status: json['status'],
      totalAmount: json['totalAmount'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      estimatedReady: json['estimatedReady'] != null 
          ? DateTime.parse(json['estimatedReady']) 
          : null,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

// 🛒 Order Item Model
class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final Map<String, dynamic>? customizations;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.customizations,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      customizations: json['customizations'],
    );
  }
}
