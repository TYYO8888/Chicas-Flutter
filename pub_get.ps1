# PowerShell script for flutter pub get
Write-Host "Starting Flutter pub get..." -ForegroundColor Green

# Check Flutter installation
try {
    $flutterVersion = flutter --version
    Write-Host "Flutter found:" -ForegroundColor Green
    Write-Host $flutterVersion
} catch {
    Write-Host "ERROR: Flutter not found in PATH" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Running flutter pub get..." -ForegroundColor Yellow

# Run flutter pub get
try {
    flutter pub get
    Write-Host "SUCCESS: Dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "ERROR: flutter pub get failed" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

# Check if pubspec.lock was created
if (Test-Path "pubspec.lock") {
    Write-Host "SUCCESS: pubspec.lock created" -ForegroundColor Green
} else {
    Write-Host "WARNING: pubspec.lock not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
