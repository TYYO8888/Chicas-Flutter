import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../config/revel_config.dart';
import '../models/revel_models.dart';

/// 🏪 Revel Systems API Service
/// Handles all communication with Revel Systems POS and Payment API
class RevelApiService {
  static final RevelApiService _instance = RevelApiService._internal();
  factory RevelApiService() => _instance;
  RevelApiService._internal();

  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;
  final Uuid _uuid = const Uuid();
  
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  /// 🚀 Initialize the API service
  Future<void> initialize() async {
    _secureStorage = const FlutterSecureStorage();
    
    _dio = Dio(BaseOptions(
      baseUrl: RevelConfig.baseUrl,
      connectTimeout: Duration(seconds: RevelConfig.connectTimeout),
      receiveTimeout: Duration(seconds: RevelConfig.receiveTimeout),
      sendTimeout: Duration(seconds: RevelConfig.sendTimeout),
      headers: RevelConfig.defaultHeaders,
    ));

    // Add interceptors
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createRetryInterceptor());

    // Load stored tokens
    await _loadStoredTokens();
    
    // Validate configuration
    if (!RevelConfig.isConfigured) {
      debugPrint('⚠️ Revel API not fully configured: ${RevelConfig.configurationWarnings}');
    }
  }

  /// 🔐 Authentication Methods
  
  /// Authenticate with Revel Systems
  Future<RevelAuthResponse> authenticate({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        RevelConfig.endpoints['auth']!,
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password',
          'client_id': RevelConfig.apiKey,
          'client_secret': RevelConfig.apiSecret,
        },
      );

      final authResponse = RevelAuthResponse.fromJson(response.data);
      
      // Store tokens securely
      await _storeTokens(authResponse);
      
      return authResponse;
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// Refresh access token
  Future<RevelAuthResponse> refreshAccessToken() async {
    if (_refreshToken == null) {
      throw const RevelApiException('No refresh token available');
    }

    try {
      final response = await _dio.post(
        RevelConfig.endpoints['refresh']!,
        data: {
          'refresh_token': _refreshToken,
          'grant_type': 'refresh_token',
          'client_id': RevelConfig.apiKey,
          'client_secret': RevelConfig.apiSecret,
        },
      );

      final authResponse = RevelAuthResponse.fromJson(response.data);
      await _storeTokens(authResponse);
      
      return authResponse;
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// 🛒 Order Management Methods
  
  /// Create a new order
  Future<RevelOrder> createOrder(RevelOrder order) async {
    try {
      final response = await _dio.post(
        RevelConfig.endpoints['orderCreate']!,
        data: order.toJson(),
      );

      return RevelOrder.fromJson(response.data);
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// Get order by ID
  Future<RevelOrder> getOrder(int orderId) async {
    try {
      final response = await _dio.get(
        '${RevelConfig.endpoints['orders']!}$orderId/',
      );

      return RevelOrder.fromJson(response.data);
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// Update order status
  Future<RevelOrder> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _dio.patch(
        RevelConfig.buildUrl(
          RevelConfig.endpoints['orderUpdate']!,
          pathParams: {'id': orderId.toString()},
        ),
        data: {'status': status},
      );

      return RevelOrder.fromJson(response.data);
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// 💳 Payment Processing Methods
  
  /// Create payment for order
  Future<RevelPayment> createPayment({
    required int orderId,
    required String paymentType,
    required double amount,
    String? paymentMethod,
    Map<String, dynamic>? paymentData,
  }) async {
    try {
      final response = await _dio.post(
        RevelConfig.endpoints['paymentCreate']!,
        data: {
          'order_id': orderId,
          'payment_type': paymentType,
          'payment_method': paymentMethod,
          'amount': amount,
          'payment_data': paymentData,
        },
      );

      return RevelPayment.fromJson(response.data);
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// Process payment
  Future<RevelPayment> processPayment(int paymentId) async {
    try {
      final response = await _dio.post(
        '${RevelConfig.endpoints['paymentProcess']!}$paymentId/',
      );

      return RevelPayment.fromJson(response.data);
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// Refund payment
  Future<RevelPayment> refundPayment({
    required int paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      final response = await _dio.post(
        RevelConfig.buildUrl(
          RevelConfig.endpoints['paymentRefund']!,
          pathParams: {'id': paymentId.toString()},
        ),
        data: {
          'amount': amount,
          'reason': reason,
        },
      );

      return RevelPayment.fromJson(response.data);
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// 👤 Customer Management Methods
  
  /// Create customer
  Future<RevelCustomer> createCustomer(RevelCustomer customer) async {
    try {
      final response = await _dio.post(
        RevelConfig.endpoints['customerCreate']!,
        data: customer.toJson(),
      );

      return RevelCustomer.fromJson(response.data);
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// Get customer by ID
  Future<RevelCustomer> getCustomer(int customerId) async {
    try {
      final response = await _dio.get(
        '${RevelConfig.endpoints['customers']!}$customerId/',
      );

      return RevelCustomer.fromJson(response.data);
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// 🍽️ Menu/Product Methods
  
  /// Get all products
  Future<List<RevelProduct>> getProducts() async {
    try {
      final response = await _dio.get(RevelConfig.endpoints['products']!);
      
      final List<dynamic> productsJson = response.data['results'] ?? response.data;
      return productsJson.map((json) => RevelProduct.fromJson(json)).toList();
    } on DioException catch (e) {
      throw RevelApiException.fromDioError(e);
    }
  }

  /// 🔧 Private Helper Methods
  
  /// Create authentication interceptor
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication header if token is available
        if (_accessToken != null && !_isTokenExpired()) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        
        // Add API signature for secure endpoints
        if (options.path.contains('/payments/') || options.path.contains('/orders/')) {
          final signature = _generateApiSignature(
            method: options.method,
            url: options.uri.toString(),
            body: options.data?.toString(),
          );
          options.headers['X-API-Signature'] = signature;
          options.headers['X-API-Timestamp'] = DateTime.now().toUtc().toIso8601String();
          options.headers['X-API-Nonce'] = _uuid.v4();
        }
        
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token expiry
        if (error.response?.statusCode == 401 && _refreshToken != null) {
          try {
            await refreshAccessToken();
            // Retry the original request
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // Refresh failed, clear tokens
            await _clearTokens();
          }
        }
        handler.next(error);
      },
    );
  }

  /// Create logging interceptor
  Interceptor _createLoggingInterceptor() {
    return LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      error: true,
      logPrint: (object) => debugPrint('🏪 Revel API: $object'),
    );
  }

  /// Create retry interceptor
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error) && error.requestOptions.extra['retryCount'] == null) {
          error.requestOptions.extra['retryCount'] = 0;
        }

        final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
        if (retryCount < RevelConfig.maxRetries && _shouldRetry(error)) {
          error.requestOptions.extra['retryCount'] = retryCount + 1;
          
          // Wait before retry
          await Future.delayed(Duration(seconds: RevelConfig.retryDelay));
          
          try {
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // Continue with original error if retry fails
          }
        }
        
        handler.next(error);
      },
    );
  }

  /// Generate API signature for secure requests
  String _generateApiSignature({
    required String method,
    required String url,
    String? body,
  }) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final nonce = _uuid.v4();
    
    final stringToSign = '$method\n$url\n$timestamp\n$nonce\n${body ?? ''}';
    final key = utf8.encode(RevelConfig.apiSecret);
    final bytes = utf8.encode(stringToSign);
    
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    
    return base64.encode(digest.bytes);
  }

  /// Check if current token is expired
  bool _isTokenExpired() {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(minutes: 5)));
  }

  /// Store tokens securely
  Future<void> _storeTokens(RevelAuthResponse authResponse) async {
    _accessToken = authResponse.accessToken;
    _refreshToken = authResponse.refreshToken;
    _tokenExpiry = DateTime.now().add(Duration(seconds: authResponse.expiresIn));

    await _secureStorage.write(key: 'revel_access_token', value: _accessToken);
    await _secureStorage.write(key: 'revel_refresh_token', value: _refreshToken);
    await _secureStorage.write(key: 'revel_token_expiry', value: _tokenExpiry!.toIso8601String());
  }

  /// Load stored tokens
  Future<void> _loadStoredTokens() async {
    _accessToken = await _secureStorage.read(key: 'revel_access_token');
    _refreshToken = await _secureStorage.read(key: 'revel_refresh_token');
    
    final expiryString = await _secureStorage.read(key: 'revel_token_expiry');
    if (expiryString != null) {
      _tokenExpiry = DateTime.parse(expiryString);
    }
  }

  /// Clear stored tokens
  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    
    await _secureStorage.delete(key: 'revel_access_token');
    await _secureStorage.delete(key: 'revel_refresh_token');
    await _secureStorage.delete(key: 'revel_token_expiry');
  }

  /// Check if error should trigger a retry
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           (error.response?.statusCode != null && 
            error.response!.statusCode! >= 500);
  }
}

/// 🚨 Revel API Exception
class RevelApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const RevelApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.details,
  });

  factory RevelApiException.fromDioError(DioException error) {
    String message = 'Unknown error occurred';
    String? code;
    int? statusCode = error.response?.statusCode;
    Map<String, dynamic>? details;

    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['error'] ?? message;
        code = data['code']?.toString();
        details = data;
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Connection timeout';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Receive timeout';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Send timeout';
          break;
        case DioExceptionType.connectionError:
          message = 'Connection error';
          break;
        default:
          message = error.message ?? message;
      }
    }

    return RevelApiException(
      message,
      code: code,
      statusCode: statusCode,
      details: details,
    );
  }

  @override
  String toString() => 'RevelApiException: $message';
}
