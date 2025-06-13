@echo off
echo ========================================
echo FIX FLUTTER PUB UPGRADE ERROR
echo ========================================
echo.
echo This script will fix the "pub upgrade" error you're experiencing
echo.

echo Step 1: Checking Flutter installation...
where flutter >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Flutter not found in PATH
    echo Please install Flutter first
    pause
    exit /b 1
)

echo ✅ Flutter found at:
where flutter
echo.

echo Step 2: Clearing Flutter pub cache...
echo.
echo Clearing local pub cache...
if exist "%LOCALAPPDATA%\Pub\Cache" (
    rmdir /s /q "%LOCALAPPDATA%\Pub\Cache"
    echo ✅ Cleared %LOCALAPPDATA%\Pub\Cache
) else (
    echo ℹ️  %LOCALAPPDATA%\Pub\Cache not found
)

if exist "%APPDATA%\Pub\Cache" (
    rmdir /s /q "%APPDATA%\Pub\Cache"
    echo ✅ Cleared %APPDATA%\Pub\Cache
) else (
    echo ℹ️  %APPDATA%\Pub\Cache not found
)

if exist "%USERPROFILE%\.pub-cache" (
    rmdir /s /q "%USERPROFILE%\.pub-cache"
    echo ✅ Cleared %USERPROFILE%\.pub-cache
) else (
    echo ℹ️  %USERPROFILE%\.pub-cache not found
)

echo.
echo Step 3: Clearing Flutter tool cache...
echo.

REM Find Flutter installation directory
for /f "tokens=*" %%i in ('where flutter') do (
    set FLUTTER_BIN=%%i
    goto :found
)
:found

REM Get Flutter root directory (remove \bin\flutter.bat)
for %%i in ("%FLUTTER_BIN%") do set FLUTTER_ROOT=%%~dpi
set FLUTTER_ROOT=%FLUTTER_ROOT:~0,-5%

echo Flutter root: %FLUTTER_ROOT%

if exist "%FLUTTER_ROOT%\bin\cache" (
    echo Clearing Flutter tool cache...
    rmdir /s /q "%FLUTTER_ROOT%\bin\cache"
    echo ✅ Cleared Flutter tool cache
) else (
    echo ℹ️  Flutter cache not found
)

echo.
echo Step 4: Repairing pub cache...
echo.
flutter pub cache repair
if errorlevel 1 (
    echo ⚠️  WARNING: pub cache repair had issues
) else (
    echo ✅ Pub cache repaired
)

echo.
echo Step 5: Testing Flutter after fixes...
echo.
flutter --version
if errorlevel 1 (
    echo ❌ FAILED: Flutter still not working
    echo.
    echo NEXT STEPS:
    echo 1. Your Flutter installation is severely corrupted
    echo 2. You need to completely reinstall Flutter
    echo 3. Delete the entire Flutter directory
    echo 4. Download fresh Flutter from official website
    echo 5. Extract to C:\flutter
    echo 6. Update PATH to point to C:\flutter\bin
    echo.
    pause
    exit /b 1
) else (
    echo ✅ SUCCESS: Flutter is now working!
)

echo.
echo Step 6: Testing Flutter doctor...
echo.
flutter doctor
echo.

echo ========================================
echo FIX COMPLETE
echo ========================================
echo.

echo If Flutter is working now, you can proceed with:
echo 1. test_flutter.bat - to test your project
echo 2. restore_dependencies.bat - to restore your dependencies
echo.

echo If Flutter is still failing, you need to:
echo 1. Completely uninstall Flutter
echo 2. Download fresh Flutter from https://docs.flutter.dev/get-started/install/windows
echo 3. Install to C:\flutter (not C:\src\flutter)
echo 4. Update PATH environment variable
echo 5. Restart computer
echo.

pause
