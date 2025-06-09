const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');

class WebSocketService {
  constructor(server) {
    this.wss = new WebSocket.Server({ 
      server,
      path: '/ws',
      verifyClient: this.verifyClient.bind(this)
    });
    
    this.clients = new Map(); // userId -> Set of WebSocket connections
    this.orderRooms = new Map(); // orderId -> Set of WebSocket connections
    
    this.setupWebSocketServer();
    logger.info('WebSocket server initialized');
  }

  // 🔐 Verify client authentication
  verifyClient(info) {
    try {
      const url = new URL(info.req.url, 'http://localhost');
      const token = url.searchParams.get('token');
      
      if (!token) {
        logger.warn('WebSocket connection rejected: No token provided');
        return false;
      }
      
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      info.req.user = decoded;
      return true;
    } catch (error) {
      logger.warn('WebSocket connection rejected: Invalid token', error.message);
      return false;
    }
  }

  // 🔧 Setup WebSocket server
  setupWebSocketServer() {
    this.wss.on('connection', (ws, req) => {
      const user = req.user;
      logger.info(`WebSocket connected: User ${user.id}`);
      
      // Add client to user connections
      if (!this.clients.has(user.id)) {
        this.clients.set(user.id, new Set());
      }
      this.clients.get(user.id).add(ws);
      
      // Setup message handlers
      ws.on('message', (data) => this.handleMessage(ws, user, data));
      ws.on('close', () => this.handleDisconnection(ws, user));
      ws.on('error', (error) => this.handleError(ws, user, error));
      
      // Send welcome message
      this.sendToClient(ws, {
        type: 'connection',
        message: 'Connected to Chica\'s Chicken real-time service',
        timestamp: new Date().toISOString()
      });
    });
  }

  // 📨 Handle incoming messages
  handleMessage(ws, user, data) {
    try {
      const message = JSON.parse(data);
      logger.info(`WebSocket message from user ${user.id}:`, message);
      
      switch (message.type) {
        case 'join_order':
          this.joinOrderRoom(ws, user, message.orderId);
          break;
          
        case 'leave_order':
          this.leaveOrderRoom(ws, user, message.orderId);
          break;
          
        case 'ping':
          this.sendToClient(ws, { type: 'pong', timestamp: new Date().toISOString() });
          break;
          
        case 'subscribe_notifications':
          this.subscribeToNotifications(ws, user);
          break;
          
        default:
          logger.warn(`Unknown message type: ${message.type}`);
      }
    } catch (error) {
      logger.error('Error handling WebSocket message:', error);
      this.sendToClient(ws, {
        type: 'error',
        message: 'Invalid message format'
      });
    }
  }

  // 🚪 Handle client disconnection
  handleDisconnection(ws, user) {
    logger.info(`WebSocket disconnected: User ${user.id}`);
    
    // Remove from user connections
    if (this.clients.has(user.id)) {
      this.clients.get(user.id).delete(ws);
      if (this.clients.get(user.id).size === 0) {
        this.clients.delete(user.id);
      }
    }
    
    // Remove from order rooms
    for (const [orderId, connections] of this.orderRooms.entries()) {
      connections.delete(ws);
      if (connections.size === 0) {
        this.orderRooms.delete(orderId);
      }
    }
  }

  // ❌ Handle WebSocket errors
  handleError(ws, user, error) {
    logger.error(`WebSocket error for user ${user.id}:`, error);
  }

  // 🏠 Join order room for real-time updates
  joinOrderRoom(ws, user, orderId) {
    if (!this.orderRooms.has(orderId)) {
      this.orderRooms.set(orderId, new Set());
    }
    
    this.orderRooms.get(orderId).add(ws);
    
    this.sendToClient(ws, {
      type: 'joined_order',
      orderId,
      message: `Joined order ${orderId} for real-time updates`
    });
    
    logger.info(`User ${user.id} joined order room: ${orderId}`);
  }

  // 🚪 Leave order room
  leaveOrderRoom(ws, user, orderId) {
    if (this.orderRooms.has(orderId)) {
      this.orderRooms.get(orderId).delete(ws);
      
      if (this.orderRooms.get(orderId).size === 0) {
        this.orderRooms.delete(orderId);
      }
    }
    
    this.sendToClient(ws, {
      type: 'left_order',
      orderId,
      message: `Left order ${orderId} room`
    });
    
    logger.info(`User ${user.id} left order room: ${orderId}`);
  }

  // 🔔 Subscribe to general notifications
  subscribeToNotifications(ws, user) {
    // Mark this connection as subscribed to notifications
    ws.subscribedToNotifications = true;
    
    this.sendToClient(ws, {
      type: 'subscribed_notifications',
      message: 'Subscribed to notifications'
    });
    
    logger.info(`User ${user.id} subscribed to notifications`);
  }

  // 📤 Send message to specific client
  sendToClient(ws, message) {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }

  // 👤 Send message to all connections of a user
  sendToUser(userId, message) {
    const userConnections = this.clients.get(userId);
    if (userConnections) {
      userConnections.forEach(ws => this.sendToClient(ws, message));
    }
  }

  // 🛒 Send order update to order room
  sendOrderUpdate(orderId, update) {
    const orderConnections = this.orderRooms.get(orderId);
    if (orderConnections) {
      const message = {
        type: 'order_update',
        orderId,
        update,
        timestamp: new Date().toISOString()
      };
      
      orderConnections.forEach(ws => this.sendToClient(ws, message));
      logger.info(`Sent order update for order ${orderId} to ${orderConnections.size} clients`);
    }
  }

  // 📢 Broadcast to all connected clients
  broadcast(message) {
    this.wss.clients.forEach(ws => {
      if (ws.readyState === WebSocket.OPEN) {
        this.sendToClient(ws, message);
      }
    });
  }

  // 🔔 Send notification to subscribed users
  sendNotification(notification) {
    this.wss.clients.forEach(ws => {
      if (ws.readyState === WebSocket.OPEN && ws.subscribedToNotifications) {
        this.sendToClient(ws, {
          type: 'notification',
          notification,
          timestamp: new Date().toISOString()
        });
      }
    });
  }

  // 📊 Get connection statistics
  getStats() {
    return {
      totalConnections: this.wss.clients.size,
      uniqueUsers: this.clients.size,
      activeOrderRooms: this.orderRooms.size,
      timestamp: new Date().toISOString()
    };
  }

  // 🧹 Cleanup inactive connections
  cleanup() {
    this.wss.clients.forEach(ws => {
      if (ws.readyState !== WebSocket.OPEN) {
        ws.terminate();
      }
    });
  }
}

// 🛒 Order Status Updates
const OrderStatus = {
  PENDING: 'pending',
  CONFIRMED: 'confirmed',
  PREPARING: 'preparing',
  READY: 'ready',
  OUT_FOR_DELIVERY: 'out_for_delivery',
  DELIVERED: 'delivered',
  CANCELLED: 'cancelled'
};

// 📱 Notification Types
const NotificationType = {
  ORDER_CONFIRMED: 'order_confirmed',
  ORDER_READY: 'order_ready',
  ORDER_DELIVERED: 'order_delivered',
  PROMOTION: 'promotion',
  SYSTEM_MAINTENANCE: 'system_maintenance'
};

module.exports = {
  WebSocketService,
  OrderStatus,
  NotificationType
};
