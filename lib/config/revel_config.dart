/// 🏪 Revel Systems API Configuration
/// Configuration for integrating with Revel Systems POS and Payment API
/// Documentation: https://developer.revelsystems.com/revelsystems/

class RevelConfig {
  // 🌐 API Base URLs
  static const String _sandboxBaseUrl = 'https://sandbox.revelsystems.com/api/v1';
  static const String _productionBaseUrl = 'https://api.revelsystems.com/api/v1';
  
  // 🔧 Environment Configuration
  static const bool _isProduction = false; // Set to true for production
  
  static String get baseUrl => _isProduction ? _productionBaseUrl : _sandboxBaseUrl;
  static bool get isProduction => _isProduction;
  static String get environment => _isProduction ? 'production' : 'sandbox';
  
  // 🔑 API Credentials (These should be stored securely in production)
  // NOTE: Move to environment variables or secure storage
  static const String apiKey = 'YOUR_REVEL_API_KEY'; // Replace with actual API key
  static const String apiSecret = 'YOUR_REVEL_API_SECRET'; // Replace with actual API secret
  static const String establishmentId = 'YOUR_ESTABLISHMENT_ID'; // Replace with actual establishment ID
  
  // 🏪 Store Configuration
  static const String storeId = 'CHICAS_CHICKEN_001'; // Your store identifier
  static const String storeName = "Chica's Chicken";
  static const String storeLocation = 'Main Location';
  
  // 💳 Payment Configuration
  static const String merchantId = 'YOUR_MERCHANT_ID'; // Replace with actual merchant ID
  static const String terminalId = 'TERMINAL_001'; // Terminal identifier
  
  // 📱 App Configuration
  static const String appName = 'Chicas Chicken Mobile';
  static const String appVersion = '1.0.0';
  static const String userAgent = '$appName/$appVersion';
  
  // ⏱️ API Timeouts (in seconds)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 60;
  static const int sendTimeout = 30;
  
  // 🔄 Retry Configuration
  static const int maxRetries = 3;
  static const int retryDelay = 2; // seconds
  
  // 💰 Payment Types Supported by Revel
  static const List<String> supportedPaymentTypes = [
    'CASH',
    'CREDIT_CARD',
    'DEBIT_CARD',
    'GIFT_CARD',
    'MOBILE_PAYMENT', // Apple Pay, Google Pay, etc.
    'LOYALTY_POINTS',
  ];
  
  // 📊 Order Status Mapping
  static const Map<String, String> orderStatusMapping = {
    'PENDING': 'Order received, awaiting preparation',
    'CONFIRMED': 'Order confirmed by restaurant',
    'PREPARING': 'Order is being prepared',
    'READY': 'Order is ready for pickup',
    'COMPLETED': 'Order has been completed',
    'CANCELLED': 'Order has been cancelled',
    'REFUNDED': 'Order has been refunded',
  };
  
  // 🔐 Security Configuration
  static const String signatureMethod = 'HMAC-SHA256';
  static const String timestampFormat = 'yyyy-MM-ddTHH:mm:ssZ';
  
  // 📍 API Endpoints
  static const Map<String, String> endpoints = {
    // Authentication
    'auth': '/auth/token/',
    'refresh': '/auth/refresh/',
    
    // Orders
    'orders': '/orders/',
    'orderCreate': '/orders/create/',
    'orderUpdate': '/orders/{id}/update/',
    'orderStatus': '/orders/{id}/status/',
    
    // Payments
    'payments': '/payments/',
    'paymentCreate': '/payments/create/',
    'paymentProcess': '/payments/process/',
    'paymentRefund': '/payments/{id}/refund/',
    'paymentStatus': '/payments/{id}/status/',
    
    // Products/Menu
    'products': '/products/',
    'categories': '/categories/',
    'modifiers': '/modifiers/',
    
    // Customers
    'customers': '/customers/',
    'customerCreate': '/customers/create/',
    'customerUpdate': '/customers/{id}/update/',
    
    // Loyalty
    'loyalty': '/loyalty/',
    'loyaltyPoints': '/loyalty/points/',
    'loyaltyRewards': '/loyalty/rewards/',
    
    // Reports
    'sales': '/reports/sales/',
    'transactions': '/reports/transactions/',
  };
  
