@echo off
echo ========================================
echo VERIFY PATH CLEANUP
echo ========================================
echo.

echo Checking if Flutter paths are removed from PATH...
echo.

echo Current PATH entries containing 'flutter':
echo %PATH% | findstr /i flutter
if not errorlevel 1 (
    echo ❌ FOUND: Flutter paths still in PATH
    echo.
    echo MANUAL ACTION REQUIRED:
    echo 1. Press Win+R, type: sysdm.cpl
    echo 2. Click "Environment Variables"
    echo 3. Edit PATH (both User and System)
    echo 4. Remove ALL entries containing 'flutter'
    echo 5. Click OK to save
    echo 6. RESTART your computer
    echo 7. Run this script again to verify
    echo.
) else (
    echo ✅ SUCCESS: No Flutter paths found in PATH
    echo PATH is clean and ready for fresh Flutter installation
)

echo.
echo Checking if Flutter command is still available...
where flutter >nul 2>&1
if not errorlevel 1 (
    echo ❌ WARNING: Flutter command still found
    echo Location:
    where flutter
    echo.
    echo This means PATH cleanup was not complete
    echo Please restart computer after cleaning PATH
) else (
    echo ✅ SUCCESS: Flutter command removed
    echo Ready for fresh installation
)

echo.
echo ========================================
echo NEXT STEPS
echo ========================================
echo.

if not errorlevel 1 (
    echo PATH CLEANUP NEEDED:
    echo 1. Clean PATH environment variable manually
    echo 2. Restart computer
    echo 3. Run this script again to verify
    echo.
) else (
    echo PATH IS CLEAN - READY FOR INSTALLATION:
    echo.
    echo 1. Download Flutter from: https://docs.flutter.dev/get-started/install/windows
    echo 2. Extract to: C:\flutter
    echo 3. Add C:\flutter\bin to PATH
    echo 4. Restart computer
    echo 5. Run: test_flutter_safe.bat
    echo.
)

pause
