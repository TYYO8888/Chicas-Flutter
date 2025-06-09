const request = require('supertest');
const express = require('express');
const Redis = require('redis');
const { WebSocketService } = require('../services/websocket');
const { generalLimiter, authLimiter } = require('../middleware/rateLimiter');
const { verifyCaptcha } = require('../middleware/captcha');
const { encryptData, decryptData } = require('../utils/encryption');
const { menuCache } = require('../middleware/cache');

// Mock Redis for testing
jest.mock('redis');

describe('🧪 Advanced Features Test Suite', () => {
  let app;
  let server;
  let redisClient;

  beforeAll(async () => {
    // Setup test app
    app = express();
    app.use(express.json());
    
    // Mock Redis client
    redisClient = {
      get: jest.fn(),
      setex: jest.fn(),
      del: jest.fn(),
      keys: jest.fn(),
      info: jest.fn(),
      dbsize: jest.fn(),
    };
    
    Redis.createClient = jest.fn(() => redisClient);
    
    // Setup test routes
    app.get('/test-cache', menuCache, (req, res) => {
      res.json({ message: 'Cache test', timestamp: Date.now() });
    });
    
    app.post('/test-rate-limit', generalLimiter, (req, res) => {
      res.json({ message: 'Rate limit test passed' });
    });
    
    app.post('/test-auth-limit', authLimiter, (req, res) => {
      res.json({ message: 'Auth rate limit test passed' });
    });
    
    app.post('/test-captcha', verifyCaptcha, (req, res) => {
      res.json({ message: 'CAPTCHA test passed' });
    });
    
    server = app.listen(0); // Use random port
  });

  afterAll(async () => {
    if (server) {
      server.close();
    }
  });

  describe('🛡️ Security Features', () => {
    
    describe('Rate Limiting', () => {
      beforeEach(() => {
        // Reset Redis mocks
        redisClient.get.mockClear();
        redisClient.setex.mockClear();
      });

      test('should allow requests within rate limit', async () => {
        redisClient.get.mockResolvedValue('5'); // 5 requests made
        
        const response = await request(app)
          .post('/test-rate-limit')
          .send({ test: 'data' });
        
        expect(response.status).toBe(200);
        expect(response.body.message).toBe('Rate limit test passed');
      });

      test('should block requests exceeding rate limit', async () => {
        redisClient.get.mockResolvedValue('101'); // Exceeds limit of 100
        
        const response = await request(app)
          .post('/test-rate-limit')
          .send({ test: 'data' });
        
        expect(response.status).toBe(429);
        expect(response.body.error).toContain('Too many requests');
      });

      test('should have stricter limits for auth endpoints', async () => {
        redisClient.get.mockResolvedValue('6'); // Exceeds auth limit of 5
        
        const response = await request(app)
          .post('/test-auth-limit')
          .send({ test: 'data' });
        
        expect(response.status).toBe(429);
        expect(response.body.error).toContain('authentication attempts');
      });
    });

    describe('Data Encryption', () => {
      test('should encrypt and decrypt data correctly', () => {
        const originalData = 'sensitive user data';
        
        const encrypted = encryptData(originalData);
        expect(encrypted).not.toBe(originalData);
        expect(encrypted).toContain(':'); // Should have IV:tag:data format
        
        const decrypted = decryptData(encrypted);
        expect(decrypted).toBe(originalData);
      });

      test('should handle null/undefined data', () => {
        expect(encryptData(null)).toBe(null);
        expect(encryptData(undefined)).toBe(null);
        expect(decryptData(null)).toBe(null);
      });

      test('should fail gracefully with invalid encrypted data', () => {
        expect(() => decryptData('invalid:data')).toThrow();
      });
    });

    describe('CAPTCHA Verification', () => {
      test('should reject requests without CAPTCHA token', async () => {
        const response = await request(app)
          .post('/test-captcha')
          .send({ test: 'data' });
        
        expect(response.status).toBe(400);
        expect(response.body.error).toContain('CAPTCHA token is required');
      });

      // Note: Real CAPTCHA testing would require mocking the Google API
    });
  });

  describe('⚡ Performance Features', () => {
    
    describe('API Caching', () => {
      test('should return cached data on cache hit', async () => {
        const cachedData = JSON.stringify({
          message: 'Cached response',
          timestamp: 1234567890
        });
        
        redisClient.get.mockResolvedValue(cachedData);
        
        const response = await request(app)
          .get('/test-cache');
        
        expect(response.status).toBe(200);
        expect(response.headers['x-cache']).toBe('HIT');
        expect(response.body.message).toBe('Cached response');
      });

      test('should cache new data on cache miss', async () => {
        redisClient.get.mockResolvedValue(null); // Cache miss
        redisClient.setex.mockResolvedValue('OK');
        
        const response = await request(app)
          .get('/test-cache');
        
        expect(response.status).toBe(200);
        expect(response.headers['x-cache']).toBe('MISS');
        expect(redisClient.setex).toHaveBeenCalled();
      });
    });
  });

  describe('🔄 Real-time Features', () => {
    
    describe('WebSocket Service', () => {
      test('should initialize WebSocket service', () => {
        const mockServer = { on: jest.fn() };
        const wsService = new WebSocketService(mockServer);
        
        expect(wsService).toBeDefined();
        expect(wsService.clients).toBeDefined();
        expect(wsService.orderRooms).toBeDefined();
      });

      test('should track connection statistics', () => {
        const mockServer = { on: jest.fn() };
        const wsService = new WebSocketService(mockServer);
        
        const stats = wsService.getStats();
        expect(stats).toHaveProperty('totalConnections');
        expect(stats).toHaveProperty('uniqueUsers');
        expect(stats).toHaveProperty('activeOrderRooms');
        expect(stats).toHaveProperty('timestamp');
      });
    });
  });
});

