#!/bin/bash

# 🧪 Comprehensive Testing Script for QSR Flutter App
# Runs all test suites and generates reports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create reports directory
mkdir -p reports

print_status "INFO" "🧪 Starting Comprehensive Test Suite for QSR App"
echo ""

# Check prerequisites
print_status "INFO" "Checking prerequisites..."

if ! command_exists flutter; then
    print_status "ERROR" "Flutter is not installed"
    exit 1
fi

if ! command_exists node; then
    print_status "ERROR" "Node.js is not installed"
    exit 1
fi

print_status "SUCCESS" "Prerequisites check completed"
echo ""

# Install dependencies
print_status "INFO" "Installing dependencies..."
flutter pub get

if command_exists npm; then
    npm install -g newman newman-reporter-htmlextra
    print_status "SUCCESS" "Newman installed for API testing"
fi

echo ""

# 1. Code Quality & Static Analysis
print_status "INFO" "🔍 Running code quality analysis..."

# Dart analysis
flutter analyze --fatal-infos > reports/analysis_report.txt 2>&1
if [ $? -eq 0 ]; then
    print_status "SUCCESS" "Code analysis passed"
else
    print_status "WARNING" "Code analysis found issues - check reports/analysis_report.txt"
fi

# Format check
dart format --set-exit-if-changed . > reports/format_report.txt 2>&1
if [ $? -eq 0 ]; then
    print_status "SUCCESS" "Code formatting is correct"
else
    print_status "WARNING" "Code formatting issues found - check reports/format_report.txt"
fi

echo ""

# 2. Unit Tests
print_status "INFO" "🧪 Running unit tests..."

flutter test --coverage --reporter=json > reports/unit_test_results.json 2>&1
if [ $? -eq 0 ]; then
    print_status "SUCCESS" "Unit tests passed"
    
    # Generate coverage report
    if command_exists genhtml; then
        genhtml coverage/lcov.info -o reports/coverage_html
        print_status "SUCCESS" "Coverage report generated at reports/coverage_html/index.html"
    fi
else
    print_status "ERROR" "Unit tests failed - check reports/unit_test_results.json"
fi

echo ""

# 3. Widget Tests
print_status "INFO" "🎨 Running widget tests..."

flutter test test/widget/ --reporter=json > reports/widget_test_results.json 2>&1
if [ $? -eq 0 ]; then
    print_status "SUCCESS" "Widget tests passed"
else
    print_status "WARNING" "Widget tests failed or not found - check reports/widget_test_results.json"
fi

echo ""

# 4. Integration Tests
print_status "INFO" "🌐 Running integration tests..."

# Enable web support for testing
flutter config --enable-web

# Run integration tests on web
flutter test integration_test/ -d web-server --reporter=json > reports/integration_test_results.json 2>&1
if [ $? -eq 0 ]; then
    print_status "SUCCESS" "Integration tests passed"
else
    print_status "WARNING" "Integration tests failed - check reports/integration_test_results.json"
fi

echo ""

# 5. API Tests (if Newman is available)
if command_exists newman; then
    print_status "INFO" "🌐 Running API tests..."
    
    # Check if Postman collection exists
    if [ -f "postman/QSR_API_Tests.postman_collection.json" ]; then
        newman run postman/QSR_API_Tests.postman_collection.json \
            -e postman/environments/staging.postman_environment.json \
            --reporters cli,json,htmlextra \
            --reporter-json-export reports/api_test_results.json \
            --reporter-htmlextra-export reports/api_test_report.html \
            --timeout-request 10000 \
            --bail > reports/api_test_output.txt 2>&1
        
        if [ $? -eq 0 ]; then
            print_status "SUCCESS" "API tests passed"
        else
            print_status "WARNING" "API tests failed - check reports/api_test_output.txt"
        fi
    else
        print_status "WARNING" "Postman collection not found - skipping API tests"
    fi
else
    print_status "WARNING" "Newman not available - skipping API tests"
fi

echo ""

# 6. Performance Tests
print_status "INFO" "📱 Running performance tests..."

