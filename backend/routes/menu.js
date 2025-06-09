// 🍗 Menu Routes
// This handles all menu-related API endpoints

const express = require('express');
const { body, validationResult } = require('express-validator');
const { verifyToken, requireAdmin } = require('../middleware/auth');
const { logger } = require('../utils/logger');

const router = express.Router();

// 📋 Menu Data (Based on Official Chica's Chicken Menu)
// In production, this would come from a database
const menuData = {
  categories: [
    { id: 'sandwiches', name: 'Sandwiches', displayOrder: 1 },
    { id: 'whole-wings', name: 'Whole Wings', displayOrder: 2 },
    { id: 'chicken-pieces', name: 'Chicken Pieces', displayOrder: 3 },
    { id: 'chicken-bites', name: 'Chicken Bites', displayOrder: 4 },
    { id: 'crew-packs', name: 'Crew Packs', displayOrder: 5 },
    { id: 'sides', name: 'Sides', displayOrder: 6 },
    { id: 'fixins', name: "Fixin's", displayOrder: 7 },
    { id: 'sauces', name: 'Sauces', displayOrder: 8 },
    { id: 'beverages', name: 'Beverages', displayOrder: 9 }
  ],
  
  items: {
    'sandwiches': [
      {
        id: 'og_sando',
        name: 'The OG Sando',
        description: 'Choose your heat level! Nashville-spiced chicken breast served on Texas toast with pickles and mayo',
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true,
        heatLevels: ['MILD', 'MEDIUM', 'MEDIUM / HOT', 'HOT'],
        nutritionInfo: { calories: 650, protein: 35, carbs: 45, fat: 28 }
      },
      {
        id: 'sweet_heat_sando',
        name: 'Sweet Heat Sando',
        description: 'Nashville-spiced chicken breast with sweet heat sauce, pickled jalapeños, and mayo on Texas toast',
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true
      },
      {
        id: 'buffalo_sando',
        name: 'Crispy Buffalo Sando',
        description: "Nashville-spiced chicken breast with buffalo sauce, coleslaw, and Chica's sauce on Texas toast",
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true
      },
      {
        id: 'jalapeno_sando',
        name: 'Jalapeño Popper Sando',
        description: 'Nashville-spiced chicken breast with chipotle aioli, pickled jalapeños, and cream cheese on Texas toast',
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true
      },
      {
        id: 'hot_honey_sando',
        name: 'Hot Honey Sando',
        description: 'Nashville-spiced chicken breast with hot honey sauce, pickled jalapeños, and mayo on Texas toast',
        price: 13.00,
        imageUrl: 'assets/sandwiches.png',
        category: 'sandwiches',
        available: true
      }
    ],
    
    'whole-wings': [
      {
        id: 'og_wings',
        name: 'OG Whole Wings',
        description: 'Choose your heat level! Nashville-spiced whole wings served on white bread with pickles',
        price: 16.00,
        imageUrl: 'assets/whole_wings.png',
        category: 'whole-wings',
        available: true,
        heatLevels: ['MILD', 'MEDIUM', 'MEDIUM / HOT', 'HOT'],
        allowsSauceSelection: true,
        includedSauceCount: 1,
        sizes: { '6 Wings': 16.00, '12 Wings': 28.00, '18 Wings': 40.00 }
      },
      {
        id: 'lemon_pepper_wings',
        name: 'Lemon Pepper Wings',
        description: 'Whole wings seasoned with lemon pepper, served on white bread with pickles',
        price: 16.00,
        imageUrl: 'assets/whole_wings.png',
        category: 'whole-wings',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1,
        sizes: { '6 Wings': 16.00, '12 Wings': 28.00, '18 Wings': 40.00 }
      }
    ],

    'chicken-pieces': [
      {
        id: '2pc_chicken',
        name: '2 Pieces',
        description: "Choose your heat level! Nashville-spiced chicken pieces served on white bread with pickles, includes one Chica's sauce",
        price: 13.00,
        imageUrl: 'assets/chicken_pieces.png',
        category: 'chicken-pieces',
        available: true,
        heatLevels: ['MILD', 'MEDIUM', 'MEDIUM / HOT', 'HOT'],
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: '3pc_chicken',
        name: '3 Pieces',
        description: "Choose your heat level! Nashville-spiced chicken pieces served on white bread with pickles, includes one Chica's sauce",
        price: 18.00,
        imageUrl: 'assets/chicken_pieces.png',
        category: 'chicken-pieces',
        available: true,
        heatLevels: ['MILD', 'MEDIUM', 'MEDIUM / HOT', 'HOT'],
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: '4pc_chicken',
        name: '4 Pieces',
        description: "Choose your heat level! Nashville-spiced chicken pieces served on white bread with pickles, includes two Chica's sauces",
        price: 22.00,
        imageUrl: 'assets/chicken_pieces.png',
        category: 'chicken-pieces',
        available: true,
        heatLevels: ['MILD', 'MEDIUM', 'MEDIUM / HOT', 'HOT'],
        allowsSauceSelection: true,
        includedSauceCount: 2
      }
    ],

    'chicken-bites': [
      {
        id: 'og_bites',
        name: 'OG Bites',
        description: 'Choose your heat level! Nashville-spiced chicken bites with one sauce',
        price: 12.50,
        imageUrl: 'assets/chicken_bites.png',
        category: 'chicken-bites',
        available: true,
        heatLevels: ['MILD', 'MEDIUM', 'MEDIUM / HOT', 'HOT'],
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: 'buffalo_bites',
        name: 'Buffalo Bites',
        description: 'Crispy chicken bites tossed in buffalo sauce',
        price: 12.50,
        imageUrl: 'assets/chicken_bites.png',
        category: 'chicken-bites',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: 'lemon_pepper_bites',
        name: 'Lemon Pepper Bites',
        description: 'Crispy chicken bites seasoned with lemon pepper',
        price: 12.50,
        imageUrl: 'assets/chicken_bites.png',
        category: 'chicken-bites',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      },
      {
        id: 'hot_honey_bites',
        name: 'Hot Honey Bites',
        description: 'Crispy chicken bites drizzled with hot honey sauce',
        price: 12.50,
        imageUrl: 'assets/chicken_bites.png',
        category: 'chicken-bites',
        available: true,
        allowsSauceSelection: true,
        includedSauceCount: 1
      }
    ],

    'crew-packs': [
      {
        id: 'crew_pack_1',
        name: 'Crew Pack 1',
        description: '($45 serves 2-3): 2x Sandwiches, 1x Chicken Bites, 2x Sides [R], 2x Sauces, 2x Drinks',
        price: 45.00,
        imageUrl: 'assets/crew_packs.png',
        category: 'crew-packs',
        available: true,
        serves: '2-3',
        customizationCounts: {
          'Sandwiches': 2,
          'Chicken Bites': 1,
          'Sides': 2,
          'Sauces': 2,
          'Beverages': 2,
        },
        customizationCategories: ['Sandwiches', 'Chicken Bites', 'Sides', 'Sauces', 'Beverages'],
        requiresCustomization: true
      },
      {
        id: 'crew_pack_2',
        name: 'Crew Pack 2',
        description: '($65 serves 4-5): 3x Sandwiches, 2x Chicken Bites, 3x Sides [R], 3x Sauces, 3x Drinks',
        price: 65.00,
        imageUrl: 'assets/crew_packs.png',
        category: 'crew-packs',
        available: true,
        serves: '4-5',
        customizationCounts: {
          'Sandwiches': 3,
          'Chicken Bites': 2,
          'Sides': 3,
          'Sauces': 3,
          'Beverages': 3,
        },
        customizationCategories: ['Sandwiches', 'Chicken Bites', 'Sides', 'Sauces', 'Beverages'],
        requiresCustomization: true
      },
      {
        id: 'crew_pack_3',
        name: 'Crew Pack 3',
        description: '($85 serves 6-7): 4x Sandwiches, 3x Chicken Bites, 4x Sides [R], 4x Sauces, 4x Drinks',
        price: 85.00,
        imageUrl: 'assets/crew_packs.png',
        category: 'crew-packs',
        available: true,
        serves: '6-7',
        customizationCounts: {
          'Sandwiches': 4,
          'Chicken Bites': 3,
          'Sides': 4,
          'Sauces': 4,
          'Beverages': 4,
        },
        customizationCategories: ['Sandwiches', 'Chicken Bites', 'Sides', 'Sauces', 'Beverages'],
        requiresCustomization: true
      }
    ],

    'sides': [
      {
        id: 'waffle_fries',
        name: 'Waffle Fries',
        description: 'Golden waffle-cut fries with perfect seasoning',
        price: 5.50,
        imageUrl: 'assets/sides.png',
        category: 'sides',
        available: true,
        sizes: { 'Regular': 5.50, 'Large': 8.00 }
      },
      {
        id: 'cajun_waffle_fries',
        name: 'Cajun Waffle Fries',
        description: 'Waffle fries seasoned with Cajun spices',
        price: 6.00,
        imageUrl: 'assets/sides.png',
        category: 'sides',
        available: true,
        sizes: { 'Regular': 6.00, 'Large': 8.50 }
      },
      {
        id: 'sour_cream_onion_waffle_fries',
        name: 'Sour Cream + Onion Waffle Fries',
        description: 'Waffle fries with sour cream and onion seasoning',
        price: 6.00,
        imageUrl: 'assets/sides.png',
        category: 'sides',
        available: true,
        sizes: { 'Regular': 6.00, 'Large': 8.50 }
      },
      {
        id: 'deep_fried_pickles',
        name: 'DEEP Fried Pickles',
        description: 'Crispy deep-fried pickle spears',
        price: 6.50,
        imageUrl: 'assets/sides.png',
        category: 'sides',
        available: true
      }
    ],

    'fixins': [
      {
        id: 'dill_pickles',
        name: 'Dill Pickles',
        description: 'Classic dill pickle spears',
        price: 2.00,
        imageUrl: 'assets/fixins.png',
        category: 'fixins',
        available: true
      },
      {
        id: 'pickled_jalapenos',
        name: 'Pickled Jalapeños',
        description: 'Spicy pickled jalapeño slices',
        price: 2.50,
        imageUrl: 'assets/fixins.png',
        category: 'fixins',
        available: true
      },
      {
        id: 'brioche_bun',
        name: 'Brioche Bun',
        description: 'Upgrade to a buttery brioche bun',
        price: 1.00,
        imageUrl: 'assets/fixins.png',
        category: 'fixins',
        available: true
      }
    ],

    'sauces': [
      {
        id: 'chicas_sauce',
        name: "Chica's Sauce (Buttermilk Ranch)",
        description: 'Our signature buttermilk ranch sauce',
        price: 1.25,
        imageUrl: 'assets/sauces.png',
        category: 'sauces',
        available: true
      },
      {
        id: 'sweet_heat_sauce',
        name: 'Sweet Heat Sauce',
        description: 'Perfect balance of sweet and spicy',
        price: 1.25,
        imageUrl: 'assets/sauces.png',
        category: 'sauces',
        available: true
      },
      {
        id: 'buffalo_sauce',
        name: 'Buffalo Sauce',
        description: 'Classic tangy buffalo sauce',
        price: 1.25,
        imageUrl: 'assets/sauces.png',
        category: 'sauces',
        available: true
      },
      {
        id: 'chipotle_aioli',
        name: 'Chipotle Aioli',
        description: 'Smoky chipotle mayo blend',
        price: 1.25,
        imageUrl: 'assets/sauces.png',
        category: 'sauces',
        available: true
      },
      {
        id: 'hot_honey_sauce',
        name: 'Hot Honey Sauce',
        description: 'Sweet honey with a spicy kick',
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
        description: 'Classic Pepsi cola',
        price: 2.50,
        imageUrl: 'assets/beverages.png',
        category: 'beverages',
        available: true,
        sizes: { 'Regular': 2.50, 'Large': 3.00 }
      },
      {
        id: 'diet_pepsi',
        name: 'Diet Pepsi',
        description: 'Zero calorie Diet Pepsi',
        price: 2.50,
        imageUrl: 'assets/beverages.png',
        category: 'beverages',
        available: true,
        sizes: { 'Regular': 2.50, 'Large': 3.00 }
      },
      {
        id: 'mountain_dew',
        name: 'Mountain Dew',
        description: 'Citrus flavored soda',
        price: 2.50,
        imageUrl: 'assets/beverages.png',
        category: 'beverages',
        available: true,
        sizes: { 'Regular': 2.50, 'Large': 3.00 }
      },
      {
        id: 'lemonade',
        name: 'Lemonade',
        description: 'Fresh squeezed lemonade',
        price: 3.00,
        imageUrl: 'assets/beverages.png',
        category: 'beverages',
        available: true,
        sizes: { 'Regular': 3.00, 'Large': 3.50 }
      },
      {
        id: 'sweet_tea',
        name: 'Sweet Tea',
        description: 'Southern-style sweet tea',
        price: 2.75,
        imageUrl: 'assets/beverages.png',
        category: 'beverages',
        available: true,
        sizes: { 'Regular': 2.75, 'Large': 3.25 }
      },
      {
        id: 'water',
        name: 'Bottled Water',
        description: 'Pure bottled water',
        price: 2.00,
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

    // Add allowsHeatLevelSelection flag based on heatLevels array
    const processedItems = items.map(item => ({
      ...item,
      allowsHeatLevelSelection: !!(item.heatLevels && item.heatLevels.length > 0)
    }));

    res.json({
      success: true,
      data: processedItems,
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
