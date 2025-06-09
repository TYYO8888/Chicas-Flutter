const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis');
const Redis = require('redis');
const logger = require('../utils/logger');

// Redis client for distributed rate limiting
const redisClient = Redis.createClient({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD,
});

redisClient.on('error', (err) => {
  logger.error('Redis connection error:', err);
});

// 🛡️ General API Rate Limiter
const generalLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args) => redisClient.sendCommand(args),
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.',
    retryAfter: '15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn(`Rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      success: false,
      error: 'Too many requests from this IP, please try again later.',
      retryAfter: '15 minutes'
    });
  }
});

// 🔐 Authentication Rate Limiter (Stricter)
const authLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args) => redisClient.sendCommand(args),
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 auth attempts per windowMs
  message: {
    error: 'Too many authentication attempts, please try again later.',
    retryAfter: '15 minutes'
  },
  skipSuccessfulRequests: true, // Don't count successful requests
  handler: (req, res) => {
    logger.warn(`Auth rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      success: false,
      error: 'Too many authentication attempts, please try again later.',
      retryAfter: '15 minutes'
    });
  }
});

// 📧 Password Reset Rate Limiter (Very Strict)
const passwordResetLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args) => redisClient.sendCommand(args),
  }),
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // Limit each IP to 3 password reset attempts per hour
  message: {
    error: 'Too many password reset attempts, please try again later.',
    retryAfter: '1 hour'
  },
  handler: (req, res) => {
    logger.warn(`Password reset rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      success: false,
      error: 'Too many password reset attempts, please try again later.',
      retryAfter: '1 hour'
    });
  }
});

// 🛒 Order Creation Rate Limiter
const orderLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args) => redisClient.sendCommand(args),
  }),
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 10, // Limit each IP to 10 orders per 5 minutes
  message: {
    error: 'Too many order attempts, please slow down.',
    retryAfter: '5 minutes'
  },
  handler: (req, res) => {
    logger.warn(`Order rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      success: false,
      error: 'Too many order attempts, please slow down.',
      retryAfter: '5 minutes'
    });
  }
});

// 🔍 Search Rate Limiter
const searchLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args) => redisClient.sendCommand(args),
  }),
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 30, // Limit each IP to 30 searches per minute
  message: {
    error: 'Too many search requests, please slow down.',
    retryAfter: '1 minute'
  },
  handler: (req, res) => {
    logger.warn(`Search rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      success: false,
      error: 'Too many search requests, please slow down.',
      retryAfter: '1 minute'
    });
  }
});

// 🚫 Suspicious Activity Detector
const suspiciousActivityDetector = (req, res, next) => {
  const suspiciousPatterns = [
    /\b(union|select|insert|delete|drop|create|alter)\b/i, // SQL injection
    /<script|javascript:|on\w+=/i, // XSS attempts
    /\.\.\//g, // Path traversal
    /\b(admin|root|administrator)\b/i, // Admin probing
  ];

  const userAgent = req.get('User-Agent') || '';
  const requestBody = JSON.stringify(req.body);
  const queryString = JSON.stringify(req.query);
  const fullRequest = `${req.url} ${requestBody} ${queryString} ${userAgent}`;

  for (const pattern of suspiciousPatterns) {
    if (pattern.test(fullRequest)) {
      logger.error(`Suspicious activity detected from IP: ${req.ip}`, {
        url: req.url,
        method: req.method,
        userAgent,
        body: req.body,
        query: req.query
      });
      
      return res.status(403).json({
        success: false,
        error: 'Suspicious activity detected. Request blocked.'
      });
    }
  }

  next();
};

// 📊 Rate Limit Status Endpoint
const getRateLimitStatus = async (req, res) => {
  try {
    const ip = req.ip;
    const keys = [
      `rl:general:${ip}`,
      `rl:auth:${ip}`,
      `rl:password-reset:${ip}`,
      `rl:order:${ip}`,
      `rl:search:${ip}`
    ];

    const results = await Promise.all(
      keys.map(async (key) => {
        const count = await redisClient.get(key);
        return { key, count: count || 0 };
      })
    );

    res.json({
      success: true,
      data: {
        ip,
        limits: results
      }
    });
  } catch (error) {
    logger.error('Error getting rate limit status:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get rate limit status'
    });
  }
};

module.exports = {
  generalLimiter,
  authLimiter,
  passwordResetLimiter,
  orderLimiter,
  searchLimiter,
  suspiciousActivityDetector,
  getRateLimitStatus,
  redisClient
};
