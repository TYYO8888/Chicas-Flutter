// 🍗 Chica's Chicken Backend Server
// This is the main server file that starts everything up!

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const http = require('http');
const WebSocket = require('ws');
require('dotenv').config();

// Import our route handlers
const authRoutes = require('./routes/auth');
const menuRoutes = require('./routes/menu');
const orderRoutes = require('./routes/orders');
const paymentRoutes = require('./routes/payments');
const analyticsRoutes = require('./routes/analytics');
const notificationRoutes = require('./routes/notifications');

// Import middleware and services
const { errorHandler } = require('./middleware/errorHandler');
const { logger } = require('./utils/logger');
const notificationService = require('./services/notificationService');

// Create Express app
const app = express();
const PORT = process.env.PORT || 3000;

// 🛡️ Security Middleware
app.use(helmet()); // Adds security headers

// 🌐 CORS Configuration
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// 🚦 Rate Limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.'
  }
});
app.use('/api/', limiter);

// 📝 Body Parsing Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 📊 Request Logging
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path} - ${req.ip}`);
  next();
});

// 🏠 Health Check Endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: "Chica's Chicken Backend is running!",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV
  });
});

// 🛣️ API Routes
app.use('/api/auth', authRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/notifications', notificationRoutes);

// 🎯 Default Route
app.get('/', (req, res) => {
  res.json({
    message: "Welcome to Chica's Chicken API! 🍗",
    version: '1.0.0',
    documentation: '/api/docs'
  });
});

// 🚫 404 Handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `The route ${req.originalUrl} does not exist on this server.`
  });
});

// 🚨 Error Handler (must be last)
app.use(errorHandler);

// 🚀 Create HTTP Server and WebSocket Server
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// 🔔 WebSocket Connection Handler
wss.on('connection', (ws, req) => {
  logger.info('New WebSocket connection established');

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);

      if (data.type === 'register' && data.userId) {
        notificationService.registerWebSocketClient(data.userId, ws);
        logger.info(`WebSocket client registered for user: ${data.userId}`);
      }
    } catch (error) {
      logger.error('Failed to parse WebSocket message:', error);
    }
  });

  ws.on('error', (error) => {
    logger.error('WebSocket error:', error);
  });

  // Send welcome message
  ws.send(JSON.stringify({
    type: 'welcome',
    message: 'Connected to Chica\'s Chicken real-time notifications',
    timestamp: new Date().toISOString(),
  }));
});

// 🚀 Start Server
server.listen(PORT, () => {
  logger.info(`🍗 Chica's Chicken Backend running on port ${PORT}`);
  logger.info(`🌍 Environment: ${process.env.NODE_ENV}`);
  logger.info(`🔗 Health check: http://localhost:${PORT}/health`);
  logger.info(`🔔 WebSocket server ready for real-time notifications`);
});

module.exports = app;
