@echo off
REM Comprehensive Testing Script for QSR Flutter App (Windows)
REM Runs all test suites and generates reports

echo Starting Comprehensive Test Suite for QSR App
echo.

REM Create reports directory
if not exist reports mkdir reports

echo Checking prerequisites...

REM Check Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter is not installed
    exit /b 1
)

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed
    exit /b 1
)

echo SUCCESS: Prerequisites check completed
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
echo Generating test summary report...

echo QSR App - Test Results Summary > reports\test_summary.txt
echo ================================ >> reports\test_summary.txt
echo Generated on: %date% %time% >> reports\test_summary.txt
echo. >> reports\test_summary.txt
echo Available Reports: >> reports\test_summary.txt
echo - analysis_report.txt >> reports\test_summary.txt
echo - unit_test_results.json >> reports\test_summary.txt
echo - widget_test_results.json >> reports\test_summary.txt
echo - integration_test_results.json >> reports\test_summary.txt
echo - api_test_output.txt >> reports\test_summary.txt
echo - security_report.txt >> reports\test_summary.txt
echo - performance_report.txt >> reports\test_summary.txt

echo SUCCESS: Test summary report generated at reports\test_summary.txt

echo.
echo SUCCESS: Comprehensive test suite completed!
echo.
echo Summary:
echo - Reports generated in: .\reports\
echo - Open reports\test_summary.txt for overview
echo - Check individual report files for detailed results
echo.
echo Useful commands:
echo - flutter test: Run unit tests only
echo - flutter test integration_test\: Run integration tests only
echo - newman run postman\collection.json: Run API tests only
echo.

REM Open summary report
start reports\test_summary.txt

pause
