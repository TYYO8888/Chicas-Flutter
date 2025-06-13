@echo off
echo FLUTTER INSTALLATION VERIFICATION
echo This script will verify your new Flutter installation
echo.

echo Step 1: Checking Flutter command availability...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter command not found
    echo Make sure Flutter is in your PATH
    echo.
    echo To fix:
    echo 1. Add C:\flutter\bin to your PATH environment variable
    echo 2. Restart Command Prompt
    echo 3. Run this script again
    pause
    exit /b 1
) else (
    echo SUCCESS: Flutter command found
)

echo.
echo Step 2: Checking Flutter version...
flutter --version

echo.
echo Step 3: Running Flutter doctor...
flutter doctor

echo.
echo Step 4: Testing pub get with minimal project...
cd /d %TEMP%
if exist flutter_test_project rmdir /s /q flutter_test_project

echo Creating test project...
flutter create flutter_test_project >nul 2>&1
if errorlevel 1 (
    echo ERROR: Could not create test project
    pause
    exit /b 1
)

cd flutter_test_project
echo Testing pub get...
flutter pub get
if errorlevel 1 (
    echo ERROR: pub get failed
    echo Your Flutter installation may still have issues
    pause
    exit /b 1
) else (
    echo SUCCESS: pub get worked
)

echo.
echo Step 5: Testing web build...
flutter build web >nul 2>&1
if errorlevel 1 (
    echo WARNING: Web build failed
    echo You may need to enable web support: flutter config --enable-web
) else (
    echo SUCCESS: Web build worked
)

echo.
echo Cleaning up test project...
cd /d %TEMP%
rmdir /s /q flutter_test_project

echo.
echo VERIFICATION COMPLETE!
echo.
if not errorlevel 1 (
    echo SUCCESS: Flutter installation appears to be working correctly
    echo You can now return to your project and run:
    echo   cd "d:\Bizness\7thSenseMediaLabz\Chica's Chicken Flutter"
    echo   flutter clean
    echo   flutter pub get
) else (
    echo WARNING: Some issues were found
    echo Please review the output above and fix any issues
)

echo.
pause
