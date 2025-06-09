// 🔐 Authentication Middleware
// This checks if users are who they say they are!

const admin = require('firebase-admin');
const { logger } = require('../utils/logger');

// Initialize Firebase Admin (only once)
if (!admin.apps.length) {
  try {
    // Check if we have valid Firebase credentials
    if (!process.env.FIREBASE_PROJECT_ID ||
        process.env.FIREBASE_PROJECT_ID === 'your-project-id' ||
        !process.env.FIREBASE_PRIVATE_KEY ||
        process.env.FIREBASE_PRIVATE_KEY.includes('REPLACE_WITH_YOUR_ACTUAL_PRIVATE_KEY')) {

      console.warn('⚠️  Firebase credentials not configured. Authentication will be disabled.');
      console.warn('   Please set up Firebase credentials in your .env file to enable authentication.');

      // Initialize with minimal config for testing
      admin.initializeApp({
        projectId: 'test-project'
      });
    } else {
      const serviceAccount = {
        type: "service_account",
        project_id: process.env.FIREBASE_PROJECT_ID,
        private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
        private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        client_email: process.env.FIREBASE_CLIENT_EMAIL,
        client_id: process.env.FIREBASE_CLIENT_ID,
        auth_uri: process.env.FIREBASE_AUTH_URI,
        token_uri: process.env.FIREBASE_TOKEN_URI,
      };

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });

      console.log('✅ Firebase Admin initialized successfully');
    }
  } catch (error) {
    console.error('❌ Firebase initialization failed:', error.message);
    console.warn('   Authentication will be disabled. Please check your Firebase configuration.');

    // Initialize with minimal config for testing
    admin.initializeApp({
      projectId: 'test-project'
    });
  }
}

// Middleware to verify Firebase ID tokens
const verifyToken = async (req, res, next) => {
  try {
    // Check if Firebase is properly configured
    if (!process.env.FIREBASE_PROJECT_ID ||
        process.env.FIREBASE_PROJECT_ID === 'your-project-id') {

      // For testing without Firebase, create a mock user
      req.user = {
        uid: 'test-user-123',
        email: 'test@chicaschicken.com',
        name: 'Test User',
        picture: null,
        emailVerified: true
      };

      logger.info('Using mock authentication for testing');
      return next();
    }

    // Get token from header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'No token provided or invalid format'
      });
    }

    const token = authHeader.split(' ')[1];

    // Verify the token with Firebase
    const decodedToken = await admin.auth().verifyIdToken(token);

    // Add user info to request object
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      name: decodedToken.name,
      picture: decodedToken.picture,
      emailVerified: decodedToken.email_verified
    };

    logger.info(`User authenticated: ${req.user.email}`);
    next();
  } catch (error) {
    logger.error('Token verification failed:', error);

    if (error.code === 'auth/id-token-expired') {
      return res.status(401).json({
        success: false,
        error: 'Token expired',
        code: 'TOKEN_EXPIRED'
      });
    }

    return res.status(401).json({
      success: false,
      error: 'Invalid token',
      code: 'INVALID_TOKEN'
    });
  }
};

// Middleware to check if user is admin
const requireAdmin = async (req, res, next) => {
  try {
    // Check if user has admin custom claims
    const userRecord = await admin.auth().getUser(req.user.uid);
    
    if (userRecord.customClaims && userRecord.customClaims.admin === true) {
      next();
    } else {
      return res.status(403).json({
        success: false,
        error: 'Admin access required'
      });
    }
  } catch (error) {
    logger.error('Admin check failed:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to verify admin status'
    });
  }
};

module.exports = { verifyToken, requireAdmin };
