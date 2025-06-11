// 🧪 Simple test to verify the testing setup is working
// This file can be deleted after verification

import 'package:flutter_test/flutter_test.dart';
import 'package:qsr_app/services/theme_service.dart';
import 'package:qsr_app/services/crash_reporting_service.dart';

void main() {
  group('Setup Verification Tests', () {
    test('ThemeService can be instantiated', () {
      final themeService = ThemeService();
      expect(themeService, isNotNull);
      expect(themeService.themeMode, isNotNull);
    });

    test('CrashReportingService can be instantiated', () {
      expect(CrashReportingService.instance, isNotNull);
    });

    test('Basic Flutter test framework works', () {
      expect(1 + 1, equals(2));
      expect('hello', isA<String>());
      expect([1, 2, 3], hasLength(3));
    });
  });
}
