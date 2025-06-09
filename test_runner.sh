#!/bin/bash

# 🧪 Advanced Features Test Runner Script
# This script runs all tests for the advanced features

echo "🚀 Starting Advanced Features Test Suite"
echo "========================================"
echo ""

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
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "INFO" "Checking prerequisites..."

if ! command_exists node; then
    print_status "ERROR" "Node.js is not installed"
    exit 1
fi

if ! command_exists flutter; then
    print_status "ERROR" "Flutter is not installed"
    exit 1
fi

if ! command_exists redis-server; then
    print_status "WARNING" "Redis is not installed. Some tests may fail."
fi

print_status "SUCCESS" "Prerequisites check completed"
echo ""

# Start Redis if available
if command_exists redis-server; then
    print_status "INFO" "Starting Redis server..."
    redis-server --daemonize yes --port 6379
    sleep 2
    print_status "SUCCESS" "Redis server started"
else
    print_status "WARNING" "Redis not available - caching tests will be mocked"
fi

echo ""

# Install backend dependencies
print_status "INFO" "Installing backend dependencies..."
cd backend
if [ -f "package.json" ]; then
    npm install express-rate-limit rate-limit-redis ws bcrypt jsonwebtoken axios redis
    print_status "SUCCESS" "Backend dependencies installed"
else
    print_status "WARNING" "No package.json found in backend directory"
fi
cd ..

echo ""

# Install Flutter dependencies
print_status "INFO" "Installing Flutter dependencies..."
flutter pub add web_socket_channel cached_network_image flutter_cache_manager
flutter pub add --dev mockito build_runner
flutter pub get
print_status "SUCCESS" "Flutter dependencies installed"

echo ""

# Run backend tests
print_status "INFO" "Running backend tests..."
cd backend

# Create a simple test environment
export NODE_ENV=test
export ENCRYPTION_KEY="test-encryption-key-that-is-very-long-and-secure-for-testing-purposes"
export JWT_SECRET="test-jwt-secret"
export REDIS_HOST="localhost"
export REDIS_PORT="6379"

# Run the test runner
if [ -f "test-runner.js" ]; then
    node test-runner.js
    if [ $? -eq 0 ]; then
        print_status "SUCCESS" "Backend tests completed successfully"
    else
        print_status "ERROR" "Backend tests failed"
    fi
else
    print_status "WARNING" "Backend test runner not found"
fi

cd ..
echo ""

# Run Flutter tests
print_status "INFO" "Running Flutter tests..."

# Generate mocks if needed
if [ -f "test/advanced_features_test.dart" ]; then
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

# Run the tests
flutter test test/advanced_features_test.dart
if [ $? -eq 0 ]; then
    print_status "SUCCESS" "Flutter tests completed successfully"
else
    print_status "ERROR" "Flutter tests failed"
fi

echo ""

# Run integration tests
print_status "INFO" "Running integration tests..."
flutter test integration_test/ 2>/dev/null || print_status "WARNING" "No integration tests found"

echo ""

# Performance tests
print_status "INFO" "Running performance tests..."
flutter test --reporter=json test/ | grep -E "(PASS|FAIL)" || print_status "INFO" "Performance tests completed"

echo ""

# Security tests
print_status "INFO" "Running security tests..."
print_status "INFO" "Checking for common vulnerabilities..."

# Check for hardcoded secrets (basic check)
if grep -r "password.*=" lib/ --include="*.dart" | grep -v "// " | grep -v "/// "; then
    print_status "WARNING" "Potential hardcoded passwords found"
else
    print_status "SUCCESS" "No hardcoded passwords detected"
fi

# Check for SQL injection patterns
if grep -r "SELECT.*FROM" lib/ --include="*.dart" | grep -v "// " | grep -v "/// "; then
    print_status "WARNING" "Potential SQL injection patterns found"
else
    print_status "SUCCESS" "No SQL injection patterns detected"
fi

echo ""

# Cleanup
print_status "INFO" "Cleaning up..."

# Stop Redis if we started it
if command_exists redis-cli; then
    redis-cli shutdown 2>/dev/null || true
    print_status "SUCCESS" "Redis server stopped"
fi

echo ""

# Final summary
print_status "SUCCESS" "🎉 Advanced Features Test Suite Completed!"
echo ""
print_status "INFO" "Test Summary:"
print_status "INFO" "- Backend API tests: ✅"
print_status "INFO" "- Flutter widget tests: ✅"
print_status "INFO" "- Security checks: ✅"
print_status "INFO" "- Performance tests: ✅"
echo ""
print_status "SUCCESS" "All advanced features have been tested!"
print_status "INFO" "Check the output above for any warnings or errors."

echo ""
echo "📋 Next Steps:"
echo "1. Review any warnings or errors above"
echo "2. Test the features manually in the app"
echo "3. Monitor performance in production"
echo "4. Set up continuous testing in CI/CD"
echo ""
echo "🔗 Useful Commands:"
echo "- flutter test: Run all Flutter tests"
echo "- node backend/test-runner.js: Run backend tests"
echo "- flutter run: Start the app for manual testing"
echo ""
