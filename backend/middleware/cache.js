const Redis = require('redis');
const logger = require('../utils/logger');

// Redis client configuration
const redisClient = Redis.createClient({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD,
  db: process.env.REDIS_CACHE_DB || 1, // Use different DB for caching
});

redisClient.on('error', (err) => {
  logger.error('Redis cache connection error:', err);
});

redisClient.on('connect', () => {
  logger.info('Redis cache connected successfully');
});

// 🗄️ Cache Configuration
const cacheConfig = {
  // Menu items cache (long-lived, rarely changes)
  menu: {
    ttl: 60 * 60 * 24, // 24 hours
    prefix: 'menu:'
  },
  
  // User preferences (medium-lived)
  userPrefs: {
    ttl: 60 * 60 * 4, // 4 hours
    prefix: 'user_prefs:'
  },
  
  // Search results (short-lived)
  search: {
    ttl: 60 * 15, // 15 minutes
    prefix: 'search:'
  },
  
  // API responses (very short-lived)
  api: {
    ttl: 60 * 5, // 5 minutes
    prefix: 'api:'
  },
  
  // Static content (very long-lived)
  static: {
    ttl: 60 * 60 * 24 * 7, // 7 days
    prefix: 'static:'
  }
};

// 🔄 Generic Cache Middleware
const createCacheMiddleware = (cacheType = 'api', customTTL = null) => {
  return async (req, res, next) => {
    try {
      const config = cacheConfig[cacheType];
      const ttl = customTTL || config.ttl;
      
      // Generate cache key based on request
      const cacheKey = generateCacheKey(req, config.prefix);
      
      // Try to get from cache
      const cachedData = await redisClient.get(cacheKey);
      
      if (cachedData) {
        logger.info(`Cache HIT for key: ${cacheKey}`);
        
        // Parse cached data and send response
        const parsedData = JSON.parse(cachedData);
        
        // Add cache headers
        res.set({
          'X-Cache': 'HIT',
          'X-Cache-Key': cacheKey,
          'Cache-Control': `public, max-age=${ttl}`
        });
        
        return res.json(parsedData);
      }
      
      logger.info(`Cache MISS for key: ${cacheKey}`);
      
      // Store original res.json method
      const originalJson = res.json;
      
      // Override res.json to cache the response
      res.json = function(data) {
        // Cache the response data
        redisClient.setex(cacheKey, ttl, JSON.stringify(data))
          .catch(err => logger.error('Cache set error:', err));
        
        // Add cache headers
        res.set({
          'X-Cache': 'MISS',
          'X-Cache-Key': cacheKey,
          'Cache-Control': `public, max-age=${ttl}`
        });
        
        // Call original json method
        return originalJson.call(this, data);
      };
      
      next();
      
    } catch (error) {
      logger.error('Cache middleware error:', error);
      // Continue without caching on error
      next();
    }
  };
};

// 🔑 Generate Cache Key
const generateCacheKey = (req, prefix) => {
  const { method, path, query, user } = req;
  
  // Include user ID for user-specific caches
  const userId = user?.id || 'anonymous';
  
  // Create a hash of query parameters for consistent keys
  const queryString = Object.keys(query)
    .sort()
    .map(key => `${key}=${query[key]}`)
    .join('&');
  
  const keyComponents = [prefix, method, path, queryString, userId]
    .filter(Boolean)
    .join(':');
  
  // Use hash for very long keys
  if (keyComponents.length > 200) {
    const crypto = require('crypto');
    return prefix + crypto.createHash('md5').update(keyComponents).digest('hex');
  }
  
  return keyComponents;
};

// 🍽️ Menu Cache Middleware
const menuCache = createCacheMiddleware('menu', 60 * 60 * 24); // 24 hours

// 👤 User Preferences Cache
const userPrefsCache = createCacheMiddleware('userPrefs', 60 * 60 * 4); // 4 hours

// 🔍 Search Results Cache
const searchCache = createCacheMiddleware('search', 60 * 15); // 15 minutes

// 📊 API Response Cache
const apiCache = createCacheMiddleware('api', 60 * 5); // 5 minutes

// 🗂️ Cache Invalidation
const invalidateCache = async (pattern) => {
  try {
    const keys = await redisClient.keys(pattern);
    if (keys.length > 0) {
      await redisClient.del(keys);
      logger.info(`Invalidated ${keys.length} cache keys matching pattern: ${pattern}`);
    }
  } catch (error) {
    logger.error('Cache invalidation error:', error);
  }
};

// 🍽️ Invalidate Menu Cache (when menu is updated)
const invalidateMenuCache = async () => {
  await invalidateCache('menu:*');
};

// 👤 Invalidate User Cache
const invalidateUserCache = async (userId) => {
  await invalidateCache(`*:*:*:*:${userId}`);
};

// 🔍 Invalidate Search Cache
const invalidateSearchCache = async () => {
  await invalidateCache('search:*');
};

// 📈 Cache Statistics
const getCacheStats = async () => {
  try {
    const info = await redisClient.info('memory');
    const keyCount = await redisClient.dbsize();
    
    return {
      memoryUsage: info,
      keyCount,
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    logger.error('Error getting cache stats:', error);
    return null;
  }
};

// 🧹 Cache Cleanup (remove expired keys)
const cleanupCache = async () => {
  try {
    // Redis automatically removes expired keys, but we can force cleanup
    const deletedKeys = await redisClient.eval(`
      local keys = redis.call('keys', ARGV[1])
      local deleted = 0
      for i=1,#keys do
        if redis.call('ttl', keys[i]) == -1 then
          redis.call('del', keys[i])
          deleted = deleted + 1
        end
      end
      return deleted
    `, 0, '*');
    
    logger.info(`Cache cleanup completed. Removed ${deletedKeys} expired keys.`);
    return deletedKeys;
  } catch (error) {
    logger.error('Cache cleanup error:', error);
    return 0;
  }
};

// 🔄 Cache Warming (preload frequently accessed data)
const warmCache = async () => {
  try {
    logger.info('Starting cache warming...');
    
    // Warm menu cache
    const menuService = require('../services/menu');
    const categories = await menuService.getMenuCategories();
    
    for (const category of categories) {
      const items = await menuService.getMenuItems(category.id);
      const cacheKey = `menu:GET:/api/menu/${category.id}::anonymous`;
      await redisClient.setex(cacheKey, cacheConfig.menu.ttl, JSON.stringify({
        success: true,
        data: items
      }));
    }
    
    logger.info('Cache warming completed successfully');
  } catch (error) {
    logger.error('Cache warming error:', error);
  }
};

// 🎯 Conditional Cache Middleware (cache based on conditions)
const conditionalCache = (condition, cacheType = 'api') => {
  return (req, res, next) => {
    if (condition(req)) {
      return createCacheMiddleware(cacheType)(req, res, next);
    }
    next();
  };
};

// 📱 Mobile-Optimized Cache
const mobileCache = conditionalCache(
  (req) => req.headers['user-agent']?.includes('Mobile'),
  'api'
);

module.exports = {
  redisClient,
  menuCache,
  userPrefsCache,
  searchCache,
  apiCache,
  mobileCache,
  createCacheMiddleware,
  invalidateCache,
  invalidateMenuCache,
  invalidateUserCache,
  invalidateSearchCache,
  getCacheStats,
  cleanupCache,
  warmCache,
  conditionalCache
};
