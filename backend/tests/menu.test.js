// 🧪 Menu API Tests
// This tests our menu endpoints to make sure they work correctly

const request = require('supertest');
const app = require('../server');

describe('Menu API', () => {
  
  // Test getting menu categories
  describe('GET /api/menu/categories', () => {
    it('should return all menu categories', async () => {
      const response = await request(app)
        .get('/api/menu/categories')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body.data.length).toBeGreaterThan(0);
      
      // Check if categories have required fields
      const category = response.body.data[0];
      expect(category).toHaveProperty('id');
      expect(category).toHaveProperty('name');
      expect(category).toHaveProperty('displayOrder');
    });
  });

  // Test getting items by category
  describe('GET /api/menu/category/:categoryId', () => {
    it('should return items for sandwiches category', async () => {
      const response = await request(app)
        .get('/api/menu/category/sandwiches')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body.data.length).toBeGreaterThan(0);
      
      // Check if items have required fields
      const item = response.body.data[0];
      expect(item).toHaveProperty('id');
      expect(item).toHaveProperty('name');
      expect(item).toHaveProperty('price');
      expect(item).toHaveProperty('category');
    });

    it('should return 404 for non-existent category', async () => {
      const response = await request(app)
        .get('/api/menu/category/non-existent')
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toContain('not found');
    });
  });

  // Test getting specific item
  describe('GET /api/menu/item/:itemId', () => {
    it('should return specific menu item', async () => {
      const response = await request(app)
        .get('/api/menu/item/og_sando')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id', 'og_sando');
      expect(response.body.data).toHaveProperty('name');
      expect(response.body.data).toHaveProperty('price');
    });

    it('should return 404 for non-existent item', async () => {
      const response = await request(app)
        .get('/api/menu/item/non-existent-item')
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('Item not found');
    });
  });

  // Test menu search
  describe('GET /api/menu/search', () => {
    it('should search menu items by name', async () => {
      const response = await request(app)
        .get('/api/menu/search?q=sando')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
      
      // All results should contain 'sando' in name or description
      response.body.data.forEach(item => {
        const searchTerm = 'sando';
        const inName = item.name.toLowerCase().includes(searchTerm);
        const inDescription = item.description.toLowerCase().includes(searchTerm);
        expect(inName || inDescription).toBe(true);
      });
    });

    it('should return 400 when search query is missing', async () => {
      const response = await request(app)
        .get('/api/menu/search')
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('Search query is required');
    });
  });

});

describe('Health Check', () => {
  it('should return server status', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);

    expect(response.body.status).toBe('OK');
    expect(response.body.message).toContain('running');
  });
});
