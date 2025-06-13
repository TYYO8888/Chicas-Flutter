@echo off
echo ========================================
echo SAFE DEPENDENCY RESTORATION
echo ========================================
echo.

echo Step 1: Checking if basic Flutter project works...
echo.

if not exist pubspec.yaml (
    echo ❌ ERROR: pubspec.yaml not found
    pause
    exit /b 1
)

if not exist pubspec.lock (
    echo ❌ ERROR: pubspec.lock not found
    echo.
    echo You need to run test_flutter_simple.bat first
    echo This ensures basic dependencies work before adding complex ones
    pause
    exit /b 1
) else (
    echo ✅ Found pubspec.lock - basic dependencies are working
)

echo.
echo Step 2: Backing up current working pubspec.yaml...
if exist pubspec_backup.yaml (
    copy pubspec.yaml pubspec_minimal_working.yaml >nul
    echo ✅ Current minimal pubspec.yaml backed up
) else (
    echo ❌ ERROR: pubspec_backup.yaml not found
    echo Cannot restore original dependencies
    pause
    exit /b 1
)

echo.
echo Step 3: Restoring original dependencies gradually...
echo.
echo This will restore your original pubspec.yaml with all dependencies
echo If it fails, we'll revert to the working minimal version
echo.

copy pubspec_backup.yaml pubspec.yaml >nul
echo ✅ Original pubspec.yaml restored

echo.
echo Step 4: Testing dependency resolution...
echo.
echo Cleaning project first...
flutter clean >nul 2>&1

echo.
echo Getting dependencies (this may take several minutes)...
echo Please be patient...

flutter pub get
if errorlevel 1 (
    echo ❌ FAILED: Original dependencies have conflicts
    echo.
    echo Reverting to minimal working version...
    copy pubspec_minimal_working.yaml pubspec.yaml >nul
    flutter pub get >nul 2>&1
    echo.
    echo ✅ Reverted to working minimal dependencies
    echo.
    echo RECOMMENDATION:
    echo Add dependencies back gradually from pubspec_backup.yaml
    echo Test flutter pub get after each addition
    echo.
    echo COMMON PROBLEMATIC PACKAGES:
    echo - flutter_inappwebview (try older version ^5.8.0)
    echo - sentry_flutter (try without this first)
    echo - device_info_plus (add this last)
    echo.
    pause
    exit /b 1
) else (
    echo ✅ SUCCESS: All original dependencies resolved!
)

echo.
echo Step 5: Verifying critical packages...
if exist pubspec.lock (
    echo ✅ pubspec.lock created successfully
    
    findstr /c:"flutter_inappwebview" pubspec.lock >nul
    if not errorlevel 1 (
        echo ✅ flutter_inappwebview resolved
    ) else (
        echo ⚠️  flutter_inappwebview not found
    )
    
    findstr /c:"sentry_flutter" pubspec.lock >nul
    if not errorlevel 1 (
        echo ✅ sentry_flutter resolved
    ) else (
        echo ⚠️  sentry_flutter not found
    )
    
    findstr /c:"device_info_plus" pubspec.lock >nul
    if not errorlevel 1 (
        echo ✅ device_info_plus resolved
    ) else (
        echo ⚠️  device_info_plus not found
    )
) else (
    echo ❌ CRITICAL ERROR: pubspec.lock not created
)

echo.
echo Step 6: Testing Flutter analyze...
flutter analyze --no-fatal-infos >nul 2>&1
if errorlevel 1 (
    echo ⚠️  WARNING: Flutter analyze found issues
    echo You may need to uncomment imports in service files
) else (
    echo ✅ Flutter analyze passed
)

echo.
echo ========================================
echo RESTORATION COMPLETE
echo ========================================
echo.

if exist pubspec.lock (
    echo ✅ SUCCESS: Original dependencies restored!
    echo.
    echo NEXT STEPS:
    echo 1. Uncomment imports in service files:
    echo    - lib\services\crash_reporting_service.dart
    echo    - lib\services\uat_feedback_service.dart
    echo.
    echo 2. Test your app:
    echo    flutter run -d chrome
    echo.
    echo 3. If you get import errors:
    echo    Check that packages are properly resolved in pubspec.lock
    echo.
) else (
    echo ❌ DEPENDENCY RESTORATION FAILED
    echo.
    echo Your project is using minimal working dependencies
    echo Add back complex dependencies one by one
    echo.
)

pause
