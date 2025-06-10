/// 🔑 Revel Systems API Credentials Configuration
/// 
/// 📋 SETUP INSTRUCTIONS:
/// 1. Log into your Revel Systems dashboard
/// 2. Navigate to Settings > API Management
/// 3. Generate API keys for your environment
/// 4. Copy the credentials and paste them below
/// 5. Save this file and restart your app

class RevelCredentials {
  /// 🏗️ DEVELOPMENT/SANDBOX CREDENTIALS
  /// Use these for testing and development
  static const Map<String, String> development = {
    // 📍 Step 1: Get these from Revel Dashboard > API Keys
    'apiKey': 'YOUR_SANDBOX_API_KEY',
    'apiSecret': 'YOUR_SANDBOX_API_SECRET',
    
    // 📍 Step 2: Get these from Revel Dashboard > Locations
    'establishmentId': 'YOUR_SANDBOX_ESTABLISHMENT_ID',
    
    // 📍 Step 3: Get this from Revel Dashboard > Payment Settings
    'merchantId': 'YOUR_SANDBOX_MERCHANT_ID',
    
    // 📍 Base URL (don't change this)
    'baseUrl': 'https://sandbox.revelsystems.com/api/v1',
  };

  /// 🚀 PRODUCTION CREDENTIALS
  /// Use these for live transactions
  static const Map<String, String> production = {
    // 📍 Step 1: Get these from Revel Dashboard > API Keys
    'apiKey': 'YOUR_PRODUCTION_API_KEY',
    'apiSecret': 'YOUR_PRODUCTION_API_SECRET',
    
    // 📍 Step 2: Get these from Revel Dashboard > Locations  
    'establishmentId': 'YOUR_PRODUCTION_ESTABLISHMENT_ID',
    
    // 📍 Step 3: Get this from Revel Dashboard > Payment Settings
    'merchantId': 'YOUR_PRODUCTION_MERCHANT_ID',
    
    // 📍 Base URL (don't change this)
    'baseUrl': 'https://api.revelsystems.com/api/v1',
  };

  /// ✅ Check if credentials are configured
  static bool get isDevelopmentConfigured {
    return development['apiKey'] != 'YOUR_SANDBOX_API_KEY' &&
           development['apiSecret'] != 'YOUR_SANDBOX_API_SECRET' &&
           development['establishmentId'] != 'YOUR_SANDBOX_ESTABLISHMENT_ID' &&
           development['merchantId'] != 'YOUR_SANDBOX_MERCHANT_ID';
  }

  static bool get isProductionConfigured {
    return production['apiKey'] != 'YOUR_PRODUCTION_API_KEY' &&
           production['apiSecret'] != 'YOUR_PRODUCTION_API_SECRET' &&
           production['establishmentId'] != 'YOUR_PRODUCTION_ESTABLISHMENT_ID' &&
           production['merchantId'] != 'YOUR_PRODUCTION_MERCHANT_ID';
  }

  /// 📋 Get configuration status
  static Map<String, dynamic> get configurationStatus {
    return {
      'development': {
        'configured': isDevelopmentConfigured,
        'apiKey': development['apiKey']?.substring(0, 8) ?? 'Not set',
        'establishmentId': development['establishmentId'],
        'baseUrl': development['baseUrl'],
      },
      'production': {
        'configured': isProductionConfigured,
        'apiKey': production['apiKey']?.substring(0, 8) ?? 'Not set',
        'establishmentId': production['establishmentId'],
        'baseUrl': production['baseUrl'],
      },
    };
  }

  /// 🔧 Get credentials for current environment
  static Map<String, String> getCurrentCredentials(bool isProduction) {
    return isProduction ? production : development;
  }
}

/// 📖 DETAILED SETUP GUIDE
/// 
/// 🔗 WHERE TO FIND YOUR REVEL CREDENTIALS:
/// 
/// 1. 🔑 API KEY & SECRET:
///    - Log into Revel Dashboard
///    - Go to Settings > API Management
///    - Click "Generate New API Key"
///    - Copy the API Key and API Secret
/// 
/// 2. 🏪 ESTABLISHMENT ID:
///    - Go to Settings > Locations
///    - Find your restaurant location
///    - Copy the Establishment ID
/// 
/// 3. 💳 MERCHANT ID:
///    - Go to Settings > Payment Settings
///    - Find your payment processor settings
///    - Copy the Merchant ID
/// 
/// 🔄 EXAMPLE CONFIGURATION:
/// ```dart
/// static const Map<String, String> development = {
///   'apiKey': 'revel_sandbox_ak_1234567890abcdef',
///   'apiSecret': 'revel_sandbox_as_abcdef1234567890',
///   'establishmentId': '12345',
///   'merchantId': 'merchant_67890',
///   'baseUrl': 'https://sandbox.revelsystems.com/api/v1',
/// };
/// ```
/// 
/// ⚠️ SECURITY NOTES:
/// - Never commit real credentials to version control
/// - Use environment variables for production
/// - Rotate API keys regularly
/// - Keep sandbox and production credentials separate
/// 
/// 🧪 TESTING YOUR SETUP:
/// 1. Configure development credentials above
/// 2. Run the app in debug mode
/// 3. Go to payment screen
/// 4. Try processing a test payment
/// 5. Check Revel dashboard for the transaction
/// 
/// 📞 NEED HELP?
/// - Revel Support: https://support.revelsystems.com/
/// - API Documentation: https://developer.revelsystems.com/
/// - Contact your Revel account manager
