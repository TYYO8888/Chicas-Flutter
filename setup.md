# 🚀 Chica's Chicken Backend Setup Guide

Welcome! Let's get your backend up and running step by step.

## 📋 Prerequisites Checklist

Before we start, make sure you have:
- [ ] Node.js 18+ installed
- [ ] Flutter SDK installed
- [ ] A Google account (for Firebase)
- [ ] A Stripe account (for payments)

## 🔥 Step 1: Firebase Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Name it "chicas-chicken" (or your preferred name)
4. Enable Google Analytics (recommended)
5. Wait for project creation

### 1.2 Enable Firebase Services
1. **Authentication:**
   - Go to Authentication > Sign-in method
   - Enable Email/Password
   - Enable Google (optional but recommended)

2. **Firestore Database:**
   - Go to Firestore Database
   - Click "Create database"
   - Start in test mode (we'll secure it later)
   - Choose a location close to your users

3. **Firebase Analytics:**
   - Should be enabled by default
   - Go to Analytics to verify

### 1.3 Get Firebase Credentials
1. Go to Project Settings (gear icon)
2. Click "Service accounts" tab
3. Click "Generate new private key"
4. Download the JSON file
5. Keep this file secure - you'll need it for the backend

### 1.4 Add Flutter App to Firebase
1. In Project Settings, click "Add app" > Flutter
2. Follow the setup wizard
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the correct directories as instructed

## 💳 Step 2: Stripe Setup

### 2.1 Create Stripe Account
1. Go to [Stripe](https://stripe.com)
2. Sign up for an account
3. Complete account verification

### 2.2 Get API Keys
1. Go to Developers > API keys
2. Copy your "Publishable key" and "Secret key"
3. Keep these secure - you'll need them for both frontend and backend

### 2.3 Set Up Webhooks (Optional for now)
1. Go to Developers > Webhooks
2. Add endpoint: `https://your-domain.com/api/payments/webhook`
3. Select events: `payment_intent.succeeded`, `payment_intent.payment_failed`

## 🖥️ Step 3: Backend Setup

### 3.1 Install Dependencies
```bash
cd backend
npm install
```

### 3.2 Configure Environment
```bash
cp .env.example .env
```

Edit `.env` file with your actual values:
```env
# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Secret (generate a strong one)
JWT_SECRET=your-super-secret-jwt-key-change-this

# Firebase Configuration (from your service account JSON)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Key-Here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account@your-project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id

# Stripe Configuration
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### 3.3 Start Backend Server
```bash
npm run dev
```

You should see:
```
🍗 Chica's Chicken Backend running on port 3000
🌍 Environment: development
🔗 Health check: http://localhost:3000/health
```

### 3.4 Test Backend
Open your browser and go to:
- `http://localhost:3000/health` - Should show server status
- `http://localhost:3000/api/menu/categories` - Should show menu categories

## 📱 Step 4: Flutter Setup

### 4.1 Install Dependencies
```bash
flutter pub get
```

### 4.2 Configure Firebase for Flutter
1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Configure Flutter app:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 4.3 Configure Stripe for Flutter
Add your Stripe publishable key to your app. You can do this in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Add this
  static const String stripePublishableKey = 'pk_test_your_publishable_key';
  // ... rest of your config
}
```

### 4.4 Update API Configuration
In `lib/config/api_config.dart`, make sure the base URL points to your backend:
```dart
static const String _baseUrlDev = 'http://localhost:3000';
```

For Android emulator, you might need:
```dart
static const String _baseUrlDev = 'http://10.0.2.2:3000';
```

## 🧪 Step 5: Testing

### 5.1 Test Backend
```bash
cd backend
npm test
```

### 5.2 Test Flutter App
```bash
flutter test
```

### 5.3 Manual Testing
1. Start your backend: `npm run dev`
2. Start your Flutter app: `flutter run`
3. Try browsing the menu
4. Try creating an account
5. Try placing an order

## 🚀 Step 6: Deployment (Optional)

### 6.1 Deploy Backend to Google Cloud
1. Install Google Cloud CLI
2. Create a new project
3. Deploy:
```bash
gcloud app deploy
```

### 6.2 Update Flutter Configuration
Update your production API URL in `lib/config/api_config.dart`

## 🔧 Troubleshooting

### Common Issues:

**Backend won't start:**
- Check your `.env` file has all required values
- Make sure Node.js 18+ is installed
- Check if port 3000 is already in use

**Firebase connection issues:**
- Verify your service account JSON is correct
- Check Firebase project ID matches
- Ensure Firestore is enabled

**Flutter build issues:**
- Run `flutter clean && flutter pub get`
- Check if all dependencies are compatible
- Verify Firebase configuration files are in correct locations

**API connection issues:**
- Check if backend is running on correct port
- Verify CORS settings in backend
- For Android emulator, use `10.0.2.2` instead of `localhost`

## 📞 Need Help?

If you run into issues:
1. Check the logs in `backend/logs/`
2. Use Flutter's debug console
3. Check Firebase console for errors
4. Verify all environment variables are set correctly

## 🎉 You're Ready!

Once everything is working:
- Your backend is serving the API
- Your Flutter app can connect to the backend
- Users can browse menus and place orders
- Payments are processed through Stripe
- Data is stored in Firebase

Next steps:
- Add more menu items through the API
- Customize the UI to match your brand
- Set up push notifications
- Add analytics tracking
- Deploy to production

Happy coding! 🍗
