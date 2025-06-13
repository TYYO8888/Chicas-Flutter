# Flutter Cleanup and Preparation Script
# Run this as Administrator before reinstalling Flutter

Write-Host "🔧 FLUTTER CLEANUP SCRIPT" -ForegroundColor Green
Write-Host "This script will help clean up your corrupted Flutter installation" -ForegroundColor Yellow
Write-Host ""

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ ERROR: This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "✅ Running as Administrator" -ForegroundColor Green
Write-Host ""

# Step 1: Find Flutter installations
Write-Host "🔍 Step 1: Finding Flutter installations..." -ForegroundColor Cyan

$flutterPaths = @()
$commonPaths = @(
    "C:\flutter",
    "C:\src\flutter", 
    "C:\tools\flutter",
    "$env:USERPROFILE\flutter",
    "$env:LOCALAPPDATA\flutter"
)

foreach ($path in $commonPaths) {
    if (Test-Path $path) {
        $flutterPaths += $path
        Write-Host "Found Flutter at: $path" -ForegroundColor Yellow
    }
}

# Check PATH for Flutter
$pathEnv = [Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [Environment]::GetEnvironmentVariable("PATH", "Machine")
$pathParts = $pathEnv -split ";"
foreach ($part in $pathParts) {
    if ($part -like "*flutter*") {
        Write-Host "Found Flutter in PATH: $part" -ForegroundColor Yellow
        $parentPath = Split-Path $part -Parent
        if ($parentPath -and (Test-Path $parentPath) -and $flutterPaths -notcontains $parentPath) {
            $flutterPaths += $parentPath
        }
    }
}

if ($flutterPaths.Count -eq 0) {
    Write-Host "No Flutter installations found" -ForegroundColor Green
} else {
    Write-Host "Found $($flutterPaths.Count) Flutter installation(s)" -ForegroundColor Yellow
}

Write-Host ""

# Step 2: Remove Flutter directories
if ($flutterPaths.Count -gt 0) {
    Write-Host "🗑️ Step 2: Removing Flutter directories..." -ForegroundColor Cyan
    
    foreach ($path in $flutterPaths) {
        try {
            Write-Host "Removing: $path" -ForegroundColor Yellow
            Remove-Item $path -Recurse -Force -ErrorAction Stop
            Write-Host "✅ Removed: $path" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to remove: $path" -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "🗑️ Step 2: No Flutter directories to remove" -ForegroundColor Green
}

Write-Host ""

# Step 3: Clean PATH environment variables
Write-Host "🧹 Step 3: Cleaning PATH environment variables..." -ForegroundColor Cyan

# Clean User PATH
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath) {
    $cleanUserPath = ($userPath -split ";") | Where-Object { $_ -notlike "*flutter*" } | Where-Object { $_ -ne "" }
    $newUserPath = $cleanUserPath -join ";"
    [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
    Write-Host "✅ Cleaned User PATH" -ForegroundColor Green
}

# Clean System PATH (requires admin)
try {
    $systemPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($systemPath) {
        $cleanSystemPath = ($systemPath -split ";") | Where-Object { $_ -notlike "*flutter*" } | Where-Object { $_ -ne "" }
        $newSystemPath = $cleanSystemPath -join ";"
        [Environment]::SetEnvironmentVariable("PATH", $newSystemPath, "Machine")
        Write-Host "✅ Cleaned System PATH" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ Could not clean System PATH (may require higher privileges)" -ForegroundColor Yellow
}

Write-Host ""

# Step 4: Remove Flutter environment variables
Write-Host "🧹 Step 4: Removing Flutter environment variables..." -ForegroundColor Cyan

$flutterVars = @("FLUTTER_ROOT", "PUB_CACHE", "FLUTTER_HOME")
foreach ($var in $flutterVars) {
    try {
        [Environment]::SetEnvironmentVariable($var, $null, "User")
        [Environment]::SetEnvironmentVariable($var, $null, "Machine")
        Write-Host "✅ Removed $var" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Could not remove $var" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 5: Clear pub cache
Write-Host "🧹 Step 5: Clearing pub cache..." -ForegroundColor Cyan

$pubCachePaths = @(
    "$env:LOCALAPPDATA\Pub\Cache",
    "$env:APPDATA\Pub\Cache",
    "$env:USERPROFILE\.pub-cache"
)

foreach ($path in $pubCachePaths) {
    if (Test-Path $path) {
        try {
            Remove-Item $path -Recurse -Force
            Write-Host "✅ Removed pub cache: $path" -ForegroundColor Green
        } catch {
            Write-Host "⚠️ Could not remove pub cache: $path" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# Step 6: Summary
Write-Host "✅ CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Restart your computer to ensure PATH changes take effect"
Write-Host "2. Download Flutter from: https://docs.flutter.dev/get-started/install/windows"
Write-Host "3. Extract to C:\flutter"
Write-Host "4. Add C:\flutter\bin to your PATH"
Write-Host "5. Open NEW Command Prompt and run: flutter doctor"
Write-Host ""
Write-Host "📋 VERIFICATION COMMANDS:" -ForegroundColor Cyan
Write-Host "flutter --version"
Write-Host "flutter doctor"
Write-Host "flutter config --enable-web"
Write-Host ""

pause
