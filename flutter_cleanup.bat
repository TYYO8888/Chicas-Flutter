@echo off
echo FLUTTER CLEANUP SCRIPT
echo This will help clean up your corrupted Flutter installation
echo.

echo Step 1: Checking for Flutter installations...
echo.

REM Check common Flutter locations
if exist "C:\flutter" (
    echo Found Flutter at C:\flutter
    echo Removing C:\flutter...
    rmdir /s /q "C:\flutter"
    if not exist "C:\flutter" (
        echo SUCCESS: Removed C:\flutter
    ) else (
        echo WARNING: Could not fully remove C:\flutter
    )
)

if exist "C:\src\flutter" (
    echo Found Flutter at C:\src\flutter
    echo Removing C:\src\flutter...
    rmdir /s /q "C:\src\flutter"
)

if exist "C:\tools\flutter" (
    echo Found Flutter at C:\tools\flutter
    echo Removing C:\tools\flutter...
    rmdir /s /q "C:\tools\flutter"
)

if exist "%USERPROFILE%\flutter" (
    echo Found Flutter at %USERPROFILE%\flutter
    echo Removing %USERPROFILE%\flutter...
    rmdir /s /q "%USERPROFILE%\flutter"
)

echo.
echo Step 2: Clearing pub cache...
if exist "%LOCALAPPDATA%\Pub\Cache" (
    rmdir /s /q "%LOCALAPPDATA%\Pub\Cache"
    echo Cleared local pub cache
)

if exist "%APPDATA%\Pub\Cache" (
    rmdir /s /q "%APPDATA%\Pub\Cache"
    echo Cleared roaming pub cache
)

if exist "%USERPROFILE%\.pub-cache" (
    rmdir /s /q "%USERPROFILE%\.pub-cache"
    echo Cleared user pub cache
)

echo.
echo CLEANUP COMPLETE!
echo.
echo NEXT STEPS:
echo 1. Manually remove Flutter from PATH environment variable:
echo    - Press Win+R, type sysdm.cpl, press Enter
echo    - Click Environment Variables
echo    - Remove any Flutter paths from PATH
echo.
echo 2. Download fresh Flutter from:
echo    https://docs.flutter.dev/get-started/install/windows
echo.
echo 3. Extract to C:\flutter
echo.
echo 4. Add C:\flutter\bin to PATH
echo.
echo 5. Restart computer
echo.
echo 6. Test with: flutter doctor
echo.
pause
