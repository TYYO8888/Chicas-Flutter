#!/usr/bin/env node

// 🚀 Backend Setup Script
// This helps you get started quickly!

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

console.log('🍗 Welcome to Chica\'s Chicken Backend Setup!');
console.log('This script will help you configure your environment.\n');

async function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
}

async function setup() {
  try {
    console.log('📋 Let\'s gather your configuration details:\n');

    // Check if .env already exists
    const envPath = path.join(__dirname, '..', '.env');
    if (fs.existsSync(envPath)) {
      const overwrite = await askQuestion('⚠️  .env file already exists. Overwrite? (y/N): ');
      if (overwrite.toLowerCase() !== 'y') {
        console.log('Setup cancelled. Your existing .env file is unchanged.');
        rl.close();
        return;
      }
    }

    // Gather configuration
    const config = {};

    console.log('🔥 Firebase Configuration:');
    config.FIREBASE_PROJECT_ID = await askQuestion('Firebase Project ID: ');
    config.FIREBASE_PRIVATE_KEY_ID = await askQuestion('Firebase Private Key ID: ');
    config.FIREBASE_CLIENT_EMAIL = await askQuestion('Firebase Client Email: ');
    config.FIREBASE_CLIENT_ID = await askQuestion('Firebase Client ID: ');
    
    console.log('\n💳 Stripe Configuration:');
    config.STRIPE_SECRET_KEY = await askQuestion('Stripe Secret Key (sk_test_...): ');
    
    console.log('\n🔐 Security Configuration:');
    const jwtSecret = await askQuestion('JWT Secret (or press Enter for auto-generated): ');
    config.JWT_SECRET = jwtSecret || generateRandomSecret();

    console.log('\n🌐 Server Configuration:');
    const port = await askQuestion('Server Port (default: 3000): ');
    config.PORT = port || '3000';

    const allowedOrigins = await askQuestion('Allowed Origins (comma-separated, default: localhost): ');
    config.ALLOWED_ORIGINS = allowedOrigins || 'http://localhost:3000,http://localhost:8080,http://10.0.2.2:3000';

    // Generate .env file
    const envContent = generateEnvFile(config);
    fs.writeFileSync(envPath, envContent);

    console.log('\n✅ Configuration saved to .env file!');
    console.log('\n📝 Next steps:');
    console.log('1. Add your Firebase private key to the .env file');
    console.log('2. Run: npm install');
    console.log('3. Run: npm run dev');
    console.log('4. Test: http://localhost:' + config.PORT + '/health');
    
    console.log('\n🎉 Setup complete! Happy coding!');

  } catch (error) {
    console.error('❌ Setup failed:', error.message);
  } finally {
    rl.close();
  }
}

function generateRandomSecret() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
  let result = '';
  for (let i = 0; i < 64; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

function generateEnvFile(config) {
  return `# Server Configuration
PORT=${config.PORT}
NODE_ENV=development

# JWT Secret
JWT_SECRET=${config.JWT_SECRET}

# Firebase Configuration
FIREBASE_PROJECT_ID=${config.FIREBASE_PROJECT_ID}
FIREBASE_PRIVATE_KEY_ID=${config.FIREBASE_PRIVATE_KEY_ID}
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\\nREPLACE_WITH_YOUR_ACTUAL_PRIVATE_KEY\\n-----END PRIVATE KEY-----\\n"
FIREBASE_CLIENT_EMAIL=${config.FIREBASE_CLIENT_EMAIL}
FIREBASE_CLIENT_ID=${config.FIREBASE_CLIENT_ID}
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token

# Stripe Configuration
STRIPE_SECRET_KEY=${config.STRIPE_SECRET_KEY}
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Database Configuration
DATABASE_URL=your-database-connection-string

# Email Configuration
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# CORS Configuration
ALLOWED_ORIGINS=${config.ALLOWED_ORIGINS}

# ⚠️  IMPORTANT: 
# 1. Replace FIREBASE_PRIVATE_KEY with your actual private key from Firebase service account JSON
# 2. Keep this file secure and never commit it to version control
# 3. For production, use environment variables instead of this file
`;
}

// Run setup
setup();
