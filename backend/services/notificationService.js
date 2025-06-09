// 🔔 Notification Service for Real-time Order Updates
// Handles push notifications, WebSocket connections, and order status updates

const admin = require('firebase-admin');
const logger = require('../utils/logger');

class NotificationService {
  constructor() {
    this.connectedClients = new Map(); // Store WebSocket connections
    this.userTokens = new Map(); // Store FCM tokens by user ID
  }

  // 📱 Register FCM token for a user
  async registerFCMToken(userId, token) {
    try {
      this.userTokens.set(userId, token);
      logger.info(`FCM token registered for user: ${userId}`);
      return { success: true };
    } catch (error) {
      logger.error('Failed to register FCM token:', error);
      throw error;
    }
  }

  // 🔔 Send push notification via FCM
  async sendPushNotification(userId, notification, data = {}) {
    try {
      const token = this.userTokens.get(userId);
      if (!token) {
        logger.warning(`No FCM token found for user: ${userId}`);
        return { success: false, reason: 'No FCM token' };
      }

      // Check if Firebase is properly configured
      if (!admin.apps.length || admin.app().options.projectId === 'test-project') {
        logger.warning('Firebase not configured, skipping push notification');
        return { success: false, reason: 'Firebase not configured' };
      }

      const message = {
        token: token,
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl || undefined,
        },
        data: {
          ...data,
          timestamp: new Date().toISOString(),
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#FF5C22', // Chica's orange
            sound: 'default',
            channelId: 'order_updates',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
        webpush: {
          notification: {
            icon: '/icons/icon-192x192.png',
            badge: '/icons/badge-72x72.png',
            vibrate: [200, 100, 200],
          },
        },
      };

      const response = await admin.messaging().send(message);
      logger.info(`Push notification sent successfully: ${response}`);
      return { success: true, messageId: response };

    } catch (error) {
      logger.error('Failed to send push notification:', error);
      return { success: false, error: error.message };
    }
  }

  // 🌐 Send WebSocket notification
  sendWebSocketNotification(userId, data) {
    try {
      const client = this.connectedClients.get(userId);
      if (client && client.readyState === 1) { // WebSocket.OPEN
        client.send(JSON.stringify({
          type: 'notification',
          data: data,
          timestamp: new Date().toISOString(),
        }));
        logger.info(`WebSocket notification sent to user: ${userId}`);
        return true;
      }
      return false;
    } catch (error) {
      logger.error('Failed to send WebSocket notification:', error);
      return false;
    }
  }

  // 🍗 Send order status update notification
  async sendOrderStatusUpdate(userId, orderId, status, orderDetails = {}) {
    const statusMessages = {
      'confirmed': {
        title: '🍗 Order Confirmed!',
        body: `Your order #${orderId} has been confirmed and is being prepared.`,
      },
      'preparing': {
        title: '👨‍🍳 Order Being Prepared',
        body: `Your delicious chicken is being prepared! Order #${orderId}`,
      },
      'ready': {
        title: '🔥 Order Ready!',
        body: `Your order #${orderId} is ready for pickup! Come get your hot chicken!`,
      },
      'completed': {
        title: '✅ Order Complete',
        body: `Thank you for choosing Chica's Chicken! Order #${orderId} completed.`,
      },
      'cancelled': {
        title: '❌ Order Cancelled',
        body: `Your order #${orderId} has been cancelled. Refund will be processed.`,
      },
    };

    const notification = statusMessages[status] || {
      title: '📱 Order Update',
      body: `Your order #${orderId} status has been updated to: ${status}`,
    };

    const data = {
      type: 'order_status',
      orderId: orderId,
      status: status,
      ...orderDetails,
    };

    // Send both push notification and WebSocket notification
    const pushResult = await this.sendPushNotification(userId, notification, data);
    const wsResult = this.sendWebSocketNotification(userId, {
      ...notification,
      ...data,
    });

    logger.info(`Order status notification sent for order ${orderId}: Push=${pushResult.success}, WS=${wsResult}`);

    return {
      pushNotification: pushResult,
      webSocket: wsResult,
    };
  }

  // 🎉 Send promotional notifications
  async sendPromotionalNotification(userIds, notification, data = {}) {
    const results = [];

    for (const userId of userIds) {
      try {
        const result = await this.sendPushNotification(userId, notification, {
          ...data,
          type: 'promotion',
        });
        results.push({ userId, result });
      } catch (error) {
        logger.error(`Failed to send promotional notification to user ${userId}:`, error);
        results.push({ userId, result: { success: false, error: error.message } });
      }
    }

    return results;
  }

  // 🔗 Register WebSocket client
  registerWebSocketClient(userId, ws) {
    this.connectedClients.set(userId, ws);
    logger.info(`WebSocket client registered for user: ${userId}`);

    // Handle client disconnect
    ws.on('close', () => {
      this.connectedClients.delete(userId);
      logger.info(`WebSocket client disconnected for user: ${userId}`);
    });

    // Send welcome message
    ws.send(JSON.stringify({
      type: 'connection',
      message: 'Connected to Chica\'s Chicken notifications',
      timestamp: new Date().toISOString(),
    }));
  }

  // 📊 Get notification statistics
  getStats() {
    return {
      connectedWebSocketClients: this.connectedClients.size,
      registeredFCMTokens: this.userTokens.size,
      timestamp: new Date().toISOString(),
    };
  }

  // 🧹 Cleanup expired tokens and connections
  cleanup() {
    // Remove closed WebSocket connections
    for (const [userId, client] of this.connectedClients.entries()) {
      if (client.readyState !== 1) { // Not OPEN
        this.connectedClients.delete(userId);
        logger.info(`Cleaned up closed WebSocket for user: ${userId}`);
      }
    }
  }
}

// Export singleton instance
module.exports = new NotificationService();
