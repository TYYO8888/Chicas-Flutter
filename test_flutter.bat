@echo off
echo ========================================
echo FLUTTER INSTALLATION TEST
echo ========================================
echo.
echo This script will test if Flutter is working correctly
echo Run this AFTER manually reinstalling Flutter
echo.

echo Step 1: Testing Flutter command availability...
echo.
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ FAILED: Flutter command not found
    echo.
    echo SOLUTION:
    echo 1. Make sure Flutter is installed to C:\flutter
    echo 2. Add C:\flutter\bin to your PATH environment variable
    echo 3. Restart your computer
    echo 4. Open a NEW Command Prompt and try again
    echo.
    pause
    exit /b 1
) else (
    echo ✅ SUCCESS: Flutter command found
)

echo.
echo Step 1.5: Testing for pub upgrade issues...
echo.
flutter --version 2>&1 | findstr /c:"pub upgrade" >nul
if not errorlevel 1 (
    echo ❌ DETECTED: Flutter pub upgrade failure
    echo.
    echo This indicates a corrupted Flutter installation.
    echo.
    echo SOLUTIONS:
    echo 1. Clear Flutter cache: flutter pub cache repair
    echo 2. Delete Flutter cache folder: rmdir /s /q "%LOCALAPPDATA%\Pub\Cache"
    echo 3. Reinstall Flutter completely
    echo.
    echo Trying automatic fix...
    flutter pub cache repair
    echo.
    echo Testing again...
    flutter --version >nul 2>&1
    if errorlevel 1 (
        echo ❌ FAILED: Automatic fix didn't work
        echo You need to reinstall Flutter completely
        pause
        exit /b 1
    ) else (
        echo ✅ SUCCESS: Automatic fix worked
    )
) else (
    echo ✅ SUCCESS: No pub upgrade issues detected
)

echo.
echo Step 2: Checking Flutter version...
echo.
flutter --version
echo.

echo Step 3: Running Flutter doctor...
echo.
flutter doctor
echo.

echo Step 4: Testing pub get with your project...
echo.
echo Cleaning your project first...
flutter clean
echo.
echo Getting dependencies...
flutter pub get
if errorlevel 1 (
    echo ❌ FAILED: pub get failed
    echo.
    echo This might be due to:
    echo 1. Network connectivity issues
    echo 2. Package version conflicts
    echo 3. Corrupted pub cache
    echo.
    echo Try running: flutter pub cache repair
    echo.
    pause
    exit /b 1
) else (
    echo ✅ SUCCESS: pub get completed
)

echo.
echo Step 5: Checking if pubspec.lock was created...
if exist pubspec.lock (
    echo ✅ SUCCESS: pubspec.lock created
    echo.
    echo Checking for critical packages...
    findstr /c:"http" pubspec.lock >nul
    if errorlevel 1 (
        echo ⚠️  WARNING: http package not found
    ) else (
        echo ✅ http package resolved
    )
    
    findstr /c:"provider" pubspec.lock >nul
    if errorlevel 1 (
        echo ⚠️  WARNING: provider package not found
    ) else (
        echo ✅ provider package resolved
    )
) else (
    echo ❌ FAILED: pubspec.lock not created
    echo Dependencies were not resolved properly
)

echo.
echo Step 6: Testing web build capability...
echo.
flutter config --enable-web >nul 2>&1
flutter build web --no-sound-null-safety >nul 2>&1
if errorlevel 1 (
    echo ⚠️  WARNING: Web build failed
    echo This is not critical for basic functionality
) else (
    echo ✅ SUCCESS: Web build works
)

echo.
echo Step 7: Testing device detection...
echo.
flutter devices
echo.

echo ========================================
echo TEST COMPLETE
echo ========================================
echo.

if exist pubspec.lock (
    echo ✅ FLUTTER IS WORKING!
    echo.
    echo Your Flutter installation appears to be working correctly.
    echo You can now:
    echo.
    echo 1. Add back your original dependencies from pubspec_backup.yaml
    echo 2. Uncomment imports in your service files
    echo 3. Run: flutter run -d chrome
    echo.
    echo NEXT STEPS:
    echo - Copy dependencies from pubspec_backup.yaml to pubspec.yaml
    echo - Run: flutter pub get
    echo - Test your app: flutter run -d chrome
) else (
    echo ❌ FLUTTER INSTALLATION HAS ISSUES
    echo.
    echo Please check the errors above and:
    echo 1. Ensure Flutter is properly installed
    echo 2. Check your PATH environment variable
    echo 3. Restart your computer
    echo 4. Try running this test again
)

echo.
echo Press any key to exit...
pause >nul
