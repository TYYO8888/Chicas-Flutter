// 🍗 Menu Routes
// This handles all menu-related API endpoints

const express = require('express');
const { body, validationResult } = require('express-validator');
const { verifyToken, requireAdmin } = require('../middleware/auth');
const { logger } = require('../utils/logger');

const router = express.Router();

// 📋 Menu Data (converted from your Flutter MenuService)
// In production, this would come from a database
const menuData = {
  categories: [
    { id: 'sandwiches', name: 'Sandwiches', displayOrder: 1 },
    { id: 'whole-wings', name: 'Whole Wings', displayOrder: 2 },
    { id: 'chicken-pieces', name: 'Chicken Pieces', displayOrder: 3 },
    { id: 'chicken-bites', name: 'Chicken Bites', displayOrder: 4 },
    { id: 'sides', name: 'Sides', displayOrder: 5 },
    { id: 'fixins', name: "Fixin's", displayOrder: 6 },
    { id: 'sauces', name: 'Sauces', displayOrder: 7 },
    { id: 'crew-combos', name: 'CREW Combos', displayOrder: 8 },
    { id: 'beverages', name: 'Beverages', displayOrder: 9 }
  ],
  
  items: {
    'sandwiches': [
      {
        id: 'og_sando',
        name: 'The OG Sando',
        description: 'Choose your heat level! Nashville-spiced',
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true,
        sizes: { 'Texas Toast': 13.00, 'Brioche Bun': 14.00 },
        nutritionInfo: { calories: 650, protein: 35, carbs: 45, fat: 28 }
      },
      {
        id: 'sweet_heat_sando',
        name: 'Sweet Heat Sando',
        description: 'Sweet heat sauce topped with pickled jalapeños',
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true,
        sizes: { 'Texas Toast': 13.00, 'Brioche Bun': 14.00 }
      },
      {
        id: 'buffalo_sando',
        name: 'Crispy Buffalo Sando',
        description: "Buffalo sauce topped with slaw and Chica's sauce",
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true,
        sizes: { 'Texas Toast': 13.00, 'Brioche Bun': 14.00 }
      },
      {
        id: 'jalapeno_sando',
        name: 'Jalapeno Popper Sando',
        description: 'Topped with chipotle aioli, pickled jalapeños',
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true,
        sizes: { 'Texas Toast': 13.00, 'Brioche Bun': 14.00 }
      },
      {
        id: 'hot_honey_sando',
        name: 'Hot Honey Sando',
        description: 'Hot honey sauce topped with pickled jalapeños',
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true,
        sizes: { 'Texas Toast': 13.00, 'Brioche Bun': 14.00 }
      }
    ],
    
    'whole-wings': [
      {
        id: 'ilb_plus_wings',
        name: 'ILB+',
        description: "Includes one side of Chica's sauce",
        price: 18.00,
        imageUrl: 'assets/whole_wings.png',
        category: 'whole-wings',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: 'og_wings',
        name: 'OG Whole Wings',
        description: 'Choose your heat level! Nashville-spiced served on white bread, topped with pickles',
        price: 16.00,
        imageUrl: 'assets/whole_wings.png',
        category: 'whole-wings',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: 'lemon_pepper_wings',
        name: 'Lemon Pepper Wings',
        description: 'Lemon pepper seasoning',
        price: 16.00,
        imageUrl: 'assets/whole_wings.png',
        category: 'whole-wings',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      }
    ],

    'chicken-pieces': [
      {
        id: '2pc_chicken',
        name: '2 Pieces',
        description: "Served on white bread, topped with pickles, includes one Chica's sauce",
        price: 13.00,
        imageUrl: 'assets/chicken_pieces.png',
        category: 'chicken-pieces',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: '3pc_chicken',
        name: '3 Pieces',
        description: "Served on white bread, topped with pickles, includes one Chica's sauce",
        price: 18.00,
        imageUrl: 'assets/chicken_pieces.png',
        category: 'chicken-pieces',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: '4pc_chicken',
        name: '4 Pieces',
        description: "Served on white bread, topped with pickles, includes two Chica's sauces",
        price: 22.00,
        imageUrl: 'assets/chicken_pieces.png',
        category: 'chicken-pieces',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 2
      }
    ],

    'chicken-bites': [
      {
        id: 'og_bites',
        name: 'OG Bites',
        description: 'Choose your heat level! Nashville-spiced',
        price: 12.50,
        imageUrl: 'assets/chicken_bites.png',
        category: 'chicken-bites',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: 'sweet_heat_bites',
        name: 'Sweet Heat Bites',
        description: 'Sweet heat sauce topped with pickled jalapeños',
        price: 12.50,
        imageUrl: 'assets/chicken_bites.png',
        category: 'chicken-bites',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: 'buffalo_bites',
        name: 'Buffalo Bites',
        description: 'Buffalo sauce',
        price: 12.50,
        imageUrl: 'assets/chicken_bites.png',
        category: 'chicken-bites',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      }
    ],

    'sides': [
      {
        id: 'crinkle_fries',
        name: 'Crinkle Cut Fries',
        description: 'Crispy crinkle cut fries',
        price: 5.00,
        imageUrl: 'assets/sides.png',
        category: 'sides',
        available: true,
        sizes: { 'Regular': 5.00, 'Large': 7.50 }
      },
      {
        id: 'mac_cheese',
        name: 'Mac & Cheese',
        description: 'Creamy three-cheese blend',
        price: 5.00,
        imageUrl: 'assets/sides.png',
        category: 'sides',
        available: true,
        sizes: { 'Regular': 5.00, 'Large': 7.50 }
      }
    ],

    'sauces': [
      {
        id: 'chicas_sauce',
        name: "Chica's Sauce (Buttermilk Ranch)",
        description: '',
        price: 1.25,
        imageUrl: 'assets/sauces.png',
        category: 'sauces',
        available: true
      },
      {
        id: 'sweet_heat_sauce',
        name: 'Sweet Heat Sauce',
        description: '',
        price: 1.25,
        imageUrl: 'assets/sauces.png',
        category: 'sauces',
        available: true
      }
    ],

    'beverages': [
      {
        id: 'pepsi',
        name: 'Pepsi',
        description: 'Classic Pepsi cola.',
        price: 2.50,
        imageUrl: 'assets/beverages.png',
        category: 'beverages',
        available: true
      },
      {
        id: 'diet_pepsi',
        name: 'Diet Pepsi',
        description: 'Zero calorie Diet Pepsi.',
        price: 2.50,
        imageUrl: 'assets/beverages.png',
        category: 'beverages',
        available: true
      }
    ]
  }
};

