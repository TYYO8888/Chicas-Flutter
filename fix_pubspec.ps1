Write-Host "FIXING PUBSPEC.YAML AND FLUTTER DEVICE DAEMON ISSUES" -ForegroundColor Green
Write-Host ""

Write-Host "Step 1: Cleaning project completely..." -ForegroundColor Yellow
flutter clean

if (Test-Path ".dart_tool") {
    Remove-Item ".dart_tool" -Recurse -Force
    Write-Host "Removed .dart_tool directory"
}

if (Test-Path "build") {
    Remove-Item "build" -Recurse -Force
    Write-Host "Removed build directory"
}

if (Test-Path "pubspec.lock") {
    Remove-Item "pubspec.lock" -Force
    Write-Host "Removed pubspec.lock"
}

Write-Host ""
Write-Host "Step 2: Getting dependencies with verbose output..." -ForegroundColor Yellow
flutter pub get --verbose

Write-Host ""
Write-Host "Step 3: Checking for dependency resolution..." -ForegroundColor Yellow

if (Test-Path "pubspec.lock") {
    Write-Host "SUCCESS: pubspec.lock created successfully" -ForegroundColor Green
    
    # Check for critical packages
    $lockContent = Get-Content "pubspec.lock" -Raw
    
    if ($lockContent -match "flutter_inappwebview") {
        Write-Host "✓ flutter_inappwebview resolved successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ flutter_inappwebview not found in pubspec.lock" -ForegroundColor Red
    }
    
    if ($lockContent -match "sentry_flutter") {
        Write-Host "✓ sentry_flutter resolved successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ sentry_flutter not found in pubspec.lock" -ForegroundColor Red
    }
    
    if ($lockContent -match "device_info_plus") {
        Write-Host "✓ device_info_plus resolved successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ device_info_plus not found in pubspec.lock" -ForegroundColor Red
    }
    
    if ($lockContent -match "package_info_plus") {
        Write-Host "✓ package_info_plus resolved successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ package_info_plus not found in pubspec.lock" -ForegroundColor Red
    }
} else {
    Write-Host "ERROR: pubspec.lock was not created - dependency resolution failed" -ForegroundColor Red
    Write-Host "Trying to fix dependency conflicts..." -ForegroundColor Yellow
    flutter pub deps
    Write-Host "Retrying pub get..." -ForegroundColor Yellow
    flutter pub get --verbose
}

Write-Host ""
Write-Host "Step 4: Running Flutter doctor..." -ForegroundColor Yellow
flutter doctor

Write-Host ""
Write-Host "Step 5: Testing device daemon stability..." -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "PUBSPEC FIX COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Check if all packages are resolved in pubspec.lock"
Write-Host "2. Uncomment imports in service files if needed"
Write-Host "3. Try running: flutter run -d chrome"
Write-Host ""
