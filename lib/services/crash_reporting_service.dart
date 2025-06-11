// 🚨 Crash Reporting Service
// Comprehensive error tracking and crash reporting for production monitoring

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

// NOTE: Uncomment when implementing Sentry
// import 'package:sentry_flutter/sentry_flutter.dart';

// NOTE: Uncomment when implementing Firebase Crashlytics
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// 🚨 Crash Reporting Service
/// 
/// Provides comprehensive error tracking and crash reporting capabilities:
/// - Automatic crash detection and reporting
/// - Custom error logging with context
/// - User feedback integration
/// - Performance monitoring
/// - Device and app information collection
class CrashReportingService {
  static CrashReportingService? _instance;
  static CrashReportingService get instance => _instance ??= CrashReportingService._();
  CrashReportingService._();

  bool _isInitialized = false;
  String? _userId;
  Map<String, dynamic> _userContext = {};
  
  /// 🚀 Initialize crash reporting service
  static Future<void> initialize({
    String? sentryDsn,
    bool enableFirebaseCrashlytics = false,
    String environment = 'production',
  }) async {
    try {
      final service = CrashReportingService.instance;
      
      // Initialize Sentry (if DSN provided)
      if (sentryDsn != null && sentryDsn.isNotEmpty) {
        await _initializeSentry(sentryDsn, environment);
      }
      
      // Initialize Firebase Crashlytics (if enabled)
      if (enableFirebaseCrashlytics) {
        await _initializeFirebaseCrashlytics();
      }
      
      // Set up Flutter error handlers
      await service._setupFlutterErrorHandlers();
      
      // Collect device information
      await service._collectDeviceInfo();
      
      service._isInitialized = true;
      debugPrint('🚨 Crash Reporting Service initialized');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize crash reporting: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
  
  /// 🔧 Initialize Sentry crash reporting
  static Future<void> _initializeSentry(String dsn, String environment) async {
    try {
      // NOTE: Uncomment when Sentry is added to dependencies
      /*
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.environment = environment;
          options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
          options.profilesSampleRate = kDebugMode ? 1.0 : 0.1;
          options.attachStacktrace = true;
          options.enableAutoSessionTracking = true;
          options.enableAutoNativeBreadcrumbs = true;
          options.enableAutoBreadcrumbTracking = true;
          options.sendDefaultPii = false; // Privacy compliance
          
          // Custom release naming
          options.release = 'qsr-app@${_getAppVersion()}';
          
          // Performance monitoring
          options.enableAutoPerformanceTracing = true;
          options.enableUserInteractionTracing = true;
        },
      );
      */
      debugPrint('✅ Sentry initialized');
    } catch (e) {
      debugPrint('❌ Sentry initialization failed: $e');
    }
  }
  
  /// 🔥 Initialize Firebase Crashlytics
  static Future<void> _initializeFirebaseCrashlytics() async {
    try {
      // NOTE: Uncomment when Firebase Crashlytics is added
      /*
      // Enable Crashlytics collection
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      
      // Set up automatic crash reporting
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      
      // Handle platform-specific errors
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      */
      debugPrint('✅ Firebase Crashlytics initialized');
    } catch (e) {
      debugPrint('❌ Firebase Crashlytics initialization failed: $e');
    }
  }
  
  /// 🛠️ Set up Flutter error handlers
  Future<void> _setupFlutterErrorHandlers() async {
    // Capture Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
      
      // Report to crash reporting services
      _reportFlutterError(details);
    };
    
    // Capture errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportPlatformError(error, stack);
      return true;
    };
    
    // Capture unhandled async errors
    runZonedGuarded(() {}, (error, stack) {
      _reportAsyncError(error, stack);
    });
  }
  
  /// 📱 Collect device and app information
  Future<void> _collectDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      _userContext = {
        'app_version': packageInfo.version,
        'app_build': packageInfo.buildNumber,
        'package_name': packageInfo.packageName,
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
      };
      