# Build app for performance testing
flutter build web --release > reports/build_output.txt 2>&1
if [ $? -eq 0 ]; then
    print_status "SUCCESS" "App built successfully for performance testing"
    
    # Run basic performance checks
    echo "Build size analysis:" > reports/performance_report.txt
    du -sh build/web >> reports/performance_report.txt
    
    print_status "SUCCESS" "Performance analysis completed"
else
    print_status "ERROR" "Build failed - check reports/build_output.txt"
fi

echo ""

# 7. Security Tests
print_status "INFO" "🔒 Running security tests..."

# Check for hardcoded secrets
echo "Security scan results:" > reports/security_report.txt
echo "======================" >> reports/security_report.txt

if grep -r "password.*=" lib/ --include="*.dart" | grep -v "// " | grep -v "/// " >> reports/security_report.txt; then
    print_status "WARNING" "Potential hardcoded passwords found - check reports/security_report.txt"
else
    echo "✅ No hardcoded passwords detected" >> reports/security_report.txt
    print_status "SUCCESS" "No hardcoded passwords detected"
fi

# Check for SQL injection patterns
if grep -r "SELECT.*FROM" lib/ --include="*.dart" | grep -v "// " | grep -v "/// " >> reports/security_report.txt; then
    print_status "WARNING" "Potential SQL injection patterns found - check reports/security_report.txt"
else
    echo "✅ No SQL injection patterns detected" >> reports/security_report.txt
    print_status "SUCCESS" "No SQL injection patterns detected"
fi

echo ""

# 8. Generate Summary Report
print_status "INFO" "📊 Generating test summary report..."

cat > reports/test_summary.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>QSR App - Test Results Summary</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #2196F3; color: white; padding: 20px; border-radius: 8px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 8px; }
        .success { background: #e8f5e8; border-color: #4caf50; }
        .warning { background: #fff3cd; border-color: #ffc107; }
        .error { background: #f8d7da; border-color: #dc3545; }
        .timestamp { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧪 QSR App - Comprehensive Test Results</h1>
        <p class="timestamp">Generated on: $(date)</p>
    </div>
    
    <div class="section success">
        <h2>✅ Test Suite Completion</h2>
        <p>All test suites have been executed. Check individual reports for detailed results.</p>
    </div>
    
    <div class="section">
        <h2>📋 Available Reports</h2>
        <ul>
            <li><a href="analysis_report.txt">Code Analysis Report</a></li>
            <li><a href="unit_test_results.json">Unit Test Results</a></li>
            <li><a href="widget_test_results.json">Widget Test Results</a></li>
            <li><a href="integration_test_results.json">Integration Test Results</a></li>
            <li><a href="api_test_report.html">API Test Report</a></li>
            <li><a href="coverage_html/index.html">Code Coverage Report</a></li>
            <li><a href="security_report.txt">Security Scan Report</a></li>
            <li><a href="performance_report.txt">Performance Analysis</a></li>
        </ul>
    </div>
    
    <div class="section">
        <h2>🚀 Next Steps</h2>
        <ol>
            <li>Review any failed tests and fix issues</li>
            <li>Check code coverage and add tests for uncovered areas</li>
            <li>Address any security warnings</li>
            <li>Monitor performance metrics</li>
            <li>Deploy to staging environment for UAT</li>
        </ol>
    </div>
</body>
</html>
EOF

print_status "SUCCESS" "Test summary report generated at reports/test_summary.html"

echo ""
print_status "SUCCESS" "🎉 Comprehensive test suite completed!"
echo ""
echo "📊 Summary:"
echo "- Reports generated in: ./reports/"
echo "- Open reports/test_summary.html for overview"
echo "- Check individual report files for detailed results"
echo ""
echo "🔗 Useful commands:"
echo "- flutter test: Run unit tests only"
echo "- flutter test integration_test/: Run integration tests only"
echo "- newman run postman/collection.json: Run API tests only"
echo ""

# Open summary report if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    open reports/test_summary.html
fi
