@echo off
echo 🌐 Starting Chica's Chicken Flutter App on Chrome (CanvasKit)
echo.
echo 🔧 Enabling web support...
flutter config --enable-web
echo.
echo 📦 Getting dependencies...
flutter pub get
echo.
echo 🌐 Launching on Chrome with CanvasKit renderer...
echo This provides better performance and animations
echo.
flutter run -d chrome --web-renderer canvaskit
echo.
pause