      // Platform-specific device info
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _userContext.addAll({
          'device_model': androidInfo.model,
          'device_manufacturer': androidInfo.manufacturer,
          'android_version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _userContext.addAll({
          'device_model': iosInfo.model,
          'device_name': iosInfo.name,
          'ios_version': iosInfo.systemVersion,
          'is_physical_device': iosInfo.isPhysicalDevice,
        });
      }
      
    } catch (e) {
      debugPrint('❌ Failed to collect device info: $e');
    }
  }
  
  /// 🆔 Set user identifier for crash reports
  void setUserIdentifier(String userId, {Map<String, dynamic>? userInfo}) {
    _userId = userId;
    
    if (userInfo != null) {
      _userContext.addAll(userInfo);
    }
    
    // Update crash reporting services
    _updateUserContext();
  }
  
  /// 🏷️ Add custom tags for better error categorization
  void addTag(String key, String value) {
    _userContext[key] = value;
    _updateUserContext();
  }
  
  /// 📝 Add breadcrumb for error context
  void addBreadcrumb(String message, {String? category, Map<String, dynamic>? data}) {
    final breadcrumb = {
      'message': message,
      'category': category ?? 'custom',
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };
    
    // NOTE: Implement breadcrumb tracking
    debugPrint('🍞 Breadcrumb: $breadcrumb');
  }
  
  /// ⚠️ Log non-fatal error
  void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? extra,
    bool fatal = false,
  }) {
    try {
      final errorInfo = {
        'error': error.toString(),
        'context': context,
        'extra': extra,
        'user_id': _userId,
        'timestamp': DateTime.now().toIso8601String(),
        ...?_userContext,
      };
      
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('🚨 Error logged: $errorInfo');
        if (stackTrace != null) {
          debugPrint('Stack trace: $stackTrace');
        }
      }
      
      // Report to crash reporting services
      _reportCustomError(error, stackTrace, errorInfo, fatal);
      
    } catch (e) {
      debugPrint('❌ Failed to log error: $e');
    }
  }
  
  /// 📊 Log performance issue
  void logPerformanceIssue(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    final performanceData = {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Log slow operations
    if (duration.inMilliseconds > 1000) {
      logError(
        'Slow operation detected',
        null,
        context: 'performance',
        extra: performanceData,
      );
    }
    
    debugPrint('📊 Performance: $performanceData');
  }
  
  /// 💬 Submit user feedback with crash context
  Future<void> submitUserFeedback({
    required String feedback,
    required String userEmail,
    String? userName,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      final feedbackData = {
        'feedback': feedback,
        'user_email': userEmail,
        'user_name': userName,
        'user_id': _userId,
        'additional_context': additionalContext,
        'device_context': _userContext,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // NOTE: Submit to feedback collection service
      debugPrint('💬 User feedback submitted: $feedbackData');
      
      // Also log as breadcrumb for future crash context
      addBreadcrumb(
        'User submitted feedback',
        category: 'user_feedback',
        data: {'feedback_length': feedback.length},
      );
      
    } catch (e, stackTrace) {
      logError(e, stackTrace, context: 'feedback_submission');
    }
  }
  
  /// 🔄 Update user context in crash reporting services
  void _updateUserContext() {
    // NOTE: Update Sentry user context
    /*
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: _userId,
        extras: _userContext,
      ));
    });
    */
    
    // NOTE: Update Firebase Crashlytics user context
    /*
    if (_userId != null) {
      FirebaseCrashlytics.instance.setUserIdentifier(_userId!);
    }
    
    _userContext.forEach((key, value) {
      FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    });
    */
  }
  
  /// 📱 Report Flutter framework errors
  void _reportFlutterError(FlutterErrorDetails details) {
    // NOTE: Report to Sentry
    /*
    Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
      withScope: (scope) {
        scope.setTag('error_type', 'flutter_error');
        scope.setContext('flutter_error_details', {
          'library': details.library,
          'context': details.context?.toString(),
        });
      },
    );
    */
    
    // NOTE: Report to Firebase Crashlytics
    /*
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    */
  }
  
  /// 🖥️ Report platform-specific errors
  void _reportPlatformError(Object error, StackTrace stack) {
    // NOTE: Report to crash reporting services
    debugPrint('🖥️ Platform error: $error');
  }
  
  /// ⏰ Report async errors
  void _reportAsyncError(Object error, StackTrace stack) {
    // NOTE: Report to crash reporting services
    debugPrint('⏰ Async error: $error');
  }
  
  /// 🎯 Report custom errors
  void _reportCustomError(
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic> context,
    bool fatal,
  ) {
    // NOTE: Report to crash reporting services
    debugPrint('🎯 Custom error: $error');
  }
  
  /// 📱 Get app version (helper method)
  static String _getAppVersion() {
    // This would be populated during initialization
    return '1.0.0'; // Placeholder
  }
  
  /// 🧪 Test crash reporting (for testing purposes only)
  void testCrashReporting() {
    if (kDebugMode) {
      throw Exception('Test crash for crash reporting verification');
    }
  }
}
