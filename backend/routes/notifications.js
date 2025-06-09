// 🔔 Notification Routes
// API endpoints for managing push notifications and real-time updates

const express = require('express');
const router = express.Router();
const notificationService = require('../services/notificationService');
const logger = require('../utils/logger');

// 📱 Register FCM token
router.post('/register-token', async (req, res) => {
  try {
    const { userId, token } = req.body;

    if (!userId || !token) {
      return res.status(400).json({
        success: false,
        message: 'User ID and FCM token are required',
      });
    }

    const result = await notificationService.registerFCMToken(userId, token);
    
    logger.info(`FCM token registered for user: ${userId}`);
    
    res.json({
      success: true,
      message: 'FCM token registered successfully',
      data: result,
    });

  } catch (error) {
    logger.error('Failed to register FCM token:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register FCM token',
      error: error.message,
    });
  }
});

// 🔔 Send test notification
router.post('/test', async (req, res) => {
  try {
    const { userId, title, body, data } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    const notification = {
      title: title || '🍗 Test Notification from Chica\'s Chicken',
      body: body || 'This is a test notification to verify your setup is working!',
    };

    const result = await notificationService.sendPushNotification(
      userId, 
      notification, 
      data || { type: 'test' }
    );

    logger.info(`Test notification sent to user: ${userId}`);

    res.json({
      success: true,
      message: 'Test notification sent',
      data: result,
    });

  } catch (error) {
    logger.error('Failed to send test notification:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send test notification',
      error: error.message,
    });
  }
});

// 🍗 Send order status update
router.post('/order-status', async (req, res) => {
  try {
    const { userId, orderId, status, orderDetails } = req.body;

    if (!userId || !orderId || !status) {
      return res.status(400).json({
        success: false,
        message: 'User ID, order ID, and status are required',
      });
    }

    const validStatuses = ['confirmed', 'preparing', 'ready', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${validStatuses.join(', ')}`,
      });
    }

    const result = await notificationService.sendOrderStatusUpdate(
      userId, 
      orderId, 
      status, 
      orderDetails
    );

    logger.info(`Order status notification sent: Order ${orderId} -> ${status}`);

    res.json({
      success: true,
      message: 'Order status notification sent',
      data: result,
    });

  } catch (error) {
    logger.error('Failed to send order status notification:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send order status notification',
      error: error.message,
    });
  }
});

// 🎉 Send promotional notification
router.post('/promotion', async (req, res) => {
  try {
    const { userIds, title, body, data } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'User IDs array is required',
      });
    }

    if (!title || !body) {
      return res.status(400).json({
        success: false,
        message: 'Title and body are required',
      });
    }

    const notification = { title, body };
    const results = await notificationService.sendPromotionalNotification(
      userIds, 
      notification, 
      data
    );

    const successCount = results.filter(r => r.result.success).length;
    
    logger.info(`Promotional notification sent to ${successCount}/${userIds.length} users`);

    res.json({
      success: true,
      message: `Promotional notification sent to ${successCount}/${userIds.length} users`,
      data: {
        totalUsers: userIds.length,
        successCount: successCount,
        results: results,
      },
    });

  } catch (error) {
    logger.error('Failed to send promotional notification:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send promotional notification',
      error: error.message,
    });
  }
});

// 📊 Get notification statistics
router.get('/stats', (req, res) => {
  try {
    const stats = notificationService.getStats();
    
    res.json({
      success: true,
      message: 'Notification statistics retrieved',
      data: stats,
    });

  } catch (error) {
    logger.error('Failed to get notification stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get notification statistics',
      error: error.message,
    });
  }
});

// 🧹 Cleanup expired connections
router.post('/cleanup', (req, res) => {
  try {
    notificationService.cleanup();
    
    logger.info('Notification service cleanup completed');
    
    res.json({
      success: true,
      message: 'Cleanup completed successfully',
    });

  } catch (error) {
    logger.error('Failed to cleanup notification service:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cleanup notification service',
      error: error.message,
    });
  }
});

module.exports = router;
