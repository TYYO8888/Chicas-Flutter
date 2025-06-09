// 🔐 Authentication Routes
// This handles user login, registration, and profile management

const express = require('express');
const { body, validationResult } = require('express-validator');
const admin = require('firebase-admin');
const { verifyToken } = require('../middleware/auth');
const { logger } = require('../utils/logger');

const router = express.Router();

// 📝 POST /api/auth/register - Register new user
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('name').trim().isLength({ min: 2 })
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { email, password, name, phone } = req.body;
    
    logger.info(`Attempting to register user: ${email}`);

    // Create user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
      emailVerified: false
    });

    // Create user profile in Firestore
    const userProfile = {
      uid: userRecord.uid,
      email,
      name,
      phone: phone || null,
      addresses: [],
      preferences: {
        favoriteItems: [],
        dietaryRestrictions: []
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLogin: admin.firestore.FieldValue.serverTimestamp()
    };

    await admin.firestore()
      .collection('users')
      .doc(userRecord.uid)
      .set(userProfile);

    logger.info(`User registered successfully: ${email}`);

    res.status(201).json({
      success: true,
      data: {
        uid: userRecord.uid,
        email: userRecord.email,
        name: userRecord.displayName
      },
      message: 'User registered successfully'
    });

  } catch (error) {
    logger.error('Registration error:', error);
    
    if (error.code === 'auth/email-already-exists') {
      return res.status(400).json({
        success: false,
        error: 'Email already registered'
      });
    }
    
    res.status(500).json({
      success: false,
      error: 'Registration failed'
    });
  }
});

// 🔑 POST /api/auth/login - Login user (Firebase handles this on client side)
router.post('/login', (req, res) => {
  // Note: With Firebase Auth, login is handled on the client side
  // This endpoint is mainly for documentation and potential custom logic
  res.json({
    success: true,
    message: 'Login is handled by Firebase Auth on the client side',
    instructions: 'Use Firebase Auth SDK in your Flutter app to sign in users'
  });
});

// 👤 GET /api/auth/profile - Get user profile
router.get('/profile', verifyToken, async (req, res) => {
  try {
    logger.info(`Fetching profile for user: ${req.user.uid}`);

    // Get user profile from Firestore
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(req.user.uid)
      .get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        error: 'User profile not found'
      });
    }

    const userData = userDoc.data();
    
    res.json({
      success: true,
      data: {
        uid: userData.uid,
        email: userData.email,
        name: userData.name,
        phone: userData.phone,
        addresses: userData.addresses,
        preferences: userData.preferences,
        createdAt: userData.createdAt,
        lastLogin: userData.lastLogin
      },
      message: 'Profile retrieved successfully'
    });

  } catch (error) {
    logger.error('Error fetching profile:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch profile'
    });
  }
});

// ✏️ PUT /api/auth/profile - Update user profile
router.put('/profile', [
  verifyToken,
  body('name').optional().trim().isLength({ min: 2 }),
  body('phone').optional().isMobilePhone()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { name, phone, addresses, preferences } = req.body;
    
    logger.info(`Updating profile for user: ${req.user.uid}`);

    const updateData = {
      ...(name && { name }),
      ...(phone && { phone }),
      ...(addresses && { addresses }),
      ...(preferences && { preferences }),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    await admin.firestore()
      .collection('users')
      .doc(req.user.uid)
      .update(updateData);

    // Also update Firebase Auth display name if provided
    if (name) {
      await admin.auth().updateUser(req.user.uid, {
        displayName: name
      });
    }

    logger.info(`Profile updated successfully for user: ${req.user.uid}`);

    res.json({
      success: true,
      message: 'Profile updated successfully'
    });

  } catch (error) {
    logger.error('Error updating profile:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update profile'
    });
  }
});

// 🚪 POST /api/auth/logout - Logout user
router.post('/logout', verifyToken, async (req, res) => {
  try {
    // Update last login time
    await admin.firestore()
      .collection('users')
      .doc(req.user.uid)
      .update({
        lastLogin: admin.firestore.FieldValue.serverTimestamp()
      });

    logger.info(`User logged out: ${req.user.email}`);

    res.json({
      success: true,
      message: 'Logged out successfully'
    });

  } catch (error) {
    logger.error('Logout error:', error);
    res.status(500).json({
      success: false,
      error: 'Logout failed'
    });
  }
});

// 🗑️ DELETE /api/auth/account - Delete user account
router.delete('/account', verifyToken, async (req, res) => {
  try {
    logger.info(`Deleting account for user: ${req.user.uid}`);

    // Delete user data from Firestore
    await admin.firestore()
      .collection('users')
      .doc(req.user.uid)
      .delete();

    // Delete user from Firebase Auth
    await admin.auth().deleteUser(req.user.uid);

    logger.info(`Account deleted successfully: ${req.user.email}`);

    res.json({
      success: true,
      message: 'Account deleted successfully'
    });

  } catch (error) {
    logger.error('Account deletion error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete account'
    });
  }
});

module.exports = router;