// 📋 GET /api/menu/categories - Get all menu categories
router.get('/categories', (req, res) => {
  try {
    logger.info('Fetching menu categories');
    
    res.json({
      success: true,
      data: menuData.categories,
      message: 'Categories retrieved successfully'
    });
  } catch (error) {
    logger.error('Error fetching categories:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch categories'
    });
  }
});

// 🍗 GET /api/menu/category/:categoryId - Get items by category
router.get('/category/:categoryId', (req, res) => {
  try {
    const { categoryId } = req.params;
    logger.info(`Fetching menu items for category: ${categoryId}`);
    
    const items = menuData.items[categoryId] || [];
    
    if (items.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Category not found or no items available'
      });
    }
    
    res.json({
      success: true,
      data: items,
      message: `Items for category ${categoryId} retrieved successfully`
    });
  } catch (error) {
    logger.error('Error fetching category items:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch category items'
    });
  }
});

// 🎯 GET /api/menu/item/:itemId - Get specific item details
router.get('/item/:itemId', (req, res) => {
  try {
    const { itemId } = req.params;
    logger.info(`Fetching item details for: ${itemId}`);
    
    // Search through all categories for the item
    let foundItem = null;
    for (const category in menuData.items) {
      foundItem = menuData.items[category].find(item => item.id === itemId);
      if (foundItem) break;
    }
    
    if (!foundItem) {
      return res.status(404).json({
        success: false,
        error: 'Item not found'
      });
    }
    
    res.json({
      success: true,
      data: foundItem,
      message: 'Item retrieved successfully'
    });
  } catch (error) {
    logger.error('Error fetching item:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch item'
    });
  }
});

// 🔍 GET /api/menu/search - Search menu items
router.get('/search', (req, res) => {
  try {
    const { q, category } = req.query;
    
    if (!q) {
      return res.status(400).json({
        success: false,
        error: 'Search query is required'
      });
    }
    
    logger.info(`Searching menu items for: ${q}`);
    
    let searchResults = [];
    const searchTerm = q.toLowerCase();
    
    // Search through categories
    const categoriesToSearch = category ? [category] : Object.keys(menuData.items);
    
    categoriesToSearch.forEach(cat => {
      if (menuData.items[cat]) {
        const matches = menuData.items[cat].filter(item => 
          item.name.toLowerCase().includes(searchTerm) ||
          item.description.toLowerCase().includes(searchTerm)
        );
        searchResults = searchResults.concat(matches);
      }
    });
    
    res.json({
      success: true,
      data: searchResults,
      message: `Found ${searchResults.length} items matching "${q}"`
    });
  } catch (error) {
    logger.error('Error searching menu:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to search menu'
    });
  }
});

module.exports = router;
