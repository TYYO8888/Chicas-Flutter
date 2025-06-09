# 🧪 Testing Setup for Advanced Features

## Prerequisites

### 1. Install Redis (for caching and rate limiting)
```bash
# Windows (using Chocolatey)
choco install redis-64

# macOS (using Homebrew)
brew install redis

# Ubuntu/Debian
sudo apt-get install redis-server

# Start Redis
redis-server
```

### 2. Install Required Dependencies

#### Backend Dependencies:
```bash
cd backend
npm install express-rate-limit rate-limit-redis ws bcrypt jsonwebtoken axios
```

#### Frontend Dependencies:
```bash
cd "Chica's Chicken Flutter"
flutter pub add web_socket_channel cached_network_image flutter_cache_manager
```

### 3. Environment Variables
Create `.env` file in backend directory:
```env
# Security
ENCRYPTION_KEY=your-256-bit-encryption-key-here-make-it-very-long-and-secure
RECAPTCHA_SECRET_KEY=your-recaptcha-secret-key
JWT_SECRET=your-jwt-secret-key

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# API
NODE_ENV=development
PORT=3000
```

### 4. Test Data Setup
We'll use the existing menu data and add some test scenarios.
