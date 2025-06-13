@echo off
echo ========================================
echo RESTORE ORIGINAL DEPENDENCIES
echo ========================================
echo.
echo This script will restore your original pubspec.yaml dependencies
echo ONLY run this AFTER test_flutter.bat shows SUCCESS
echo.

echo Checking if Flutter is working...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Flutter not working
    echo Please run test_flutter.bat first and ensure it passes
    pause
    exit /b 1
)

echo ✅ Flutter is available
echo.

echo Checking if pubspec_backup.yaml exists...
if not exist pubspec_backup.yaml (
    echo ❌ ERROR: pubspec_backup.yaml not found
    echo This file contains your original dependencies
    pause
    exit /b 1
)

echo ✅ Backup file found
echo.

echo Creating backup of current working pubspec.yaml...
copy pubspec.yaml pubspec_minimal_working.yaml >nul
echo ✅ Current pubspec.yaml backed up as pubspec_minimal_working.yaml
echo.

echo Restoring original dependencies...
copy pubspec_backup.yaml pubspec.yaml >nul
echo ✅ Original pubspec.yaml restored
echo.

echo Step 1: Testing with basic dependencies first...
echo.
echo Getting dependencies (this may take a while)...
flutter pub get
if errorlevel 1 (
    echo ❌ FAILED: Dependency resolution failed
    echo.
    echo Restoring minimal working version...
    copy pubspec_minimal_working.yaml pubspec.yaml >nul
    echo.
    echo The original dependencies have conflicts.
    echo You'll need to add them back gradually.
    echo.
    echo RECOMMENDED APPROACH:
    echo 1. Start with pubspec_minimal_working.yaml
    echo 2. Add dependencies one by one from pubspec_backup.yaml
    echo 3. Test flutter pub get after each addition
    echo.
    pause
    exit /b 1
)

echo ✅ SUCCESS: All dependencies resolved!
echo.

echo Step 2: Uncommenting service imports...
echo.

REM Check if crash reporting service exists
if exist "lib\services\crash_reporting_service.dart" (
    echo Uncommenting imports in crash_reporting_service.dart...
    REM This is a simple approach - you may need to manually uncomment
    echo ⚠️  MANUAL ACTION REQUIRED:
    echo Please manually uncomment these imports in lib\services\crash_reporting_service.dart:
    echo   - import 'package:device_info_plus/device_info_plus.dart';
    echo   - import 'package:package_info_plus/package_info_plus.dart';
    echo   - import 'package:sentry_flutter/sentry_flutter.dart';
    echo.
)

if exist "lib\services\uat_feedback_service.dart" (
    echo ⚠️  MANUAL ACTION REQUIRED:
    echo Please manually uncomment imports in lib\services\uat_feedback_service.dart
    echo.
)

echo Step 3: Testing final build...
echo.
flutter analyze --no-fatal-infos >nul 2>&1
if errorlevel 1 (
    echo ⚠️  WARNING: Analysis found issues
    echo Check the imports in your service files
) else (
    echo ✅ Analysis passed
)

echo.
echo ========================================
echo RESTORATION COMPLETE
echo ========================================
echo.

echo ✅ SUCCESS: Original dependencies restored!
echo.
echo FINAL STEPS:
echo 1. Manually uncomment imports in service files (see warnings above)
echo 2. Test your app: flutter run -d chrome
echo 3. If you get import errors, the packages may not be properly resolved
echo.
echo TROUBLESHOOTING:
echo - If imports fail: flutter pub get
echo - If build fails: flutter clean && flutter pub get
echo - If device daemon crashes: restart your computer
echo.

echo Press any key to exit...
pause >nul
