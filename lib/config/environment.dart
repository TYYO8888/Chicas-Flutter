/// 🌍 Environment Configuration for Chica's Chicken
/// Manages environment-specific settings and API keys

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.development;
  
  static Environment get current => _currentEnvironment;
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// 🏪 Revel Systems Configuration
  ///
  /// 📝 TO CONFIGURE REVEL API:
  /// 1. Get credentials from Revel Systems dashboard
  /// 2. Replace the placeholder values below with your actual credentials
  /// 3. For security, consider using environment variables in production
  static const Map<Environment, Map<String, String>> _revelConfig = {
    Environment.development: {
      'baseUrl': 'https://sandbox.revelsystems.com/api/v1',
      // 🔑 REPLACE THESE WITH YOUR ACTUAL REVEL SANDBOX CREDENTIALS:
      'apiKey': 'your_sandbox_api_key_here',           // From Revel Dashboard > API Keys
      'apiSecret': 'your_sandbox_api_secret_here',     // From Revel Dashboard > API Keys
      'establishmentId': 'your_sandbox_establishment_id', // From Revel Dashboard > Locations
      'merchantId': 'your_sandbox_merchant_id',        // From Revel Dashboard > Payment Settings
    },
    Environment.staging: {
      'baseUrl': 'https://staging.revelsystems.com/api/v1',
      // 🔑 REPLACE THESE WITH YOUR ACTUAL REVEL STAGING CREDENTIALS:
      'apiKey': 'your_staging_api_key_here',
      'apiSecret': 'your_staging_api_secret_here',
      'establishmentId': 'your_staging_establishment_id',
      'merchantId': 'your_staging_merchant_id',
    },
    Environment.production: {
      'baseUrl': 'https://api.revelsystems.com/api/v1',
      // 🔑 REPLACE THESE WITH YOUR ACTUAL REVEL PRODUCTION CREDENTIALS:
      'apiKey': 'your_production_api_key_here',
      'apiSecret': 'your_production_api_secret_here',
      'establishmentId': 'your_production_establishment_id',
      'merchantId': 'your_production_merchant_id',
    },
  };

  /// 🔑 Get Revel configuration for current environment
  static Map<String, String> get revelConfig => 
      _revelConfig[_currentEnvironment] ?? _revelConfig[Environment.development]!;

  /// 🌐 Backend API Configuration
  static const Map<Environment, String> _backendUrls = {
    Environment.development: 'http://localhost:3001',
    Environment.staging: 'https://staging-api.chicaschicken.com',
    Environment.production: 'https://api.chicaschicken.com',
  };

  static String get backendUrl => 
      _backendUrls[_currentEnvironment] ?? _backendUrls[Environment.development]!;

  /// 🔥 Firebase Configuration
  static const Map<Environment, Map<String, String>> _firebaseConfig = {
    Environment.development: {
      'projectId': 'chicas-chicken-dev',
      'apiKey': 'dev_firebase_api_key',
      'appId': 'dev_firebase_app_id',
    },
    Environment.staging: {
      'projectId': 'chicas-chicken-staging',
      'apiKey': 'staging_firebase_api_key',
      'appId': 'staging_firebase_app_id',
    },
    Environment.production: {
      'projectId': 'chicas-chicken-prod',
      'apiKey': 'prod_firebase_api_key',
      'appId': 'prod_firebase_app_id',
    },
  };

  static Map<String, String> get firebaseConfig => 
      _firebaseConfig[_currentEnvironment] ?? _firebaseConfig[Environment.development]!;

  /// 📊 Analytics Configuration
  static const Map<Environment, bool> _analyticsEnabled = {
    Environment.development: false,
    Environment.staging: true,
    Environment.production: true,
  };

  static bool get analyticsEnabled => 
      _analyticsEnabled[_currentEnvironment] ?? false;

  /// 🐛 Debug Configuration
  static const Map<Environment, bool> _debugMode = {
    Environment.development: true,
    Environment.staging: true,
    Environment.production: false,
  };

  static bool get debugMode => 
      _debugMode[_currentEnvironment] ?? false;

  /// 📝 Logging Configuration
  static const Map<Environment, String> _logLevel = {
    Environment.development: 'DEBUG',
    Environment.staging: 'INFO',
    Environment.production: 'ERROR',
  };

  static String get logLevel => 
      _logLevel[_currentEnvironment] ?? 'INFO';

  /// 🔐 Security Configuration
  static const Map<Environment, Map<String, dynamic>> _securityConfig = {
    Environment.development: {
      'enableSSLPinning': false,
      'allowHttpTraffic': true,
      'enableCertificateTransparency': false,
    },
    Environment.staging: {
      'enableSSLPinning': true,
      'allowHttpTraffic': false,
      'enableCertificateTransparency': true,
    },
    Environment.production: {
      'enableSSLPinning': true,
      'allowHttpTraffic': false,
      'enableCertificateTransparency': true,
    },
  };

  static Map<String, dynamic> get securityConfig => 
      _securityConfig[_currentEnvironment] ?? _securityConfig[Environment.development]!;

  /// 📱 App Configuration
  static const Map<Environment, Map<String, dynamic>> _appConfig = {
    Environment.development: {
      'appName': "Chica's Chicken (Dev)",
      'bundleId': 'com.chicaschicken.app.dev',
      'versionSuffix': '-dev',
      'enableTestFeatures': true,
    },
    Environment.staging: {
      'appName': "Chica's Chicken (Staging)",
      'bundleId': 'com.chicaschicken.app.staging',
      'versionSuffix': '-staging',
      'enableTestFeatures': true,
    },
    Environment.production: {
      'appName': "Chica's Chicken",
      'bundleId': 'com.chicaschicken.app',
      'versionSuffix': '',
      'enableTestFeatures': false,
    },
  };

  static Map<String, dynamic> get appConfig => 
      _appConfig[_currentEnvironment] ?? _appConfig[Environment.development]!;

  /// 🎯 Feature Flags
  static const Map<Environment, Map<String, bool>> _featureFlags = {
    Environment.development: {
      'enableLoyaltyProgram': true,
      'enablePushNotifications': false,
      'enableAnalytics': false,
      'enableCrashReporting': false,
      'enableBetaFeatures': true,
      'enableMockPayments': true,
      'enableRevelIntegration': false, // Set to true when Revel is configured
    },
    Environment.staging: {
      'enableLoyaltyProgram': true,
      'enablePushNotifications': true,
      'enableAnalytics': true,
      'enableCrashReporting': true,
      'enableBetaFeatures': true,
      'enableMockPayments': false,
      'enableRevelIntegration': true,
    },
    Environment.production: {
      'enableLoyaltyProgram': true,
      'enablePushNotifications': true,
      'enableAnalytics': true,
      'enableCrashReporting': true,
      'enableBetaFeatures': false,
      'enableMockPayments': false,
      'enableRevelIntegration': true,
    },
  };

  static Map<String, bool> get featureFlags => 
      _featureFlags[_currentEnvironment] ?? _featureFlags[Environment.development]!;

  /// 🔧 Helper Methods
  
  /// Check if a feature is enabled
  static bool isFeatureEnabled(String feature) {
    return featureFlags[feature] ?? false;
  }

  /// Get environment display name
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  /// Get environment color for UI
  static String get environmentColor {
    switch (_currentEnvironment) {
      case Environment.development:
        return '#4CAF50'; // Green
      case Environment.staging:
        return '#FF9800'; // Orange
      case Environment.production:
        return '#F44336'; // Red
    }
  }

  /// 📊 Get all configuration as map
  static Map<String, dynamic> get allConfig => {
    'environment': environmentName,
    'isDevelopment': isDevelopment,
    'isStaging': isStaging,
    'isProduction': isProduction,
    'backendUrl': backendUrl,
    'revelConfig': revelConfig,
    'firebaseConfig': firebaseConfig,
    'appConfig': appConfig,
    'featureFlags': featureFlags,
    'securityConfig': securityConfig,
    'analyticsEnabled': analyticsEnabled,
    'debugMode': debugMode,
    'logLevel': logLevel,
  };

  /// ⚠️ Validate configuration
  static List<String> validateConfiguration() {
    final warnings = <String>[];

    // Check Revel configuration
    final revel = revelConfig;
    if (revel['apiKey']?.contains('_here') == true) {
      warnings.add('Revel API key not configured');
    }
    if (revel['apiSecret']?.contains('_here') == true) {
      warnings.add('Revel API secret not configured');
    }
    if (revel['establishmentId']?.contains('_here') == true) {
      warnings.add('Revel establishment ID not configured');
    }

    // Check Firebase configuration
    final firebase = firebaseConfig;
    if (firebase['apiKey']?.contains('_key') == true) {
      warnings.add('Firebase API key not configured');
    }

    // Environment-specific warnings
    if (isProduction && debugMode) {
      warnings.add('Debug mode enabled in production');
    }
    if (isProduction && isFeatureEnabled('enableMockPayments')) {
      warnings.add('Mock payments enabled in production');
    }
    if (isProduction && isFeatureEnabled('enableBetaFeatures')) {
      warnings.add('Beta features enabled in production');
    }

    return warnings;
  }
}

/// 🔧 Environment Helper Extensions
extension EnvironmentHelpers on Environment {
  String get name {
    switch (this) {
      case Environment.development:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.production:
        return 'production';
    }
  }

  bool get isDebug {
    return this == Environment.development || this == Environment.staging;
  }
}
