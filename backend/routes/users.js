const express = require('express');
const router = express.Router();

// In-memory storage for user preferences (in production, use a database)
const userPreferences = new Map();

// GET /api/users/:userId/preferences
router.get('/:userId/preferences', (req, res) => {
  try {
    const { userId } = req.params;
    
    const preferences = userPreferences.get(userId);
    
    if (!preferences) {
      // Return default preferences if user doesn't exist
      const defaultPreferences = {
        userId,
        favoriteMenuItems: [],
        defaultCustomizations: {},
        darkModeEnabled: false,
        notificationsEnabled: true,
        preferredLanguage: 'en',
        dietaryRestrictions: {},
        favoriteOrders: [],
        lastUpdated: new Date().toISOString(),
      };
      
      userPreferences.set(userId, defaultPreferences);
      
      res.json({
        success: true,
        data: defaultPreferences,
        message: 'Default user preferences created'
      });
    } else {
      res.json({
        success: true,
        data: preferences,
        message: 'User preferences retrieved successfully'
      });
    }
  } catch (error) {
    console.error('Error getting user preferences:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user preferences',
      error: error.message
    });
  }
});

// PUT /api/users/:userId/preferences
router.put('/:userId/preferences', (req, res) => {
  try {
    const { userId } = req.params;
    const preferences = req.body;
    
    // Validate required fields
    if (!preferences.userId || preferences.userId !== userId) {
      return res.status(400).json({
        success: false,
        message: 'Invalid user ID in preferences data'
      });
    }
    
    // Update timestamp
    preferences.lastUpdated = new Date().toISOString();
    
    // Store preferences
    userPreferences.set(userId, preferences);
    
    res.json({
      success: true,
      data: preferences,
      message: 'User preferences updated successfully'
    });
  } catch (error) {
    console.error('Error updating user preferences:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user preferences',
      error: error.message
    });
  }
});

// GET /api/users/:userId/favorites
router.get('/:userId/favorites', (req, res) => {
  try {
    const { userId } = req.params;
    
    const preferences = userPreferences.get(userId);
    
    if (!preferences) {
      return res.json({
        success: true,
        data: [],
        message: 'No favorite items found'
      });
    }
    
    res.json({
      success: true,
      data: preferences.favoriteMenuItems || [],
      message: 'Favorite menu items retrieved successfully'
    });
  } catch (error) {
    console.error('Error getting favorite items:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get favorite items',
      error: error.message
    });
  }
});

// POST /api/users/:userId/favorites
router.post('/:userId/favorites', (req, res) => {
  try {
    const { userId } = req.params;
    const { menuItemId } = req.body;
    
    if (!menuItemId) {
      return res.status(400).json({
        success: false,
        message: 'Menu item ID is required'
      });
    }
    
    let preferences = userPreferences.get(userId);
    
    if (!preferences) {
      // Create default preferences if user doesn't exist
      preferences = {
        userId,
        favoriteMenuItems: [],
        defaultCustomizations: {},
        darkModeEnabled: false,
        notificationsEnabled: true,
        preferredLanguage: 'en',
        dietaryRestrictions: {},
        favoriteOrders: [],
        lastUpdated: new Date().toISOString(),
      };
    }
    
    // Add to favorites if not already present
    if (!preferences.favoriteMenuItems.includes(menuItemId)) {
      preferences.favoriteMenuItems.push(menuItemId);
      preferences.lastUpdated = new Date().toISOString();
      userPreferences.set(userId, preferences);
    }
    
    res.json({
      success: true,
      data: preferences.favoriteMenuItems,
      message: 'Item added to favorites successfully'
    });
  } catch (error) {
    console.error('Error adding favorite item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add favorite item',
      error: error.message
    });
  }
});

// DELETE /api/users/:userId/favorites/:menuItemId
router.delete('/:userId/favorites/:menuItemId', (req, res) => {
  try {
    const { userId, menuItemId } = req.params;
    
    const preferences = userPreferences.get(userId);
    
    if (!preferences) {
      return res.status(404).json({
        success: false,
        message: 'User preferences not found'
      });
    }
    
    // Remove from favorites
    const index = preferences.favoriteMenuItems.indexOf(menuItemId);
    if (index > -1) {
      preferences.favoriteMenuItems.splice(index, 1);
      preferences.lastUpdated = new Date().toISOString();
      userPreferences.set(userId, preferences);
    }
    
    res.json({
      success: true,
      data: preferences.favoriteMenuItems,
      message: 'Item removed from favorites successfully'
    });
  } catch (error) {
    console.error('Error removing favorite item:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to remove favorite item',
      error: error.message
    });
  }
});

// GET /api/users/:userId/favorite-orders
router.get('/:userId/favorite-orders', (req, res) => {
  try {
    const { userId } = req.params;
    
    const preferences = userPreferences.get(userId);
    
    if (!preferences) {
      return res.json({
        success: true,
        data: [],
        message: 'No favorite orders found'
      });
    }
    
    res.json({
      success: true,
      data: preferences.favoriteOrders || [],
      message: 'Favorite orders retrieved successfully'
    });
  } catch (error) {
    console.error('Error getting favorite orders:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get favorite orders',
      error: error.message
    });
  }
});

// POST /api/users/:userId/favorite-orders
router.post('/:userId/favorite-orders', (req, res) => {
  try {
    const { userId } = req.params;
    const favoriteOrder = req.body;
    
    // Validate required fields
    if (!favoriteOrder.name || !favoriteOrder.items || !Array.isArray(favoriteOrder.items)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid favorite order data'
      });
    }
    
    let preferences = userPreferences.get(userId);
    
    if (!preferences) {
      // Create default preferences if user doesn't exist
      preferences = {
        userId,
        favoriteMenuItems: [],
        defaultCustomizations: {},
        darkModeEnabled: false,
        notificationsEnabled: true,
        preferredLanguage: 'en',
        dietaryRestrictions: {},
        favoriteOrders: [],
        lastUpdated: new Date().toISOString(),
      };
    }
    
    // Add order details
    favoriteOrder.id = `fav_${Date.now()}`;
    favoriteOrder.createdAt = new Date().toISOString();
    favoriteOrder.orderCount = 1;
    
    preferences.favoriteOrders.push(favoriteOrder);
    preferences.lastUpdated = new Date().toISOString();
    userPreferences.set(userId, preferences);
    
    res.json({
      success: true,
      data: favoriteOrder,
      message: 'Favorite order saved successfully'
    });
  } catch (error) {
    console.error('Error saving favorite order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to save favorite order',
      error: error.message
    });
  }
});

// DELETE /api/users/:userId/favorite-orders/:orderId
router.delete('/:userId/favorite-orders/:orderId', (req, res) => {
  try {
    const { userId, orderId } = req.params;
    
    const preferences = userPreferences.get(userId);
    
    if (!preferences) {
      return res.status(404).json({
        success: false,
        message: 'User preferences not found'
      });
    }
    
    // Remove favorite order
    const index = preferences.favoriteOrders.findIndex(order => order.id === orderId);
    if (index > -1) {
      preferences.favoriteOrders.splice(index, 1);
      preferences.lastUpdated = new Date().toISOString();
      userPreferences.set(userId, preferences);
    }
    
    res.json({
      success: true,
      data: preferences.favoriteOrders,
      message: 'Favorite order removed successfully'
    });
  } catch (error) {
    console.error('Error removing favorite order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to remove favorite order',
      error: error.message
    });
  }
});

module.exports = router;