  // 🎯 Request Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': userAgent,
    'X-API-Version': '1.0',
    'X-App-Name': appName,
    'X-App-Version': appVersion,
  };
  
  // 🔑 Authentication Headers
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
  
  // 📝 Validation
  static bool get isConfigured {
    return apiKey != 'YOUR_REVEL_API_KEY' &&
           apiSecret != 'YOUR_REVEL_API_SECRET' &&
           establishmentId != 'YOUR_ESTABLISHMENT_ID' &&
           merchantId != 'YOUR_MERCHANT_ID';
  }
  
  // ⚠️ Configuration Warnings
  static List<String> get configurationWarnings {
    final warnings = <String>[];
    
    if (apiKey == 'YOUR_REVEL_API_KEY') {
      warnings.add('API Key not configured');
    }
    if (apiSecret == 'YOUR_REVEL_API_SECRET') {
      warnings.add('API Secret not configured');
    }
    if (establishmentId == 'YOUR_ESTABLISHMENT_ID') {
      warnings.add('Establishment ID not configured');
    }
    if (merchantId == 'YOUR_MERCHANT_ID') {
      warnings.add('Merchant ID not configured');
    }
    if (!_isProduction) {
      warnings.add('Running in sandbox mode');
    }
    
    return warnings;
  }
  
  // 🌐 Full URL Builder
  static String buildUrl(String endpoint, {Map<String, String>? pathParams}) {
    String url = baseUrl + endpoint;
    
    if (pathParams != null) {
      pathParams.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
    }
    
    return url;
  }
  
  // 📊 Debug Information
  static Map<String, dynamic> get debugInfo => {
    'environment': environment,
    'baseUrl': baseUrl,
    'isConfigured': isConfigured,
    'warnings': configurationWarnings,
    'storeId': storeId,
    'storeName': storeName,
    'appVersion': appVersion,
  };
}

/// 🔐 Revel API Security Helper
class RevelSecurity {
  /// Generate HMAC-SHA256 signature for API requests
  static String generateSignature({
    required String method,
    required String url,
    required String timestamp,
    required String nonce,
    String? body,
  }) {
    // Implementation will be added when we integrate with crypto package
    // This follows Revel's signature generation requirements
    return 'signature_placeholder';
  }
  
  /// Generate unique nonce for requests
  static String generateNonce() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// Generate ISO 8601 timestamp
  static String generateTimestamp() {
    return DateTime.now().toUtc().toIso8601String();
  }
}

/// 🏪 Revel Store Information
class RevelStoreInfo {
  static const Map<String, dynamic> storeDetails = {
    'name': RevelConfig.storeName,
    'location': RevelConfig.storeLocation,
    'storeId': RevelConfig.storeId,
    'timezone': 'America/New_York', // Adjust based on your location
    'currency': 'USD',
    'taxRate': 0.12, // 12% (5% GST + 7% PST for Canada)
    'serviceCharge': 0.0,
    'deliveryFee': 0.0,
    'minimumOrder': 10.00,
  };
  
  static const Map<String, String> businessHours = {
    'monday': '10:00-22:00',
    'tuesday': '10:00-22:00',
    'wednesday': '10:00-22:00',
    'thursday': '10:00-22:00',
    'friday': '10:00-23:00',
    'saturday': '10:00-23:00',
    'sunday': '11:00-21:00',
  };
}

/// 📱 Revel Mobile App Configuration
class RevelMobileConfig {
  // Payment redirect URLs for mobile payments
  static const String paymentSuccessUrl = 'chicaschicken://payment/success';
  static const String paymentCancelUrl = 'chicaschicken://payment/cancel';
  static const String paymentFailureUrl = 'chicaschicken://payment/failure';
  
  // Deep link configuration
  static const String appScheme = 'chicaschicken';
  static const String paymentCallbackPath = '/payment/callback';
  
  // Push notification configuration
  static const String fcmSenderId = 'YOUR_FCM_SENDER_ID';
  static const String apnsTeamId = 'YOUR_APNS_TEAM_ID';
}
