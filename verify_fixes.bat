@echo off
echo 🔍 VERIFYING PUBSPEC FIXES AND FLUTTER STABILITY
echo.

echo 📋 Checking current pubspec.yaml configuration...
echo.

echo ✅ Checking for removed conflicting packages...
findstr /c:"webview_flutter:" pubspec.yaml >nul
if not errorlevel 1 (
    echo ❌ ERROR: webview_flutter still present in pubspec.yaml
    echo   This conflicts with flutter_inappwebview and can cause crashes
) else (
    echo ✅ webview_flutter correctly removed
)

findstr /c:"flutter_inappwebview:" pubspec.yaml >nul
if errorlevel 1 (
    echo ❌ ERROR: flutter_inappwebview missing from pubspec.yaml
) else (
    echo ✅ flutter_inappwebview present
)

echo.
echo 📦 Checking pubspec.lock status...
if not exist pubspec.lock (
    echo ❌ ERROR: pubspec.lock missing - dependencies not resolved
    echo   Run: flutter pub get
) else (
    echo ✅ pubspec.lock exists
    
    echo.
    echo 🔍 Checking critical packages in pubspec.lock...
    
    findstr /c:"flutter_inappwebview" pubspec.lock >nul
    if errorlevel 1 (
        echo ❌ flutter_inappwebview not resolved
    ) else (
        echo ✅ flutter_inappwebview resolved
    )
    
    findstr /c:"sentry_flutter" pubspec.lock >nul
    if errorlevel 1 (
        echo ❌ sentry_flutter not resolved
    ) else (
        echo ✅ sentry_flutter resolved
    )
    
    findstr /c:"device_info_plus" pubspec.lock >nul
    if errorlevel 1 (
        echo ❌ device_info_plus not resolved
    ) else (
        echo ✅ device_info_plus resolved
    )
    
    findstr /c:"package_info_plus" pubspec.lock >nul
    if errorlevel 1 (
        echo ❌ package_info_plus not resolved
    ) else (
        echo ✅ package_info_plus resolved
    )
)

echo.
echo 🛠️ Testing Flutter device daemon stability...
echo.

echo Testing flutter devices command...
flutter devices --verbose > device_test.txt 2>&1
if errorlevel 1 (
    echo ❌ flutter devices command failed - device daemon may be unstable
    echo   Check device_test.txt for details
) else (
    echo ✅ flutter devices command successful
)

echo.
echo 🔍 Running quick analysis...
flutter analyze --no-fatal-infos > quick_analysis.txt 2>&1
if errorlevel 1 (
    echo ⚠️  Analysis found issues - check quick_analysis.txt
) else (
    echo ✅ Analysis passed
)

echo.
echo 📊 VERIFICATION SUMMARY:
echo.
echo If all checks show ✅, your pubspec issues are resolved.
echo If any show ❌, run fix_pubspec_issues.bat to apply fixes.
echo.
echo 🚀 Next steps if all good:
echo 1. flutter run -d chrome
echo 2. Test app functionality
echo 3. Monitor for device daemon crashes
echo.
pause
