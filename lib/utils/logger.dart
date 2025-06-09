// 📝 App Logger
// This helps us track what's happening in the app

import 'dart:developer' as developer;

class AppLogger {
  static const String _tag = 'ChicasChicken';
  
  // 📝 Info level logging
  static void info(String message) {
    developer.log(
      message,
      name: _tag,
      level: 800, // Info level
    );
  }
  
  // ⚠️ Warning level logging
  static void warning(String message) {
    developer.log(
      message,
      name: _tag,
      level: 900, // Warning level
    );
  }
  
  // 🚨 Error level logging
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  // 🐛 Debug level logging (only in debug mode)
  static void debug(String message) {
    assert(() {
      developer.log(
        message,
        name: _tag,
        level: 700, // Debug level
      );
      return true;
    }());
  }
}
