@echo off
REM 🧪 Comprehensive Testing Script for QSR Flutter App (Windows)
REM Runs all test suites and generates reports

echo 🧪 Starting Comprehensive Test Suite for QSR App
echo.

REM Create reports directory
if not exist reports mkdir reports

echo ℹ️  Checking prerequisites...

REM Check Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed
    exit /b 1
)

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed
    exit /b 1
)

echo ✅ Prerequisites check completed
echo.

REM Install dependencies
echo ℹ️  Installing dependencies...
flutter pub get

REM Install Newman if Node.js is available
npm install -g newman newman-reporter-htmlextra >nul 2>&1
if not errorlevel 1 (
    echo ✅ Newman installed for API testing
)

echo.

REM 1. Code Quality & Static Analysis
echo ℹ️  🔍 Running code quality analysis...

flutter analyze --fatal-infos > reports\analysis_report.txt 2>&1
if not errorlevel 1 (
    echo ✅ Code analysis passed
) else (
    echo ⚠️  Code analysis found issues - check reports\analysis_report.txt
)

dart format --set-exit-if-changed . > reports\format_report.txt 2>&1
if not errorlevel 1 (
    echo ✅ Code formatting is correct
) else (
    echo ⚠️  Code formatting issues found - check reports\format_report.txt
)

echo.

REM 2. Unit Tests
echo ℹ️  🧪 Running unit tests...

flutter test --coverage --reporter=json > reports\unit_test_results.json 2>&1
if not errorlevel 1 (
    echo ✅ Unit tests passed
) else (
    echo ❌ Unit tests failed - check reports\unit_test_results.json
)

echo.

REM 3. Widget Tests
echo ℹ️  🎨 Running widget tests...

flutter test test\widget\ --reporter=json > reports\widget_test_results.json 2>&1
if not errorlevel 1 (
    echo ✅ Widget tests passed
) else (
    echo ⚠️  Widget tests failed or not found - check reports\widget_test_results.json
)

echo.

REM 4. Integration Tests
echo ℹ️  🌐 Running integration tests...

REM Enable web support for testing
flutter config --enable-web

REM Run integration tests on web
flutter test integration_test\ -d web-server --reporter=json > reports\integration_test_results.json 2>&1
if not errorlevel 1 (
    echo ✅ Integration tests passed
) else (
    echo ⚠️  Integration tests failed - check reports\integration_test_results.json
)

echo.

REM 5. API Tests (if Newman is available)
newman --version >nul 2>&1
if not errorlevel 1 (
    echo ℹ️  🌐 Running API tests...
    
    if exist "postman\QSR_API_Tests.postman_collection.json" (
        newman run postman\QSR_API_Tests.postman_collection.json -e postman\environments\staging.postman_environment.json --reporters cli,json,htmlextra --reporter-json-export reports\api_test_results.json --reporter-htmlextra-export reports\api_test_report.html --timeout-request 10000 > reports\api_test_output.txt 2>&1
        
        if not errorlevel 1 (
            echo ✅ API tests passed
        ) else (
            echo ⚠️  API tests failed - check reports\api_test_output.txt
        )
    ) else (
        echo ⚠️  Postman collection not found - skipping API tests
    )
) else (
    echo ⚠️  Newman not available - skipping API tests
)

echo.

REM 6. Performance Tests
echo ℹ️  📱 Running performance tests...

flutter build web --release > reports\build_output.txt 2>&1
if not errorlevel 1 (
    echo ✅ App built successfully for performance testing
    
    REM Basic performance check
    echo Build size analysis: > reports\performance_report.txt
    dir build\web /s /-c >> reports\performance_report.txt
    
    echo ✅ Performance analysis completed
) else (
    echo ❌ Build failed - check reports\build_output.txt
)

echo.

REM 7. Security Tests
echo ℹ️  🔒 Running security tests...

echo Security scan results: > reports\security_report.txt
echo ====================== >> reports\security_report.txt

