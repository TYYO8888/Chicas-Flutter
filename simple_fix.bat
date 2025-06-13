@echo off
echo Starting Flutter pub get...
flutter pub get
echo.
echo Checking if pubspec.lock was created...
if exist pubspec.lock (
    echo SUCCESS: pubspec.lock created
) else (
    echo ERROR: pubspec.lock not created
)
echo.
echo Done!
pause
