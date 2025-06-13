@echo off
echo ========================================
echo FLUTTER INSTALLATION HELPER
echo ========================================
echo.
echo This script will help you prepare for Flutter installation
echo.

echo Step 1: Checking current Flutter installation...
echo.

where flutter >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  WARNING: Flutter command still found in PATH
    echo Current Flutter location:
    where flutter
    echo.
    echo You need to:
    echo 1. Remove Flutter from PATH environment variable
    echo 2. Delete the Flutter directory
    echo 3. Restart your computer
    echo.
) else (
    echo ✅ Good: No Flutter found in PATH
)

echo.
echo Step 2: Checking for Flutter directories...
echo.

if exist "C:\flutter" (
    echo ⚠️  Found: C:\flutter
    echo You should delete this directory
)

if exist "C:\src\flutter" (
    echo ⚠️  Found: C:\src\flutter  
    echo You should delete this directory
)

if exist "%USERPROFILE%\flutter" (
    echo ⚠️  Found: %USERPROFILE%\flutter
    echo You should delete this directory
)

echo.
echo Step 3: Environment variable check...
echo.
echo Current PATH contains:
echo %PATH% | findstr /i flutter
if not errorlevel 1 (
    echo ⚠️  WARNING: PATH still contains Flutter references
    echo You need to clean your PATH environment variable
) else (
    echo ✅ Good: No Flutter found in PATH
)

echo.
echo ========================================
echo MANUAL INSTALLATION STEPS
echo ========================================
echo.
echo 1. CLEAN UP (if warnings shown above):
echo    a. Press Win+R, type: sysdm.cpl
echo    b. Click "Environment Variables"
echo    c. Remove ALL Flutter paths from PATH (both User and System)
echo    d. Delete any Flutter directories found above
echo    e. RESTART YOUR COMPUTER
echo.
echo 2. DOWNLOAD FLUTTER:
echo    a. Go to: https://docs.flutter.dev/get-started/install/windows
echo    b. Download the latest stable Flutter SDK
echo    c. Extract to: C:\flutter (exactly this path)
echo.
echo 3. UPDATE PATH:
echo    a. Press Win+R, type: sysdm.cpl
echo    b. Click "Environment Variables"
echo    c. Edit User PATH variable
echo    d. Add: C:\flutter\bin
echo    e. Click OK to save
echo.
echo 4. RESTART COMPUTER:
echo    This is CRITICAL - restart to apply PATH changes
echo.
echo 5. TEST INSTALLATION:
echo    a. Open NEW Command Prompt (not PowerShell)
echo    b. Run: test_flutter.bat
echo.
echo ========================================
echo DOWNLOAD LINKS
echo ========================================
echo.
echo Flutter SDK: https://docs.flutter.dev/get-started/install/windows
echo.
echo Choose "Windows" and download the stable channel
echo.

echo ========================================
echo TROUBLESHOOTING
echo ========================================
echo.
echo If you get "command not found" errors:
echo - Check PATH environment variable
echo - Restart computer
echo - Use Command Prompt, not PowerShell
echo.
echo If pub get hangs:
echo - Check internet connection
echo - Try: flutter pub cache repair
echo - Disable antivirus temporarily
echo.
echo If device daemon crashes:
echo - Restart computer after Flutter installation
echo - Use: flutter devices --verbose
echo - Check for conflicting packages
echo.

echo Press any key to exit...
pause >nul