findstr /r /s /i "password.*=" lib\*.dart | findstr /v "//" >> reports\security_report.txt 2>nul
if not errorlevel 1 (
    echo ⚠️  Potential hardcoded passwords found - check reports\security_report.txt
) else (
    echo ✅ No hardcoded passwords detected >> reports\security_report.txt
    echo ✅ No hardcoded passwords detected
)

findstr /r /s /i "SELECT.*FROM" lib\*.dart | findstr /v "//" >> reports\security_report.txt 2>nul
if not errorlevel 1 (
    echo ⚠️  Potential SQL injection patterns found - check reports\security_report.txt
) else (
    echo ✅ No SQL injection patterns detected >> reports\security_report.txt
    echo ✅ No SQL injection patterns detected
)

echo.

REM 8. Generate Summary Report
echo ℹ️  📊 Generating test summary report...

(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo     ^<title^>QSR App - Test Results Summary^</title^>
echo     ^<style^>
echo         body { font-family: Arial, sans-serif; margin: 20px; }
echo         .header { background: #2196F3; color: white; padding: 20px; border-radius: 8px; }
echo         .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 8px; }
echo         .success { background: #e8f5e8; border-color: #4caf50; }
echo         .warning { background: #fff3cd; border-color: #ffc107; }
echo         .error { background: #f8d7da; border-color: #dc3545; }
echo         .timestamp { color: #666; font-size: 0.9em; }
echo     ^</style^>
echo ^</head^>
echo ^<body^>
echo     ^<div class="header"^>
echo         ^<h1^>🧪 QSR App - Comprehensive Test Results^</h1^>
echo         ^<p class="timestamp"^>Generated on: %date% %time%^</p^>
echo     ^</div^>
echo     
echo     ^<div class="section success"^>
echo         ^<h2^>✅ Test Suite Completion^</h2^>
echo         ^<p^>All test suites have been executed. Check individual reports for detailed results.^</p^>
echo     ^</div^>
echo     
echo     ^<div class="section"^>
echo         ^<h2^>📋 Available Reports^</h2^>
echo         ^<ul^>
echo             ^<li^>^<a href="analysis_report.txt"^>Code Analysis Report^</a^>^</li^>
echo             ^<li^>^<a href="unit_test_results.json"^>Unit Test Results^</a^>^</li^>
echo             ^<li^>^<a href="widget_test_results.json"^>Widget Test Results^</a^>^</li^>
echo             ^<li^>^<a href="integration_test_results.json"^>Integration Test Results^</a^>^</li^>
echo             ^<li^>^<a href="api_test_report.html"^>API Test Report^</a^>^</li^>
echo             ^<li^>^<a href="security_report.txt"^>Security Scan Report^</a^>^</li^>
echo             ^<li^>^<a href="performance_report.txt"^>Performance Analysis^</a^>^</li^>
echo         ^</ul^>
echo     ^</div^>
echo     
echo     ^<div class="section"^>
echo         ^<h2^>🚀 Next Steps^</h2^>
echo         ^<ol^>
echo             ^<li^>Review any failed tests and fix issues^</li^>
echo             ^<li^>Check code coverage and add tests for uncovered areas^</li^>
echo             ^<li^>Address any security warnings^</li^>
echo             ^<li^>Monitor performance metrics^</li^>
echo             ^<li^>Deploy to staging environment for UAT^</li^>
echo         ^</ol^>
echo     ^</div^>
echo ^</body^>
echo ^</html^>
) > reports\test_summary.html

echo ✅ Test summary report generated at reports\test_summary.html

echo.
echo ✅ 🎉 Comprehensive test suite completed!
echo.
echo 📊 Summary:
echo - Reports generated in: .\reports\
echo - Open reports\test_summary.html for overview
echo - Check individual report files for detailed results
echo.
echo 🔗 Useful commands:
echo - flutter test: Run unit tests only
echo - flutter test integration_test\: Run integration tests only
echo - newman run postman\collection.json: Run API tests only
echo.

REM Open summary report
start reports\test_summary.html

pause
