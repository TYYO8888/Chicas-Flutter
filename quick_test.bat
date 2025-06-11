@echo off
echo 🚀 COMPREHENSIVE TEST - Launch Fixed App
echo.
echo This will launch the app after comprehensive fixes
echo.

echo 📊 Checking current problem count...
flutter analyze --no-fatal-infos | find /c "error" > error_count.txt
set /p ERROR_COUNT=<error_count.txt
echo Current errors: %ERROR_COUNT%
echo.

echo 📦 Getting dependencies...
flutter pub get
echo.

echo 🌐 Launching on Chrome...
echo The app will open in your default browser
echo.
flutter run -d chrome --web-renderer html
echo.

echo 🎯 COMPREHENSIVE TESTING CHECKLIST:
echo.
echo ✅ BASIC FUNCTIONALITY:
echo 1. App loads without console errors
echo 2. Bottom navigation works (Home, Scan, Menu)
echo 3. All screens load properly
echo.
echo ✅ MENU TESTING:
echo 4. Navigate to Menu screen
echo 5. Categories display correctly
echo 6. Menu items load with images
echo.
echo ✅ EXTRAS TESTING:
echo 7. Click bug icon (🐛) in top-right
echo 8. Try "Simple Extras Test" first
echo 9. Then try "Extras Test Screen"
echo 10. Test sandwich customization
echo.
echo ✅ CART TESTING:
echo 11. Add items to cart
echo 12. View cart contents
echo 13. Check pricing calculations
echo.
echo 📋 Report any remaining issues with specific error messages
echo.
pause
