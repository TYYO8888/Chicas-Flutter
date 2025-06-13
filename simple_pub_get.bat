@echo off
REM Simple Flutter pub get script
echo Starting Flutter pub get...
echo.

REM Check if Flutter is available
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter is not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo Running flutter pub get...
flutter pub get

if errorlevel 1 (
    echo ERROR: flutter pub get failed
    pause
    exit /b 1
) else (
    echo SUCCESS: Dependencies installed successfully
)

echo.
echo Checking pubspec.lock...
if exist pubspec.lock (
    echo SUCCESS: pubspec.lock created
) else (
    echo WARNING: pubspec.lock not found
)

echo.
echo Done!
pause