// 🧪 Load Testing Simulation
describe('📊 Load Testing', () => {
  test('should handle concurrent requests', async () => {
    const promises = [];
    const concurrentRequests = 10;
    
    // Mock successful cache responses
    redisClient.get.mockResolvedValue(null);
    redisClient.setex.mockResolvedValue('OK');
    
    for (let i = 0; i < concurrentRequests; i++) {
      promises.push(
        request(app)
          .get('/test-cache')
          .expect(200)
      );
    }
    
    const responses = await Promise.all(promises);
    expect(responses).toHaveLength(concurrentRequests);
    
    // All requests should complete successfully
    responses.forEach(response => {
      expect(response.status).toBe(200);
    });
  });
});

// 🔍 Security Testing
describe('🔒 Security Testing', () => {
  test('should detect SQL injection attempts', () => {
    const maliciousInputs = [
      "'; DROP TABLE users; --",
      "1' OR '1'='1",
      "UNION SELECT * FROM users",
    ];
    
    maliciousInputs.forEach(input => {
      // Test that our sanitization catches these
      const sanitized = require('../utils/encryption').sanitizeData(input);
      expect(sanitized).not.toContain('DROP');
      expect(sanitized).not.toContain('UNION');
    });
  });

  test('should detect XSS attempts', () => {
    const xssInputs = [
      "<script>alert('xss')</script>",
      "javascript:alert('xss')",
      "<img src=x onerror=alert('xss')>",
    ];
    
    xssInputs.forEach(input => {
      const sanitized = require('../utils/encryption').sanitizeData(input);
      expect(sanitized).not.toContain('<script>');
      expect(sanitized).not.toContain('javascript:');
      expect(sanitized).not.toContain('onerror=');
    });
  });
});

// 📱 Mobile Performance Testing
describe('📱 Mobile Performance', () => {
  test('should handle mobile-specific requests', async () => {
    const response = await request(app)
      .get('/test-cache')
      .set('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15');
    
    expect(response.status).toBe(200);
    // Mobile requests should also be cached
    expect(['HIT', 'MISS']).toContain(response.headers['x-cache']);
  });
});

module.exports = {
  // Export for integration testing
  app,
  redisClient,
};
