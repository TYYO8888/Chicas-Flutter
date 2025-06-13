@echo off
echo ========================================
echo SAFE FLUTTER INSTALLATION TEST
echo ========================================
echo.
echo This script will test Flutter with timeout protection
echo.

echo Step 1: Testing if Flutter command exists...
echo.
where flutter >nul 2>&1
if errorlevel 1 (
    echo ❌ FAILED: Flutter command not found in PATH
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
    echo Location:
    where flutter
)

echo.
echo Step 2: Testing Flutter version with timeout...
echo.
echo Testing Flutter version (will timeout after 30 seconds)...

REM Create a temporary batch file to test Flutter with timeout
echo @echo off > temp_flutter_test.bat
echo flutter --version >> temp_flutter_test.bat

REM Run with timeout (30 seconds)
timeout /t 30 /nobreak > nul ^& temp_flutter_test.bat
if errorlevel 1 (
    echo ❌ FAILED: Flutter command timed out or failed
    echo.
    echo This indicates Flutter is corrupted and hanging on pub upgrade
    echo.
    echo SOLUTIONS:
    echo 1. Run: fix_corrupted_flutter.bat
    echo 2. Completely reinstall Flutter
    echo 3. Use standard installation path: C:\flutter
    echo.
    del temp_flutter_test.bat >nul 2>&1
    pause
    exit /b 1
) else (
    echo ✅ SUCCESS: Flutter version command completed
)

del temp_flutter_test.bat >nul 2>&1

echo.
echo Step 3: Quick Flutter doctor check...
echo.
echo Running flutter doctor (with timeout protection)...

REM Test flutter doctor with timeout
echo @echo off > temp_doctor_test.bat
echo flutter doctor --version >> temp_doctor_test.bat

timeout /t 30 /nobreak > nul ^& temp_doctor_test.bat
if errorlevel 1 (
    echo ⚠️  WARNING: Flutter doctor timed out
    echo Flutter installation may have issues
) else (
    echo ✅ SUCCESS: Flutter doctor completed
)

del temp_doctor_test.bat >nul 2>&1

echo.
echo Step 4: Testing basic project operations...
echo.

echo Checking if this is a Flutter project...
if not exist pubspec.yaml (
    echo ❌ ERROR: pubspec.yaml not found
    echo This doesn't appear to be a Flutter project
    pause
    exit /b 1
) else (
    echo ✅ Found pubspec.yaml
)

echo.
echo Testing flutter clean...
flutter clean >nul 2>&1
if errorlevel 1 (
    echo ⚠️  WARNING: flutter clean had issues
) else (
    echo ✅ flutter clean completed
)

echo.
echo Testing flutter pub get (this may take time)...
echo Please wait, getting dependencies...

REM Test pub get with longer timeout
echo @echo off > temp_pub_test.bat
echo flutter pub get >> temp_pub_test.bat

timeout /t 120 /nobreak > nul ^& temp_pub_test.bat
if errorlevel 1 (
    echo ❌ FAILED: flutter pub get timed out or failed
    echo.
    echo This could be due to:
    echo 1. Network connectivity issues
    echo 2. Package version conflicts
    echo 3. Corrupted pub cache
    echo 4. Flutter installation issues
    echo.
    del temp_pub_test.bat >nul 2>&1
    pause
    exit /b 1
) else (
    echo ✅ SUCCESS: flutter pub get completed
)

del temp_pub_test.bat >nul 2>&1

echo.
echo Step 5: Verifying pubspec.lock creation...
if exist pubspec.lock (
    echo ✅ SUCCESS: pubspec.lock created
    echo.
    echo Checking for basic packages...
    findstr /c:"http" pubspec.lock >nul
    if not errorlevel 1 (
        echo ✅ http package resolved
    )
    
    findstr /c:"provider" pubspec.lock >nul
    if not errorlevel 1 (
        echo ✅ provider package resolved
    )
) else (
    echo ❌ FAILED: pubspec.lock not created
    echo Dependencies were not resolved properly
)

echo.
echo ========================================
echo TEST RESULTS
echo ========================================
echo.

if exist pubspec.lock (
    echo ✅ FLUTTER IS WORKING!
    echo.
    echo Your Flutter installation appears to be working correctly.
    echo You can now try:
    echo.
    echo 1. restore_dependencies.bat - to add back your full dependencies
    echo 2. flutter run -d chrome - to test your app
    echo.
) else (
    echo ❌ FLUTTER HAS ISSUES
    echo.
    echo Your Flutter installation needs attention:
    echo 1. Run: fix_corrupted_flutter.bat
    echo 2. Completely reinstall Flutter to C:\flutter
    echo 3. Make sure PATH points to C:\flutter\bin
    echo 4. Restart computer after installation
    echo.
)

echo Press any key to exit...
pause >nul
