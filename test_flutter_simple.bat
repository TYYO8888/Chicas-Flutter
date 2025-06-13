@echo off
echo ========================================
echo SIMPLE FLUTTER TEST
echo ========================================
echo.

echo Step 1: Testing if Flutter command exists...
echo.
where flutter >nul 2>&1
if errorlevel 1 (
    echo ❌ FAILED: Flutter command not found
    pause
    exit /b 1
) else (
    echo ✅ SUCCESS: Flutter command found
    where flutter
)

echo.
echo Step 2: Testing Flutter version (may hang if corrupted)...
echo.
echo If this hangs, press Ctrl+C and reinstall Flutter
echo.

REM Simple test without timeout - if it hangs, user can Ctrl+C
flutter --version
if errorlevel 1 (
    echo ❌ FAILED: Flutter version command failed
    pause
    exit /b 1
) else (
    echo ✅ SUCCESS: Flutter version works
)

echo.
echo Step 3: Testing Flutter doctor...
echo.
flutter doctor
if errorlevel 1 (
    echo ⚠️  WARNING: Flutter doctor had issues
) else (
    echo ✅ SUCCESS: Flutter doctor completed
)

echo.
echo Step 4: Testing project operations...
echo.

if not exist pubspec.yaml (
    echo ❌ ERROR: pubspec.yaml not found
    pause
    exit /b 1
)

echo Cleaning project...
flutter clean
echo.

echo Getting dependencies (this may take time)...
flutter pub get
if errorlevel 1 (
    echo ❌ FAILED: flutter pub get failed
    pause
    exit /b 1
) else (
    echo ✅ SUCCESS: flutter pub get completed
)

echo.
echo Step 5: Checking results...
if exist pubspec.lock (
    echo ✅ SUCCESS: pubspec.lock created
    echo.
    echo Flutter is working correctly!
    echo You can now try: flutter run -d chrome
) else (
    echo ❌ FAILED: pubspec.lock not created
)

echo.
pause
