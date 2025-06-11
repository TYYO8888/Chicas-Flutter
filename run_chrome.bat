@echo off
echo 🌐 Starting Chica's Chicken Flutter App on Chrome
echo.
echo 🔧 Enabling web support...
flutter config --enable-web
echo.
echo 📦 Getting dependencies...
flutter pub get
echo.
echo 🌐 Launching on Chrome...
echo This will open Chrome browser automatically
echo.
flutter run -d chrome --web-renderer html
echo.
pause
